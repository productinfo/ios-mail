//
//  PushNotificationService.swift
//  Proton Mail
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

import Foundation
import ProtonCore_Services
import UserNotifications

final class PushNotificationService: NSObject, Service, PushNotificationServiceProtocol {
    private let notificationActions: PushNotificationActionsHandler

    /// Pending actions because the app has been just launched and can't make a request yet
    private var deviceTokenRegistrationPendingUnlock: String?
    private var notificationActionPendingUnlock: PendingNotificationAction?
    private var notificationOptions: [AnyHashable: Any]?

    private var debounceTimer: Timer?
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.notificationActions = PushNotificationActionsHandler(
            dependencies: .init(lockCacheStatus: dependencies.lockCacheStatus)
        )
        self.dependencies = dependencies

        super.init()

        notificationActions.registerActions()

        let notificationsToObserve: [Notification.Name] = [
            .didSignIn,
            .didUnlock,
            .didSignOutLastAccount
        ]
        notificationsToObserve.forEach {
            dependencies.notificationCenter.addObserver(
                self,
                selector: #selector(didObserveNotification(notification:)),
                name: $0,
                object: nil
            )
        }
    }

    // MARK: - register for notifications
    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else {
                SystemLogger.log(message: "push notification authorization is not granted", category: .pushNotification)
                return
            }
            DispatchQueue.main.async {
                SystemLogger.log(
                    message: "Requesting system to register for remote notifications",
                    category: .pushNotification
                )
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func registerIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                self?.registerForRemoteNotifications()
            default:
                break
            }
        }
    }

    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: String) {
        guard dependencies.usersManager.hasUsers(), dependencies.unlockProvider.isUnlocked() else {
            deviceTokenRegistrationPendingUnlock = deviceToken
            return
        }
        // we avoid calling the device registration flow in a quick sequence with a delay
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.dependencies.pushEncryptionManager.registerDeviceForNotifications(deviceToken: deviceToken)
        }
    }

    // MARK: - launch options
    func setNotificationFrom(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let notificationKey = UIApplication.LaunchOptionsKey.remoteNotification
        guard
            let launchOption = launchOptions,
            let remoteNotification = launchOption[notificationKey] as? [AnyHashable: Any]
        else {
            return
        }
        notificationOptions = remoteNotification
    }

    func setNotification(
        _ notification: [AnyHashable: Any]?,
        fetchCompletionHandler completionHandler: @escaping () -> Void
    ) {
        notificationOptions = notification
        completionHandler()
    }

    func processCachedLaunchOptions() {
        if let options = notificationOptions {
            try? didReceiveRemoteNotification(options, completionHandler: {})
        }
    }

    func hasCachedNotificationOptions() -> Bool {
        notificationOptions != nil
    }
}

// MARK: - NotificationCenter observation

extension PushNotificationService {

    @objc
    private func didObserveNotification(notification: Notification) {
        switch notification.name {
        case .didSignIn:
            didSignInAccount()
        case .didUnlock:
            didUnlockApp()
        case .didSignOutLastAccount:
            didSignOutLastAccount()
        default:
            PMAssertionFailure("\(notification.name) not expected")
        }
    }

    private func didUnlockApp() {
        if let deviceToken = deviceTokenRegistrationPendingUnlock {
            deviceTokenRegistrationPendingUnlock = nil
            dependencies.pushEncryptionManager.registerDeviceForNotifications(deviceToken: deviceToken)
        }

        if let notificationAction = notificationActionPendingUnlock {
            notificationActionPendingUnlock = nil
            handleNotificationActionTask(notificationAction: notificationAction)
        }
    }

    private func didSignInAccount() {
        dependencies.pushEncryptionManager.registerDeviceAfterNewAccountSignIn()
    }

    private func didSignOutLastAccount() {
        dependencies.pushEncryptionManager.deleteAllCachedData()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // App opened tapping on a push notification
            handleRemoteNotification(response: response, completionHandler: completionHandler)
        } else if notificationActions.isKnown(action: response.actionIdentifier) {
            // User tapped on a push notification action
            handleNotificationAction(response: response, completionHandler: completionHandler)
        } else {
            completionHandler()
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let options: UNNotificationPresentationOptions = [.list, .banner, .sound]
        completionHandler(options)
    }
}

// MARK: - Handle remote notification
extension PushNotificationService {
    private func handleRemoteNotification(response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if dependencies.unlockProvider.isUnlocked() { // unlocked
            do {
                try didReceiveRemoteNotification(userInfo, completionHandler: completionHandler)
            } catch {
                setNotification(userInfo, fetchCompletionHandler: completionHandler)
            }
        } else if UIApplication.shared.applicationState == .inactive { // opened by push
            setNotification(userInfo, fetchCompletionHandler: completionHandler)
        } else {
            completionHandler()
        }
    }

