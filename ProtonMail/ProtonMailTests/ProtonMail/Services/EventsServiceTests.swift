// Copyright (c) 2023 Proton Technologies AG
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

import CoreData
import Foundation
@testable import ProtonMail
import ProtonCore_TestingToolkit
import XCTest

final class EventsServiceTests: XCTestCase {
    private var sut: EventsService!
    private var mockApiService: APIServiceMock!
    private var mockUserManager: UserManager!
    private var mockContactCache: MockContactCacheStatusProtocol!
    private var mockFetchMessageMetaData: FetchMessageMetaDataUseCase!
    private var mockContactCacheStatus: ContactCacheStatusProtocol!
    private var mockContextProvider: CoreDataContextProviderProtocol!
    private let dummyUserID = "dummyUserID"
    private let timeout = 3.0

    override func setUp() {
        mockApiService = APIServiceMock()
        mockUserManager = makeUserManager(apiMock: mockApiService)
        mockContactCache = MockContactCacheStatusProtocol()
        mockFetchMessageMetaData = MockFetchMessageMetaData()
        mockContactCacheStatus = MockContactCacheStatusProtocol()
        mockContextProvider = MockCoreDataContextProvider()
        let incomingDefaultService = IncomingDefaultService(
            dependencies: .init(
                apiService: mockApiService,
                contextProvider: mockContextProvider,
                userInfo: mockUserManager.userInfo
            )
        )
        let dependencies = EventsService.Dependencies(
            contactCacheStatus: mockContactCacheStatus,
            coreDataProvider: mockContextProvider,
            featureFlagCache: MockFeatureFlagCache(),
            fetchMessageMetaData: mockFetchMessageMetaData,
            incomingDefaultService: incomingDefaultService,
            queueManager: MockQueueManager()
        )
        sut = EventsService(userManager: mockUserManager, dependencies: dependencies)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        mockApiService = nil
        mockUserManager = nil
        mockContactCache = nil
        mockFetchMessageMetaData = nil
        mockContactCacheStatus = nil
        mockContextProvider = nil
    }

