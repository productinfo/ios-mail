// Copyright (c) 2022 Proton AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import Groot
import ProtonCore_Crypto
import ProtonCore_DataModel
import ProtonCore_TestingToolkit
import ProtonCore_UIFoundations
import XCTest

@testable import ProtonMail

final class MessageInfoProviderTest: XCTestCase {
    private var apiMock: APIServiceMock!
    private var delegateObject: ProviderDelegate!
    private var featureFlagCache: MockFeatureFlagCache!
    private var message: MessageEntity!
    private var messageDecrypter: MessageDecrypterMock!
    private var sut: MessageInfoProvider!
    private var user: UserManager!
    private var imageTempUrl: URL!
    private var userContainer: UserContainer!

    private let systemUpTime = SystemUpTimeMock(
        localServerTime: TimeInterval(1635745851),
        localSystemUpTime: TimeInterval(2000),
        systemUpTime: TimeInterval(2000)
    )
    private let labelID = LabelID("0")

    override func setUpWithError() throws {
        try super.setUpWithError()

        LocaleEnvironment.locale = { .enUS }
        LocaleEnvironment.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        apiMock = APIServiceMock()
        apiMock.sessionUIDStub.fixture = String.randomString(10)
        apiMock.dohInterfaceStub.fixture = DohMock()

        featureFlagCache = .init()

        user = try UserManager.prepareUser(apiMock: apiMock)
        // testing are more thorough with this setting disabled, even though it is enabled by default
        user.userInfo.hideRemoteImages = 1

        message = try Self.prepareEncryptedMessage(
            plaintextBody: MessageDecrypterTestData.decryptedHTMLMimeBody(),
            mimeType: .multipartMixed,
            user: user
        )

        messageDecrypter = MessageDecrypterMock(userDataSource: user)

        let globalContainer = GlobalContainer()
        globalContainer.featureFlagCacheFactory.register { self.featureFlagCache }

        userContainer = UserContainer(userManager: user, globalContainer: globalContainer)

        sut = MessageInfoProvider(
            message: message,
            messageDecrypter: messageDecrypter,
            systemUpTime: systemUpTime,
            labelID: labelID,
            dependencies: userContainer,
            highlightedKeywords: ["contact", "feng"],
            dateFormatter: .init()
        )
        delegateObject = ProviderDelegate()
        sut.set(delegate: delegateObject)

        // Prepare for api mock to write image data to disk
        imageTempUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent("senderImage", isDirectory: true)
        try FileManager.default.createDirectory(at: imageTempUrl, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        sut = nil
        apiMock = nil
        delegateObject = nil
        featureFlagCache = nil
        message = nil
        messageDecrypter = nil
        user = nil
        userContainer = nil

        try FileManager.default.removeItem(at: imageTempUrl)
        try super.tearDownWithError()
    }

    func checkHighlight(source: NSAttributedString?, expectedString: String, highlight: NSRange?) {
        guard let source = source else {
            XCTFail("Should have value")
            return
        }

        if let highlight = highlight {
            let expectations: [NSRange: XCTestExpectation] = [highlight: expectation(description: expectedString)]
            let range = NSRange(location: 0, length: source.length)
            source.enumerateAttribute(.backgroundColor, in: range) { value, highlightedRange, _ in
                guard let color = value as? UIColor, color.rrggbbaa == "FFB84DFF" else { return }
                guard let expectation = expectations[highlightedRange] else {
                    XCTFail("Unexpected range highlighted: \(highlightedRange).")
                    return
                }
                expectation.fulfill()
            }
        }

        XCTAssertEqual(source.string, expectedString)
    }

    func testBasicData() {
        XCTAssertEqual(sut.initials, "P")
        checkHighlight(source: sut.senderEmail, expectedString: "contact@protonmail.ch", highlight: NSRange(location: 0, length: 7))
        XCTAssertEqual(sut.time, "May 02, 2018")
        if #available(iOS 17.0, *) {
            XCTAssertEqual(sut.date, "May 2, 2018 at 4:43:19 PM")
        } else {
            XCTAssertEqual(sut.date, "May 2, 2018 at 4:43:19 PM")
        }
        XCTAssertEqual(sut.originFolderTitle(isExpanded: false), "Inbox")
        XCTAssertEqual(sut.size, "2 KB")
        checkHighlight(source: sut.simpleRecipient, expectedString: "cc name, feng88@proton.me", highlight: NSRange(location: 9, length: 4))

        let toList = sut.toData
        XCTAssertEqual(toList?.title, "To:")
        XCTAssertEqual(toList?.recipients.count, 1)
        checkHighlight(source: toList?.recipients.first?.name, expectedString: "feng88@proton.me", highlight: NSRange(location: 0, length: 4))

        let ccList = sut.ccData
        XCTAssertEqual(ccList?.title, "Cc:")
        XCTAssertEqual(ccList?.recipients.count, 1)
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testPGPChecker_keysAPIFailedAndNoAddressKeys_failsVerification() async throws {
        apiMock.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/keys") {
                completion(nil, .success(["Code": 33101, "Error": "Server failed validation"]))
            } else if path == AddressesAPI.path {
                completion(nil, .success([:]))
            } else {
                XCTFail("Unexpected path: \(path)")
                completion(nil, .failure(NSError.badResponse()))
            }
        }
        user.addresses.removeAll()

