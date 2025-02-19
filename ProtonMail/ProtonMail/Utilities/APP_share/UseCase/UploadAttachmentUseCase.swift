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

import Foundation
import ProtonCore_Crypto
import ProtonCore_Networking
import ProtonCore_Services
import class ProtonCore_DataModel.Key

protocol UploadAttachmentUseCase {
    func execute(attachmentURI: String) async throws
}

final class UploadAttachment: UploadAttachmentUseCase {
    let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func execute(attachmentURI: String) async throws {
        guard let attachment = try dependencies.messageDataService.getAttachmentEntity(for: attachmentURI) else {
            throw UploadAttachmentError.resourceDoesNotExist
        }

        let messageEntity = try dependencies.messageDataService.getMessageEntity(for: attachment.messageID)
        if isUploadingAttachment(attachment, duplicatedIn: messageEntity) {
            removeDuplicated(attachment: attachment, in: messageEntity)
            throw UploadAttachmentError.duplicatedUploading
        }

        do {
            let requestParams = try prepareUploadingParameters(attachment: attachment, message: messageEntity)
            let response = try await sendUploadingRequest(params: requestParams)
            dependencies.messageDataService.updateAttachment(by: response, attachmentObjectID: attachment.objectID)
        } catch {
            dependencies.messageDataService.removeAttachmentFromDB(objectIDs: [attachment.objectID])
            // Upload public key right before sending
            // Ignore any error from uploading public key
            if isPublicKey(name: attachment.name) { return }
            let error = error as NSError
            let uploadingErrors = [
                APIErrorCode.tooManyAttachments,
                APIErrorCode.accountStorageQuotaExceeded
            ]
            if !uploadingErrors.contains(error.code) {
                PMAssertionFailure(error)
            }
            NotificationCenter.default.post(
                name: .attachmentUploadFailed,
                object: nil,
                userInfo: ["code": error.code]
            )
            throw error
        }
    }

    // Scenario: upload attachment, kill app before receiving request response
    // Since the http request is handling by system even app is killed, the uploading still successful
    // But App didn't receive response, it will resume upload operation after re-launch
    private func isUploadingAttachment(_ attachment: AttachmentEntity, duplicatedIn message: MessageEntity) -> Bool {
        let attachments = message.attachments
        let matched = attachments.first(where: { attached in
            return attached.getContentID() == attachment.getContentID() && attached.id.rawValue != "0"
        })
        return matched != nil
    }

    private func removeDuplicated(attachment: AttachmentEntity, in message: MessageEntity) {
        let attachments = message.attachments
        let objectIDs = attachments
            .filter { $0.objectID == attachment.objectID }
            .map { $0.objectID }
        dependencies.messageDataService.removeAttachmentFromDB(objectIDs: objectIDs)
    }

    private func prepareUploadingParameters(
        attachment: AttachmentEntity,
        message: MessageEntity
    ) throws -> UploadingRequestParams {
        let params: [String: String] = [
            "Filename": attachment.name,
            "MIMEType": attachment.rawMimeType,
            "MessageID": message.messageID.rawValue,
            "ContentID": attachment.getContentID() ?? attachment.name,
            "Disposition": attachment.isInline ? "inline" : "attachment"
        ]
        let messageURI = message.objectID.rawValue.uriRepresentation().absoluteString
        guard let sendingData = dependencies.messageDataService.getMessageSendingData(for: messageURI) else {
            throw UploadAttachmentError.resourceDoesNotExist
        }
        guard
            let addressID = sendingData.cachedSenderAddress?.addressID ??
                sendingData.defaultSenderAddress?.addressID,
            let key = sendingData.cachedSenderAddress?.keys.first ??
                dependencies.user?.userInfo.getAddressKey(address_id: addressID),
            let passphrase = sendingData.cachedPassphrase ?? dependencies.user?.mailboxPassword,
            let userKeys = (sendingData.cachedUserInfo ?? dependencies.user?.userInfo)?.userPrivateKeys
        else {
            throw UploadAttachmentError.encryptionError
        }
        return .init(
            attachment: attachment,
            cachedAuthCredential: sendingData.cachedAuthCredential,
            key: key,
            params: params,
            passphrase: passphrase,
            userKeys: userKeys
        )
    }

    private func sendUploadingRequest(params: UploadingRequestParams) async throws -> UploadingResponse {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<UploadingResponse, Error>) in
            autoreleasepool {
                do {
                    guard
                        let (keyPacket, dataPacketURL) = try AttachmentCrypto.encrypt(
                            attachment: params.attachment,
                            with: params.key
                        )
                    else { throw UploadAttachmentError.encryptionError }

                    Crypto.freeGolangMem()
                    let signed = AttachmentCrypto.sign(
                        attachment: params.attachment,
                        key: params.key,
                        userKeys: params.userKeys,
                        passphrase: params.passphrase
                    )
                    dependencies.user?.apiService.uploadFromFile(
                        byPath: AttachmentAPI.path,
                        parameters: params.params,
                        keyPackets: keyPacket,
                        dataPacketSourceFileURL: dataPacketURL,
                        signature: signed,
                        headers: .empty,
                        authenticated: true,
                        customAuthCredential: params.cachedAuthCredential,
                        nonDefaultTimeout: nil,
                        retryPolicy: .background,
                        uploadProgress: nil,
                        jsonCompletion: { _, result in
                            switch result {
                            case .success(let dict):
                                continuation.resume(with: .success((dict, keyPacket)))
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            }
                        }
                    )
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        })
    }

    private func isPublicKey(name: String) -> Bool {
        // publicKey - \(email) - \(fingerprint).asc
        name.hasPrefix("publicKey") && name.hasSuffix(".asc")
    }
}

extension UploadAttachment {

    struct Dependencies {
        let messageDataService: MessageDataServiceProtocol
        weak var user: UserManager?
    }

    private struct UploadingRequestParams {
        let attachment: AttachmentEntity
        let cachedAuthCredential: AuthCredential?
        let key: Key
        let params: [String: String]
        let passphrase: Passphrase
        let userKeys: [ArmoredKey]
    }

    typealias UploadingResponse = (response: JSONDictionary, keyPacket: Data)

    enum UploadAttachmentError: Error {
        case resourceDoesNotExist
        case duplicatedUploading
        case encryptionError
    }
}