    func testFetchEvents_whenNewIncomingDefault_itSucceedsSavingIt() throws {
        let objectId = String.randomString(32)
        let objectEmail = "dummy@example.com"
        let objectTime: TimeInterval = 1678721296
        let objectLocation = "14"
        mockApiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/events") {
                let result = self.newBlockedSenderEventJson(
                    id: objectId,
                    email: objectEmail,
                    time: objectTime,
                    location: objectLocation
                ).toDictionary()!
                completion(nil, .success(result))
            }
        }

       let expectation = expectation(description: "")
        sut.start() // needed to set the correct sut status
        sut.fetchEvents(byLabel: LabelID(rawValue: "anylabel"), notificationMessageID: nil) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)

        try mockContextProvider.read { context in
            let fetchRequest = NSFetchRequest<IncomingDefault>(entityName: IncomingDefault.entity().name!)
            let incomingDefaults = try context.fetch(fetchRequest)
            XCTAssertEqual(incomingDefaults.count, 1)
            let matchingStoredObject: IncomingDefault = try XCTUnwrap(incomingDefaults.first { $0.id == objectId })
            XCTAssertEqual(matchingStoredObject.email, objectEmail)
            XCTAssertEqual(matchingStoredObject.location, objectLocation)
            XCTAssertEqual(matchingStoredObject.time.timeIntervalSince1970, objectTime)
            XCTAssertEqual(matchingStoredObject.userID, dummyUserID)
        }
    }

    func testFetchEvents_whenNewIncomingDefaultForRemovedBlockedSender_itSucceedsRemovingIt() {
        let incomingDefaultId = String.randomString(32)
        mockContextProvider.enqueueOnRootSavingContext { context in
            let incomingDefault = IncomingDefault(context: context)
            incomingDefault.userID = self.dummyUserID
            incomingDefault.id = incomingDefaultId
            incomingDefault.email = String.randomString(15)
            incomingDefault.location = "14"
            incomingDefault.time = Date()
            _ = context.saveUpstreamIfNeeded()
        }
        mockApiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/events") {
                let result = self.removedBlockedSenderEventJson(id: incomingDefaultId).toDictionary()!
                completion(nil, .success(result))
            }
        }

        let expectation = expectation(description: "")
        sut.start() // needed to set the correct sut status
        sut.fetchEvents(byLabel: LabelID(rawValue: "anylabel"), notificationMessageID: nil) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)

        try! mockContextProvider.read { context in
            let fetchRequest = NSFetchRequest<IncomingDefault>(entityName: IncomingDefault.entity().name!)
            let incomingDefaults = try context.fetch(fetchRequest)
            XCTAssertEqual(incomingDefaults.count, 0)
        }
    }

    func testFetchEvents_whenNewIncomingDefaultForBlockedSenderMovedToSpam_itSucceedsUpdatingIt() {
        let incomingDefaultId = String.randomString(32)
        let imcomingDefaultEmail = "random@example.com"
        mockContextProvider.enqueueOnRootSavingContext { context in
            let incomingDefault = IncomingDefault(context: context)
            incomingDefault.userID = self.dummyUserID
            incomingDefault.id = incomingDefaultId
            incomingDefault.email = imcomingDefaultEmail
            incomingDefault.location = "\(IncomingDefaultsAPI.Location.blocked.rawValue)"
            incomingDefault.time = Date.distantPast
            _ = context.saveUpstreamIfNeeded()
        }
        mockApiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/events") {
                let result = self.movedBlockedSenderToSpamEventJson(
                    id: incomingDefaultId,
                    email: imcomingDefaultEmail
                ).toDictionary()!
                completion(nil, .success(result))
            }
        }

        let expectation = expectation(description: "")
        sut.start() // needed to set the correct sut status
        sut.fetchEvents(byLabel: LabelID(rawValue: "anylabel"), notificationMessageID: nil) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)

        try! mockContextProvider.read { context in
            let fetchRequest = NSFetchRequest<IncomingDefault>(entityName: IncomingDefault.entity().name!)
            let incomingDefaults = try context.fetch(fetchRequest)
            XCTAssertEqual(incomingDefaults.count, 1)
            let matchingStoredObject: IncomingDefault = try XCTUnwrap(incomingDefaults.first {
                $0.id == incomingDefaultId
            })
            XCTAssertEqual(matchingStoredObject.location, "\(IncomingDefaultsAPI.Location.spam.rawValue)")
        }
    }

    func testFetchEvents_whenNewMessageConversationInsert_itSucceedsSavingToCacheAndUpdateUnreadCount() throws {
        let msgID = String.randomString(20)
        let conversationID = String.randomString(20)
        mockContextProvider.enqueueOnRootSavingContext { context in
            let msgCount = LabelUpdate.newLabelUpdate(
                by: "0",
                userID: self.mockUserManager.userID.rawValue,
                inManagedObjectContext: context
            )
            msgCount.unread = 0
            msgCount.total = 0
            let conversationCount = ConversationCount.newConversationCount(
                by: "0",
                userID: self.mockUserManager.userID.rawValue,
                inManagedObjectContext: context
            )
            conversationCount.unread = 0
            conversationCount.total = 0
            _ = context.saveUpstreamIfNeeded()
        }
        mockApiService.requestJSONStub.bodyIs { _, _, path, _, _, _, _, _, _, _, _, completion in
            if path.contains("/events") {
                let result = self.newMessageEventJson(msgID: msgID, conversationID: conversationID).toDictionary()!
                completion(nil, .success(result))
            }
        }
        let expectation = expectation(description: "")
        sut.start() // needed to set the correct sut status

        sut.fetchEvents(byLabel: LabelID(rawValue: "0"), notificationMessageID: nil) { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)
        mockContextProvider.read { context in
            let msgCount = LabelUpdate.lastUpdate(
                by: "0",
                userID: mockUserManager.userID.rawValue,
                inManagedObjectContext: context
            )
            XCTAssertEqual(msgCount?.unread, 1)
            XCTAssertEqual(msgCount?.total, 1)

            let conversationCount = ConversationCount.lastContextUpdate(
                by: "0",
                userID: mockUserManager.userID.rawValue,
                inManagedObjectContext: context
            )
            XCTAssertEqual(conversationCount?.unread, 1)
            XCTAssertEqual(conversationCount?.total, 1)

            let message = Message.messageForMessageID(msgID, inManagedObjectContext: context)
            XCTAssertEqual(message?.messageID, msgID)

            let conversation = Conversation.conversationForConversationID(conversationID, inManagedObjectContext: context)
            XCTAssertEqual(conversation?.conversationID, conversationID)
        }
    }
}

extension EventsServiceTests {

    private func makeUserManager(apiMock: APIServiceMock) -> UserManager {
        let user = UserManager(api: apiMock, role: .member)
        user.userInfo.userId = dummyUserID
        return user
    }
}

extension EventsServiceTests {

    private func newBlockedSenderEventJson(id: String, email: String, time: TimeInterval, location: String) -> String {
        return """
        {
          "Code": 1000,
          "EventID": "1XyDltMaDjGe0ss_Ww5XwyuC9GEzMtMXOVkHFsapuODZLJ_tlm8NxPp2mtNN5Wli6bQCt84UylUHHpZQDROrvg==",
          "Refresh": 0,
          "More": 0,
          "IncomingDefaults": [
            {
              "ID": "\(id)",
              "Action": 1,
              "IncomingDefault": {
                "ID": "\(id)",
                "Location": \(location),
                "Type": 1,
                "Time": \(time),
                "Email": "\(email)"
              }
            }
          ],
          "Pushes": [],
          "Notices": []
        }
        """
    }