        sut.initialize()

        waitForMessageToBePrepared()

        XCTAssertEqual(delegateObject.providerHasChangedStub.callCounter, 1)

        let checkedSenderContact = try XCTUnwrap(sut.checkedSenderContact)
        let encryptionIconStatus = try XCTUnwrap(checkedSenderContact.encryptionIconStatus)
        XCTAssertEqual(encryptionIconStatus.text, "Sender Verification Failed")
    }

    func testMIMEDecrypt() throws {
        let expectation1 = expectation(description: "decrypt body test")
        expectation1.expectedFulfillmentCount = 3

        sut.initialize()

        delegateObject.contentUpdate.bodyIs { _, _ in
            expectation1.fulfill()
        }
        delegateObject.attachmentsUpdate.bodyIs { _ in
            expectation1.fulfill()
        }
        waitForExpectations(timeout: 3) { error in
            XCTAssertNil(error)
        }
        XCTAssertEqual(sut.inlineAttachments?.count, 0)
        XCTAssertEqual(sut.nonInlineAttachments.count, 3)
        XCTAssertEqual(sut.mimeAttachments.count, 2)
        XCTAssertNotNil(sut.contents)
    }

    func testMessageDecrypter_whenMessageBodyChanges_isCalled() async throws {
        XCTAssertEqual(messageDecrypter.decryptCallCount, 0)

        sut.initialize()
        waitForMessageToBePrepared()
        XCTAssertEqual(messageDecrypter.decryptCallCount, 1)

        simulateMessageUpdateWithSameBodyAsBefore()
        waitForMessageToBePrepared()
        XCTAssertEqual(messageDecrypter.decryptCallCount, 1)

        try simulateMessageUpdateWithBodyDifferentThanBefore()
        waitForMessageToBePrepared()
        XCTAssertEqual(messageDecrypter.decryptCallCount, 2)
    }

    func testMessageDecrypter_whenSettingAreChanged_isNotCalled() async throws {
        sut.initialize()
        waitForMessageToBePrepared()
        XCTAssertEqual(messageDecrypter.decryptCallCount, 1)

        XCTAssertNotEqual(sut.remoteContentPolicy, .allowed)
        sut.remoteContentPolicy = .allowed
        waitForMessageToBePrepared()

        XCTAssertNotEqual(sut.embeddedContentPolicy, .allowed)
        sut.embeddedContentPolicy = .allowed
        waitForMessageToBePrepared()

        XCTAssertNotEqual(sut.displayMode, .expanded)
        sut.displayMode = .expanded
        waitForMessageToBePrepared()

        XCTAssertEqual(messageDecrypter.decryptCallCount, 1)
    }

    func testImageProxy_whenSettingsOtherThanRemoteContentAreChanged_isNotCalled() async throws {
        enableImageProxyAndRemoteContent()

        XCTAssertNotEqual(sut.embeddedContentPolicy, .allowed)
        sut.embeddedContentPolicy = .allowed
        waitForMessageToBePrepared()

        XCTAssertNotEqual(sut.displayMode, .expanded)
        sut.displayMode = .expanded
        waitForMessageToBePrepared()

        XCTAssertEqual(messageDecrypter.decryptCallCount, 1)
    }

    func testInit_withSentMessage_remoteContentPolicyIsAllowedAll() {
        let message = MessageEntity.make(labels: [.make(labelID: Message.Location.sent.labelID)])
        user.userInfo.hideRemoteImages = 0

        sut = MessageInfoProvider(
            message: message,
            messageDecrypter: messageDecrypter,
            systemUpTime: systemUpTime,
            labelID: labelID,
            dependencies: userContainer,
            highlightedKeywords: []
        )

        XCTAssertEqual(sut.remoteContentPolicy, .allowedAll)
    }

    func testSetRemoteContentPolicy_toAllowAll_shouldShowImageProxyFailedBannerWillBeFalse() {
        sut.shouldShowImageProxyFailedBanner = true

        sut.set(policy: .allowedAll)

        XCTAssertFalse(sut.shouldShowImageProxyFailedBanner)
    }

    func testReloadImagesWithoutProtection_remoteContentWillBeSetToAllowAll() {
        XCTAssertNotEqual(sut.remoteContentPolicy, .allowedAll)

        sut.reloadImagesWithoutProtection()

        XCTAssertEqual(sut.remoteContentPolicy, .allowedAll)
    }

    func testFetchSenderImageIfNeeded_featureFlagIsOff_getNil() {
        user.mailSettings = .init(hideSenderImages: false)
        let e = expectation(description: "Closure is called")

        sut.fetchSenderImageIfNeeded(isDarkMode: Bool.random(),
                                     scale: 1.0) { result in
            XCTAssertNil(result)
            e.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(apiMock.requestJSONStub.wasNotCalled)
    }

    func testFetchSenderImageIfNeeded_hideSenderImageInMailSettingTrue_getNil() {
        user.mailSettings = .init(hideSenderImages: true)
        featureFlagCache.featureFlagsStub.bodyIs { _, _ in
            SupportedFeatureFlags(rawValues: [FeatureFlagKey.senderImage.rawValue: true])
        }
        let e = expectation(description: "Closure is called")

        sut.fetchSenderImageIfNeeded(isDarkMode: Bool.random(),
                                     scale: 1.0) { result in
            XCTAssertNil(result)
            e.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(apiMock.requestJSONStub.wasNotCalled)
    }

    func testFetchSenderImageIfNeeded_msgHasNoSenderThatIsEligible_getNil() {
        user.mailSettings = .init(hideSenderImages: false)
        featureFlagCache.featureFlagsStub.bodyIs { _, _ in
            SupportedFeatureFlags(rawValues: [FeatureFlagKey.senderImage.rawValue: true])
        }
        let e = expectation(description: "Closure is called")

        sut.fetchSenderImageIfNeeded(isDarkMode: Bool.random(),
                                     scale: 1.0) { result in
            XCTAssertNil(result)
            e.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(apiMock.requestJSONStub.wasNotCalled)
    }

    func testFetchSenderImageIfNeeded_msgHasEligibleSender_getImageData() {
        user.mailSettings = .init(hideSenderImages: false)
        featureFlagCache.featureFlagsStub.bodyIs { _, _ in
            SupportedFeatureFlags(rawValues: [FeatureFlagKey.senderImage.rawValue: true])
        }
        let e = expectation(description: "Closure is called")
        let msg = MessageEntity.createSenderImageEligibleMessage()
        sut.update(message: msg)
        let imageData = UIImage(named: "mail_attachment_audio")?.pngData()
        apiMock.downloadStub.bodyIs { _, _, fileUrl, _, _, _, _, _, _, completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                try? imageData?.write(to: fileUrl)
                let response = HTTPURLResponse(statusCode: 200)
                completion(response, nil, nil)
            }
        }

        sut.fetchSenderImageIfNeeded(isDarkMode: Bool.random(),
                                     scale: 1.0) { result in
            XCTAssertNotNil(result)
            e.fulfill()
        }

        waitForExpectations(timeout: 2)

        XCTAssertTrue(apiMock.downloadStub.wasCalledExactlyOnce)
    }

    func testSetMessage_updateAttachmentDelegateIsTriggered() {
        let msg = MessageEntity.createSenderImageEligibleMessage()
        sut.update(message: msg)

        wait(self.delegateObject.attachmentsUpdate.wasCalledExactlyOnce == true)
    }
}

extension MessageInfoProviderTest {
    static func prepareEncryptedMessage(
        plaintextBody: String,
        mimeType: Message.MimeType,
        user: UserManager
    ) throws -> MessageEntity {
        let encryptedBody = try Encryptor.encrypt(
            publicKey: user.userInfo.addressKeys.toArmoredPrivateKeys[0],
            cleartext: plaintextBody
        ).value

        let parsedObject = testMessageDetailData.parseObjectAny()!
        let testContext = MockCoreDataStore.testPersistentContainer.newBackgroundContext()

        return try testContext.performAndWait {
             let messageObject = try XCTUnwrap(
                GRTJSONSerialization.object(
                    withEntityName: "Message",
                    fromJSONDictionary: parsedObject,
                    in: testContext
                ) as? Message
            )
            messageObject.userID = "userID"
            messageObject.isDetailDownloaded = true
            messageObject.body = encryptedBody
            messageObject.mimeType = mimeType.rawValue
            return MessageEntity(messageObject)
        }
    }

    /// This method is needed because most of the related code runs on a background queue
    private func waitForMessageToBePrepared() {
        Thread.sleep(forTimeInterval: 0.1)
    }

    private func simulateMessageUpdateWithSameBodyAsBefore() {
        let identicalMessage: MessageEntity = message
        sut.update(message: identicalMessage)
    }

    private func simulateMessageUpdateWithBodyDifferentThanBefore() throws {
        let differentMessage = try Self.prepareEncryptedMessage(
            plaintextBody: String.randomString(500),
            mimeType: .textPlain,
            user: user
        )
        sut.update(message: differentMessage)
    }

    private func enableImageProxyAndRemoteContent() {
        user.userInfo.imageProxy = .imageProxy
        sut.remoteContentPolicy = .allowed
        waitForMessageToBePrepared()
    }
}

final private class ProviderDelegate: MessageInfoProviderDelegate {

    @FuncStub(ProviderDelegate.providerHasChanged) var providerHasChangedStub
    func providerHasChanged() {
        providerHasChangedStub()
    }

    func hideDecryptionErrorBanner() {

    }

    func showDecryptionErrorBanner() {

    }

    func updateBannerStatus() {

    }

    @FuncStub(update(content:)) var contentUpdate
    func update(content: WebContents?) {
        contentUpdate(content)
    }

    func update(hasStrippedVersion: Bool) {

    }

    func update(renderStyle: MessageRenderStyle) {

    }

    func sendDarkModeMetric(isApply: Bool) {

    }

    @FuncStub(updateAttachments) var attachmentsUpdate
    func updateAttachments() {
        attachmentsUpdate()
    }

    @FuncStub(trackerProtectionSummaryChanged) var trackerProtectionSummaryChangedStub
    func trackerProtectionSummaryChanged() {
        trackerProtectionSummaryChangedStub()
    }
}