    private func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        completionHandler: @escaping () -> Void
    ) throws {
        guard
            let payload = pushNotificationPayload(userInfo: userInfo),
            shouldHandleNotification(payload: payload)
        else {
            throw PushNotificationServiceError.userIsNotReady
        }
        notificationOptions = nil
        completionHandler()
        dependencies.navigationResolver.mapNotificationToDeepLink(payload) { [weak self] deeplink in
            self?.dependencies.notificationCenter.post(name: .switchView, object: deeplink)
        }
    }

    private func pushNotificationPayload(userInfo: [AnyHashable: Any]) -> PushNotificationPayload? {
        do {
            return try PushNotificationPayload(userInfo: userInfo)
        } catch {
            let message = "Fail parsing push payload. Error: \(String(describing: error))"
            SystemLogger.log(message: message, category: .pushNotification, isError: true)
            return nil
        }
    }

    private func shouldHandleNotification(payload: PushNotificationPayload) -> Bool {
        guard dependencies.usersManager.hasUsers() && dependencies.unlockProvider.isUnlocked() else {
            return false
        }
        return payload.isLocalNotification || (!payload.isLocalNotification && isUserManagerReady(payload: payload))
    }

    /// Given how the application logic sets up some services at launch time, when a push notification awakes the app, UserManager might
    /// not be set up yet, even with an authenticated user. This function is a patch to be sure UserManager is ready when the app has been
    /// launched by a remote notification being tapped by the user.
    private func isUserManagerReady(payload: PushNotificationPayload) -> Bool {
        guard let uid = payload.uid else { return false }
        return sharedServices.get(by: UsersManager.self).getUser(by: uid) != nil
    }
}

// MARK: - Handle notification action

extension PushNotificationService {
    private func handleNotificationAction(response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        let usersManager = sharedServices.get(by: UsersManager.self)
        let userInfo = response.notification.request.content.userInfo
        guard
            let sessionId = userInfo["UID"] as? String,
            let messageId = userInfo["messageId"] as? String
        else {
            SystemLogger.log(message: "Action info parameters not found", category: .pushNotification, isError: true)
            completionHandler()
            return
        }
        let notificationActionPayload = NotificationActionPayload(
            sessionId: sessionId,
            messageId: messageId,
            actionIdentifier: response.actionIdentifier
        )
        let pendingNotificationAction = PendingNotificationAction(
            payload: notificationActionPayload,
            completionHandler: completionHandler
        )
        guard !usersManager.users.isEmpty else {
            // This might mean the app is locked and not able to access
            // authenticated users info yet or that there are no users.
            if usersManager.hasUsers() {
                notificationActionPendingUnlock = pendingNotificationAction
                SystemLogger.log(message: "Action pending \(response.actionIdentifier)", category: .pushNotification)
            } else {
                completionHandler()
            }
            return
        }
        handleNotificationActionTask(notificationAction: pendingNotificationAction)
    }

    private func handleNotificationActionTask(notificationAction action: PendingNotificationAction) {
        let usersManager = sharedServices.get(by: UsersManager.self)
        guard let userId = usersManager.getUser(by: action.payload.sessionId)?.userID else {
            let message = "Action \(action.payload.actionIdentifier): User not found for specific session"
            SystemLogger.log(message: message, category: .pushNotification, isError: true)
            action.completionHandler()
            return
        }
        let completion = {
            DispatchQueue.main.async {
                action.completionHandler()
            }
        }
        notificationActions.handle(
            action: action.payload.actionIdentifier,
            userId: userId,
            messageId: action.payload.messageId,
            completion: completion
        )
    }
}

private extension PushNotificationService {

    struct PendingNotificationAction {
        let payload: NotificationActionPayload
        let completionHandler: () -> Void
    }

    struct NotificationActionPayload {
        let sessionId: String
        let messageId: String
        let actionIdentifier: String
    }

    enum Key {
        static let subscription = "pushNotificationSubscription"
    }

    enum PushNotificationServiceError: Error {
        case userIsNotReady
    }
}

extension PushNotificationService {
    struct Dependencies {
        let usersManager: UsersManagerProtocol
        let unlockProvider: UnlockProvider
        let pushEncryptionManager: PushEncryptionManagerProtocol
        let navigationResolver: PushNavigationResolver
        let lockCacheStatus: LockCacheStatus
        let notificationCenter: NotificationCenter

        init(
            usersManager: UsersManagerProtocol,
            unlockProvider: UnlockProvider,
            pushEncryptionManager: PushEncryptionManagerProtocol = PushEncryptionManager.shared,
            navigationResolver: PushNavigationResolver = PushNavigationResolver(dependencies: .init()),
            lockCacheStatus: LockCacheStatus,
            notificationCenter: NotificationCenter = NotificationCenter.default
        ) {
            self.usersManager = usersManager
            self.unlockProvider = unlockProvider
            self.pushEncryptionManager = pushEncryptionManager
            self.navigationResolver = navigationResolver
            self.lockCacheStatus = lockCacheStatus
            self.notificationCenter = notificationCenter
        }
    }
}