    private func removedBlockedSenderEventJson(id: String) -> String {
        return """
        {
          "Code": 1000,
          "EventID": "fVWF9HoEza6cSK75iJRrXH6bYhTgPEvijpkJS7qnAKi8_dMNVLvNmxc0_AsXwYiwrr7bKqCWGh2TgG51OpDVFQ==",
          "Refresh": 0,
          "More": 0,
          "IncomingDefaults": [
            {
              "ID": "\(id)",
              "Action": 0
            }
          ],
          "Pushes": [],
          "Notices": []
        }
        """
    }

    private func movedBlockedSenderToSpamEventJson(id: String, email: String) -> String {
        return """
        {
          "Code": 1000,
          "EventID": "va8rKRAyI54YHXAWU_VoW4VhBnJEoQ-NLavt4osGrvH4Exrl8KAK4swHkhN6o-uWbxlZh-fZWFBZBhPbTLjTpA==",
          "Refresh": 0,
          "More": 0,
          "IncomingDefaults": [
            {
              "ID": "\(id)",
              "Action": 2,
              "IncomingDefault": {
                "ID": "\(id)",
                "Location": 4,
                "Type": 1,
                "Time": 1678723854,
                "Email": "\(email)"
              }
            }
          ],
          "Pushes": [],
          "Notices": []
        }
        """
    }

    private func newMessageEventJson(msgID: String, conversationID: String) -> String {
        return """
        {
        "Code": 1000,
        "EventID": "18b6FFRIALmOueW5PG0ovcXEk39TspB1hRh7cHRbPFA0sK6wYW412Zx5Qtpqp5WKpuMRdCoU0sC_w12lxcg==",
        "Refresh": 0,
        "More": 0,
        "Messages": [
        {
        "ID": "\(msgID)",
        "Action": 1,
        "Message": {
        "ID": "\(msgID)",
        "Order": 403162130546,
        "ConversationID": "\(conversationID)",
        "Subject": "Test",
        "Unread": 1,
        "Sender": {
          "Name": "name",
          "Address": "xxx@pm.me",
          "IsProton": 1,
          "DisplaySenderImage": 0,
          "BimiSelector": null,
          "IsSimpleLogin": 0
        },
        "SenderAddress": "xxx@pm.me",
        "SenderName": "name",
        "Flags": 8388609,
        "Type": 0,
        "IsEncrypted": 2,
        "IsReplied": 0,
        "IsRepliedAll": 0,
        "IsForwarded": 0,
        "IsProton": 0,
        "DisplaySenderImage": 0,
        "BimiSelector": null,
        "ToList": [
          {
            "Name": "x",
            "Address": "x@pm.me",
            "Group": "",
            "IsProton": 0
          }
        ],
        "CCList": [],
        "BCCList": [],
        "Time": 1681267870,
        "Size": 54679,
        "NumAttachments": 2,
        "ExpirationTime": 0,
        "AddressID": "bHFOgqlbPihTyo5_AQD1RXFn9Fdzg1gD13QlkDwMw1dzGWiyiM_rvkIMkZQJbHfzCX7n5j0w==",
        "ExternalID": "fa43-b1b0-e80f-e8afa9e55936@mail.com",
        "LabelIDs": [
          "0",
          "5"
        ],
        "AttachmentInfo": {
          "image/png": {
            "attachment": 2
          }
        }
        }
        }
        ],
        "Conversations": [
        {
        "ID": "\(conversationID)",
        "Action": 1,
        "Conversation": {
        "ID": "\(conversationID)",
        "Order": 402117746315,
        "Subject": "Dark Mode Email Test 931550",
        "Senders": [
          {
            "Name": "name",
            "Address": "xxx@pm.me",
            "IsProton": 1,
            "DisplaySenderImage": 0,
            "BimiSelector": null,
            "IsSimpleLogin": 0
          }
        ],
        "Recipients": [
          {
            "Name": "x",
            "Address": "x@pm.me",
            "IsProton": 0
          }
        ],
        "NumMessages": 1,
        "NumUnread": 1,
        "NumAttachments": 2,
        "ExpirationTime": 0,
        "Size": 54679,
        "IsProton": 0,
        "DisplaySenderImage": 0,
        "BimiSelector": null,
        "Labels": [
          {
            "ContextNumMessages": 1,
            "ContextNumUnread": 1,
            "ContextTime": 1681267870,
            "ContextSize": 54679,
            "ContextNumAttachments": 2,
            "ID": "0"
          },
          {
            "ContextNumMessages": 1,
            "ContextNumUnread": 1,
            "ContextTime": 1681267870,
            "ContextSize": 54679,
            "ContextNumAttachments": 2,
            "ID": "5"
          }
        ],
        "AttachmentInfo": {
          "image/png": {
            "attachment": 2
          }
        }
        }
        }
        ],
        "UsedSpace": 334091655,
        "Notices": []
        }
        """
    }
}
