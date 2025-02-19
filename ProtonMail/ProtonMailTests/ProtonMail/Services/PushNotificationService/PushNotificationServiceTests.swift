//
//  PushNotificationServiceTests.swift
//  ProtonMailTests - Created on 06/11/2018.
//
//
//  Copyright (c) 2019 Proton AG
//
//  This file is part of Proton Mail.
//
//  Proton Mail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Proton Mail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Proton Mail.  If not, see <https://www.gnu.org/licenses/>.

import XCTest
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_TestingToolkit
@testable import ProtonMail

final class PushNotificationServiceTests: XCTestCase {
    private var sut: PushNotificationService!

    private var mockPushEncryptionManager: MockPushEncryptionManagerProtocol!
    private var mockUsersManager: MockUsersManagerProtocol!
    private var mockUnlockProvider: MockUnlockProvider!
    private var mockNotificationCenter: NotificationCenter!
    private let dummyToken = "dummy_token"

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPushEncryptionManager = .init()
        mockNotificationCenter = .init()
        mockUsersManager = .init()
        mockUsersManager.hasUsersStub.bodyIs { _ in true }
        mockUnlockProvider = .init()
        mockUnlockProvider.isUnlockedStub.bodyIs { _ in true }
        let dependencies: PushNotificationService.Dependencies = .init(
            usersManager: mockUsersManager,
            unlockProvider: mockUnlockProvider,
            pushEncryptionManager: mockPushEncryptionManager,
            navigationResolver: PushNavigationResolver(dependencies: .init()),
            lockCacheStatus: MockLockCacheStatus(),
            notificationCenter: mockNotificationCenter
        )
        sut = PushNotificationService(dependencies: dependencies)
    }

    override func tearDown() {
        super.tearDown()
        mockPushEncryptionManager = nil
        mockNotificationCenter = nil
        mockUsersManager = nil
        mockUnlockProvider = nil
        sut = nil
    }

    func testDidRegisterForRemoteNotifications_itShouldCallPushEncryptionManager() {
        let expect = expectation(description: "wait for registration")
        mockPushEncryptionManager.registerDeviceForNotificationsStub.bodyIs { _, _ in
            expect.fulfill()
        }

        sut.didRegisterForRemoteNotifications(withDeviceToken: dummyToken)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockPushEncryptionManager.registerDeviceForNotificationsStub.callCounter, 1)
        XCTAssertEqual(mockPushEncryptionManager.registerDeviceForNotificationsStub.lastArguments?.a1, dummyToken)
    }

    func testDidRegisterForRemoteNotifications_whenMultipleCalls_itShouldOnlyCallPushEncryptionManagerOnce() {
        let expect = expectation(description: "wait for registration")
        mockPushEncryptionManager.registerDeviceForNotificationsStub.bodyIs { _, _ in
            expect.fulfill()
        }

        for _ in 1...3 {
            sut.didRegisterForRemoteNotifications(withDeviceToken: dummyToken)
        }

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockPushEncryptionManager.registerDeviceForNotificationsStub.callCounter, 1)
    }

    func testOnNotificationDidUnlock_whenNoPengingToken_itShouldNotCallPushEncryptionManagerToRegisterDeviceToken() {
        mockNotificationCenter.post(name: .didUnlock, object: nil)
        XCTAssertEqual(mockPushEncryptionManager.registerDeviceForNotificationsStub.callCounter, 0)
    }

    func testOnNotificationDidUnlock_whenPengingToken_itShouldCallPushEncryptionManagerToRegisterDeviceToken() {
        mockUsersManager.hasUsersStub.bodyIs { _ in false }
        sut.didRegisterForRemoteNotifications(withDeviceToken: dummyToken)
        mockNotificationCenter.post(name: .didUnlock, object: nil)

        XCTAssertEqual(mockPushEncryptionManager.registerDeviceForNotificationsStub.callCounter, 1)
    }

    func testOnNotificationDidSignIn_itShouldCallPushEncryptionManagerToRegisterDeviceToken() {
        mockNotificationCenter.post(name: .didSignIn, object: nil)
        XCTAssertEqual(mockPushEncryptionManager.registerDeviceAfterNewAccountSignInStub.callCounter, 1)
    }

    func testOnNotificationDidSignOutLastAccount_itShouldCallPushEncryptionManagerToDeleteData() {
        mockNotificationCenter.post(name: .didSignOutLastAccount, object: nil)
        XCTAssertEqual(mockPushEncryptionManager.deleteAllCachedDataStub.callCounter, 1)
    }
}

// MARK: - Mocks

extension PushNotificationServiceTests {
    typealias SubscriptionSettings = PushSubscriptionSettings
    typealias Completion = JSONCompletion
    
    class InMemorySaver<T: Codable>: Saver<T> {
        
        convenience init(store: StoreMock = StoreMock()) {
            self.init(key: "", store: store)
        }
    }
    
    class StoreMock: KeyValueStoreProvider {
        enum Errors: Error {
            case noData
        }
        private(set) var dict = [String: Any]()

        func set(_ intValue: Int, forKey key: String) { dict[key] = intValue }
        func set(_ data: Data, forKey key: String) { dict[key] = data }
        func set(_ value: Bool, forKey defaultName: String) { dict[defaultName] = value }

        func int(forKey key: String) -> Int? { return dict[key] as? Int }
        func bool(forKey defaultName: String) -> Bool { return dict[defaultName] as? Bool ?? false }
        func data(forKey key: String) -> Data? { return dict[key] as? Data }

        func remove(forKey key: String) { dict[key] = nil }

        func decodeData<D: Decodable>(_ type: D.Type, forKey key: String) throws -> D {
            guard let data = dict[key] as? Data else {
                throw Errors.noData
            }
            return try PropertyListDecoder().decode(type, from: data)
        }
    }
}
