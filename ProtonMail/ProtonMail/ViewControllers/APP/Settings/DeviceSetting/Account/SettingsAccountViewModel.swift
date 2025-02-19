//
//  SettingsViewModel.swift
//  Proton Mail - Created on 12/12/18.
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
import ProtonCore_DataModel
import ProtonCore_AccountDeletion

enum SettingAccountSection: Int, CustomStringConvertible {
    case account
    case addresses
    case snooze
    case mailbox
    case deleteAccount

    var description: String {
        switch self {
        case .account:
            return LocalString._account
        case .addresses:
            return LocalString._addresses
        case .snooze:
            return LocalString._snooze
        case .mailbox:
            return LocalString._mailbox
        case .deleteAccount:
            return ""
        }
    }
}

enum SettingsAccountItem: Int, CustomStringConvertible {
    case singlePassword
    case loginPassword
    case mailboxPassword
    case recovery
    case storage

    var description: String {
        switch self {
        case .singlePassword:
            return LocalString._single_password
        case .loginPassword:
            return LocalString._signin_password
        case .mailboxPassword:
            return LocalString._mailbox_password
        case .recovery:
            return LocalString._recovery_email
        case .storage:
            return LocalString._mailbox_storage
        }
    }
}

enum SettingsAddressItem: Int, CustomStringConvertible {
    case addr
    case displayName
    case signature
    case mobileSignature

    var description: String {
        switch self {
        case .addr:
            return LocalString._general_default
        case .displayName:
            return LocalString._settings_display_name_title
        case .signature:
            return LocalString._settings_signature_title
        case .mobileSignature:
            return LocalString._settings_mobile_signature_title
        }
    }
}

enum SettingsMailboxItem: Int, CustomStringConvertible, Equatable {
    case blockList
    case privacy
    case conversation
    case undoSend
    case labels
    case folders
    case storage
    case nextMsgAfterMove
    case autoDeleteSpamTrash

    var description: String {
        switch self {
        case .blockList:
            return L11n.BlockSender.blockListSettingsItem
        case .privacy:
            return LocalString._privacy
        case .conversation:
            return LocalString._conversation_settings_title
        case .undoSend:
            return LocalString._account_settings_undo_send_row_title
        case .labels:
            return LocalString._labels
        case .folders:
            return LocalString._folders
        case .storage:
            return LocalString._local_storage_limit
        case .nextMsgAfterMove:
            return L11n.NextMsgAfterMove.settingTitle
        case .autoDeleteSpamTrash:
            return L11n.AutoDeleteSettings.settingTitle
        }
    }
}

protocol SettingsAccountViewModel: AnyObject {
    var sections: [SettingAccountSection] { get }
    var accountItems: [SettingsAccountItem] { get }
    var addrItems: [SettingsAddressItem] { get }
    var mailboxItems: [SettingsMailboxItem] { get }

    var storageText: String { get }
    var recoveryEmail: String { get }

    var email: String { get }
    var displayName: String { get }

    var defaultSignatureStatus: String { get }
    var defaultMobileSignatureStatus: String { get }
    var allSendingAddresses: [Address] { get }

    var isAutoDeleteSpamAndTrashEnabled: Bool { get }
    var isPaidUser: Bool { get }
    func updateDefaultAddress(with address: Address, completion: ((NSError?) -> Void)?)

    var reloadTable: (() -> Void)? { get set }
}

class SettingsAccountViewModelImpl: SettingsAccountViewModel {
    let sections: [SettingAccountSection] = [ .account, .addresses, .mailbox, .deleteAccount]

    var accountItems: [SettingsAccountItem] {
        var items: [SettingsAccountItem]
        if userManager.userInfo.passwordMode == 1 {
            items = [.singlePassword]
        } else {
            items = [.loginPassword, .mailboxPassword]
        }

        items.append(contentsOf: [.recovery, .storage])

        return items
    }

    let addrItems: [SettingsAddressItem] = [.addr, .displayName, .signature, .mobileSignature]
    let mailboxItems: [SettingsMailboxItem]

    private let userManager: UserManager

    var reloadTable: (() -> Void)?

    init(user: UserManager) {
        self.userManager = user

        var mailboxItems: [SettingsMailboxItem] = [.privacy, .undoSend, .conversation, .labels, .folders]
        if UserInfo.isConversationSwipeEnabled {
            mailboxItems.append(.nextMsgAfterMove)
        }

        if UserInfo.isBlockSenderEnabled {
            mailboxItems.append(.blockList)
        }

        if UserInfo.isAutoDeleteEnabled {
            mailboxItems.append(.autoDeleteSpamTrash)
        }
 
        self.mailboxItems = mailboxItems
    }

    var storageText: String {
        get {
            let usedSpace = self.userManager.userInfo.usedSpace
            let maxSpace = self.userManager.userInfo.maxSpace
            let formattedUsedSpace = ByteCountFormatter.string(fromByteCount: Int64(usedSpace), countStyle: ByteCountFormatter.CountStyle.binary)
            let formattedMaxSpace = ByteCountFormatter.string(fromByteCount: Int64(maxSpace), countStyle: ByteCountFormatter.CountStyle.binary)

            return "\(formattedUsedSpace) / \(formattedMaxSpace)"
        }
    }

    var recoveryEmail: String {
        get {
            return self.userManager.userInfo.notificationEmail
        }
    }

    var email: String {
        get {
            return self.userManager.defaultEmail
        }

    }

    var displayName: String {
        get {
            return self.userManager.defaultDisplayName
        }
    }

    var defaultSignatureStatus: String {
        get {
            if self.userManager.defaultSignatureStatus {
                return LocalString._settings_On_title
            } else {
                return LocalString._settings_Off_title
            }
        }
    }

    var defaultMobileSignatureStatus: String {
        get {
            if self.userManager.showMobileSignature {
                return LocalString._settings_On_title
            } else {
                return LocalString._settings_Off_title
            }
        }
    }

    var allSendingAddresses: [Address] {
        let defaultAddress: Address? = userManager.addresses.defaultAddress()
        return userManager.addresses.filter { address in
            address.status.rawValue == 1 && address.receive.rawValue == 1 && address != defaultAddress
        }
    }

    var isAutoDeleteSpamAndTrashEnabled: Bool {
        userManager.isAutoDeleteEnabled
    }

    var isPaidUser: Bool {
        userManager.isPaid
    }

    func updateDefaultAddress(with address: Address, completion: ((NSError?) -> Void)?) {
        var newAddrs = [Address]()
        var newOrder = [String]()
        newAddrs.append(address)
        newOrder.append(address.addressID)
        var order = 1
        if let indexOfNewDefaultAddress = userManager.addresses.firstIndex(of: address) {
            userManager.addresses[indexOfNewDefaultAddress] = address.withUpdated(order: order)
        }
        order += 1
        let copyAddresses = userManager.addresses
        for index in copyAddresses.indices where userManager.addresses[index].addressID != address.addressID {
            newAddrs.append(userManager.addresses[index])
            newOrder.append(userManager.addresses[index].addressID)
            userManager.addresses[index] = userManager.addresses[index].withUpdated(order: order)
            order += 1
        }

        let service = userManager.userService
        service.updateUserDomiansOrder(auth: userManager.authCredential,
                                       user: userManager.userInfo,
                                       newAddrs,
                                       newOrder: newOrder) { error in
            if error == nil {
                self.userManager.save()
            }
            DispatchQueue.main.async {
                completion?(error)
            }
        }
    }
}
