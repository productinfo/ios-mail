//
//  APIService.swift
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

import CoreData
import ProtonCore_Authentication
import ProtonCore_Challenge
import ProtonCore_Environment
import ProtonCore_Log
import ProtonCore_Keymaker
import ProtonCore_Networking
import ProtonCore_Services

extension PMAPIService {

    private static var authManagerForUnauthorizedAPIService = AuthManagerForUnauthorizedAPIService(coreKeyMaker: sharedServices.get())

    static var unauthorized: PMAPIService = {
        PMAPIService.setupTrustIfNeeded()

        let unauthorized: PMAPIService
        if let initialSessionUID = authManagerForUnauthorizedAPIService.initialSessionUID {
            unauthorized = PMAPIService.createAPIService(
                environment: BackendConfiguration.shared.environment,
                sessionUID: initialSessionUID,
                challengeParametersProvider: .forAPIService(clientApp: .mail, challenge: PMChallenge())
            )
        } else {
            unauthorized = PMAPIService.createAPIServiceWithoutSession(
                environment: BackendConfiguration.shared.environment,
                challengeParametersProvider: .forAPIService(clientApp: .mail, challenge: PMChallenge())
            )
        }
        #if !APP_EXTENSION
        unauthorized.serviceDelegate = PMAPIService.ServiceDelegate.shared
        unauthorized.humanDelegate = HumanVerificationManager.shared.humanCheckHelper(apiService: unauthorized)
        unauthorized.forceUpgradeDelegate = ForceUpgradeManager.shared.forceUpgradeHelper
        #endif
        unauthorized.authDelegate = authManagerForUnauthorizedAPIService.authDelegateForUnauthorized
        return unauthorized
    }()

    static func setupTrustIfNeeded() {
//        #if DEBUG
//        PMAPIService.noTrustKit = true
//        #endif

        guard PMAPIService.trustKit == nil else { return }
        #if !APP_EXTENSION
        // For the extension, please check ShareExtensionEntry
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure(
                "\(UIApplication.shared.delegate.map { "\($0)" } ?? "null") is not an instance of AppDelegate!"
            )
            return
        }
        TrustKitWrapper.start(delegate: delegate)
        #endif
    }
}

final private class AuthManagerForUnauthorizedAPIService: AuthHelperDelegate {

    private let key = "Unauthenticated_session"

    let initialSessionUID: String?

    let authDelegateForUnauthorized: AuthHelper
    let coreKeyMaker: KeyMakerProtocol

    init(coreKeyMaker: KeyMakerProtocol) {
        self.coreKeyMaker = coreKeyMaker
        defer {
            let dispatchQueue = DispatchQueue(label: "me.proton.mail.queue.unauth-session-auth-helper-delegate")
            authDelegateForUnauthorized.setUpDelegate(self, callingItOn: .asyncExecutor(dispatchQueue: dispatchQueue))
        }

        guard let mainKey = coreKeyMaker.mainKey(by: RandomPinProtection.randomPin),
              let data = SharedCacheBase.getDefault()?.data(forKey: key) else {
            self.authDelegateForUnauthorized = AuthHelper()
            self.initialSessionUID = nil
            return
        }

        let authlocked = Locked<[AuthCredential]>(encryptedValue: data)

        guard let authCredential = try? authlocked.unlock(with: mainKey).first else {
            SharedCacheBase.getDefault().remove(forKey: key)
            self.authDelegateForUnauthorized = AuthHelper()
            self.initialSessionUID = nil
            return
        }

        self.authDelegateForUnauthorized = AuthHelper(authCredential: authCredential)
        self.initialSessionUID = authCredential.sessionID
    }

    func credentialsWereUpdated(authCredential: AuthCredential, credential _: Credential, for _: String) {
        guard let mainKey = coreKeyMaker.mainKey(by: RandomPinProtection.randomPin),
              let lockedAuth = try? Locked<[AuthCredential]>(clearValue: [authCredential], with: mainKey) else { return }
        SharedCacheBase.getDefault()?.setValue(lockedAuth.encryptedValue, forKey: key)
    }

    func sessionWasInvalidated(for _: String, isAuthenticatedSession: Bool) {
        SharedCacheBase.getDefault()?.remove(forKey: key)
    }
}

extension PMAPIService {
    final class ServiceDelegate: APIServiceDelegate {
        static let shared = ServiceDelegate()

        var appVersion: String {
            Constants.App.appVersion
        }

        var userAgent: String? {
            UserAgent.default.ua
        }

        var locale: String {
            LanguageManager().currentLanguageCode()
        }

        var additionalHeaders: [String : String]? {
            nil
        }

        func onUpdate(serverTime: Int64) {
            MailCrypto.updateTime(serverTime, processInfo: userCachedStatus)
        }

        func isReachable() -> Bool {
            InternetConnectionStatusProvider.shared.status.isConnected
        }

        func onDohTroubleshot() {
        }
    }
}
