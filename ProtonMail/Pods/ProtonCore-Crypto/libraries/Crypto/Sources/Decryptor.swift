//
//  Decryptor.swift
//  ProtonCore-Crypto - Created on 07/19/22.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import Foundation
import ProtonCore_CryptoGoInterface
import ProtonCore_DataModel

public enum Decryptor {
    
    /// decrypt armored message return string value
    /// - Parameters:
    ///   - decryptionKeys: decryption keys
    ///   - encrypted: encrypted armored message
    /// - Returns: clear text
    public static func decrypt(decryptionKeys: [DecryptionKey], encrypted: ArmoredMessage) throws -> String {
        return try Crypto().decrypt(decryptionKeys: decryptionKeys, encrypted: encrypted)
    }
    
    /// decrypt armored message return binary value
    /// - Parameters:
    ///   - decryptionKeys: decryption keys
    ///   - value: encrypted armored message
    /// - Returns: raw data
    public static func decrypt(decryptionKeys: [DecryptionKey], encrypted: ArmoredMessage) throws -> Data {
        return try Crypto().decrypt(decryptionKeys: decryptionKeys, encrypted: encrypted)
    }
    
    /// decrypt split packet
    /// - Parameters:
    ///   - decryptionKeys: decryption keys
    ///   - split: split packets
    /// - Returns: raw data
    public static func decrypt(decryptionKeys: [DecryptionKey], split: SplitPacket) throws -> Data {
        return try Crypto().decrypt(decryptionKeys: decryptionKeys, split: split)
    }
    
    public static func decryptSessionKey(decryptionKeys: [DecryptionKey], keyPacket: Data) throws -> SessionKey {
        return try Crypto().decryptSessionKey(decryptionKeys: decryptionKeys, keyPacket: keyPacket)
    }
    
    /// decrypt and verify with passed in verifierKeys
    /// - Parameters:
    ///   - decryptionKeys: keys used for decryption
    ///   - value: encrypted message
    ///   - verificationKeys: verifiers
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptAndVerify(decryptionKeys: [DecryptionKey], value: ArmoredMessage,
                                        verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedString {
        return try Crypto().decryptAndVerify(decryptionKeys: decryptionKeys,
                                             encrypted: value,
                                             verifications: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt and verify with passed in verifierKeys
    /// - Parameters:
    ///   - decryptionKeys: keys used for decryption
    ///   - value: encrypted message
    ///   - verificationKeys: verifiers
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptAndVerify(decryptionKeys: [DecryptionKey], value: ArmoredMessage,
                                        verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedData {
        return try Crypto().decryptAndVerify(decryptionKeys: decryptionKeys,
                                             encrypted: value,
                                             verifications: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt and verify with passed in verifierKeys
    /// - Parameters:
    ///   - decryptionKeys: keys used for decryption
    ///   - value: splited packet
    ///   - verificationKeys: verifiers
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptAndVerify(decryptionKeys: [DecryptionKey], value: SplitPacket,
                                        verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedString {
        
        return try Crypto().decryptAndVerify(decryptionKeys: decryptionKeys, split: value,
                                             verifications: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt and verify with passed in verifierKeys
    /// - Parameters:
    ///   - decryptionKeys: keys used for decryption
    ///   - value: splited packet
    ///   - verificationKeys: verifiers
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptAndVerify(decryptionKeys: [DecryptionKey], value: SplitPacket,
                                        verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedData {
        
        return try Crypto().decryptAndVerify(decryptionKeys: decryptionKeys, split: value,
                                             verifications: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt and verify with passed in verifierKeys
    /// - Parameters:
    ///   - decryptionKey: single key used for decryption
    ///   - value: splited packet
    ///   - verificationKeys: verifiers
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptAndVerify(decryptionKey: DecryptionKey, value: SplitPacket,
                                        verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedString {
        return try Crypto().decryptAndVerify(decryptionKeys: [decryptionKey], split: value,
                                             verifications: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt and verify with passed in verifierKeys
    /// - Parameters:
    ///   - decryptionKey: single key used for decryption
    ///   - value: encrypted message
    ///   - verificationKeys: verifiers
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptAndVerify(decryptionKey: DecryptionKey, value: ArmoredMessage,
                                        verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedString {
        return try Crypto().decryptAndVerify(decryptionKeys: [decryptionKey],
                                             encrypted: value,
                                             verifications: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt session key and verify the detached signature with passed in verifierKeys
    /// - Parameters:
    ///   - decryptionKey: single key used for decryption
    ///   - keyPacket: encrypted session key
    ///   - signature: detached signature on the session key
    ///   - verificationKeys: verifiers
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptAndVerify(decryptionKey: DecryptionKey, keyPacket: Data,
                                        signature: ArmoredSignature, verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedData {
        return try Crypto().decryptAndVerify(decryptionKey: decryptionKey,
                                             keyPacket: keyPacket, signature: signature,
                                             verificationKeys: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt address token and verify a detached signature with self
    /// - Parameters:
    ///   - decryptionKey: single key used for decryption
    ///   - addrToken: address token encrypted
    ///   - detachedSign: detached signature
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: plaintext address token
    public static func decryptAndVerify(decryptionKey: DecryptionKey, addrToken: ArmoredMessage,
                                        detachedSign: ArmoredSignature, verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedString {
        return try Crypto().decryptAndVerify(decryptionKey: decryptionKey,
                                             encrypted: addrToken, signature: detachedSign,
                                             verificationKeys: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    /// decrypt random passpharase and verify a detached signature with self
    /// - Parameters:
    ///   - decryptionKey: single key used for decryption
    ///   - encPasspharse:encryption passpharse
    ///   - detachedSign: detached signature
    ///   - verifyTime: optional time
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: passpharse
    public static func decryptAndVerify(decryptionKey: DecryptionKey, encPasspharse: ArmoredMessage,
                                        detachedSign: ArmoredSignature, verificationKeys: [ArmoredKey], verifyTime: Int64 = 0, verificationContext: VerificationContext? = nil) throws -> VerifiedString {
        return try Crypto().decryptAndVerify(decryptionKey: decryptionKey,
                                             encrypted: encPasspharse, signature: detachedSign,
                                             verificationKeys: verificationKeys, verifyTime: verifyTime, verificationContext: verificationContext)
    }
    
    // swiftlint:disable function_parameter_count
    /// decrypt a file using the streaming api and verify the signature
    /// - Parameters:
    ///   - encryptedFile: The file containing the encrypted data
    ///   - decryptedFile: The file in which the decrypted data is written
    ///   - decryptionKeys: list of keys used for decryption
    ///   - keyPacket: encrypted session key
    ///   - verificationKeys: verifiers
    ///   - signature: encrypted signature
    ///   - chunckSize: chunk size used to write to read from the streaming api
    ///   - removeClearTextFileIfAlreadyExist: if true, the destination file is first deleted if it already exists.
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    @available(*, deprecated, message: "Use version with correct encryptedSignature name and type.")
    public static func decryptStream(encryptedFile cyphertextUrl: URL,
                                     decryptedFile cleartextUrl: URL,
                                     decryptionKeys: [DecryptionKey],
                                     keyPacket: Data,
                                     verificationKeys: [ArmoredKey],
                                     signature: ArmoredSignature,
                                     chunckSize: Int,
                                     removeClearTextFileIfAlreadyExists: Bool = false,
                                     verificationContext: VerificationContext? = nil) throws
    {
        try Crypto().decryptStream(encryptedFile: cyphertextUrl, decryptedFile: cleartextUrl,
                                   decryptionKeys: decryptionKeys, keyPacket: keyPacket,
                                   verificationKeys: verificationKeys, encryptedSignature: ArmoredMessage(value: signature.value),
                                   chunckSize: chunckSize, removeClearTextFileIfAlreadyExists: removeClearTextFileIfAlreadyExists, verificationContext: verificationContext)
    }
    
    // swiftlint:disable function_parameter_count
    /// decrypt a file using the streaming api and verify the signature
    /// - Parameters:
    ///   - encryptedFile: The file containing the encrypted data
    ///   - decryptedFile: The file in which the decrypted data is written
    ///   - decryptionKeys: list of keys used for decryption
    ///   - keyPacket: encrypted session key
    ///   - verificationKeys: verifiers
    ///   - enryptedSignature: encrypted signature
    ///   - chunckSize: chunk size used to write to read from the streaming api
    ///   - removeClearTextFileIfAlreadyExist: if true, the destination file is first deleted if it already exists.
    ///   - verificationContext: optional context, which can be used to enforce the signature was created with the right context.
    /// - Returns: verifiedString object. contains error if any
    public static func decryptStream(encryptedFile cyphertextUrl: URL,
                                     decryptedFile cleartextUrl: URL,
                                     decryptionKeys: [DecryptionKey],
                                     keyPacket: Data,
                                     verificationKeys: [ArmoredKey],
                                     encryptedSignature: ArmoredMessage,
                                     chunckSize: Int,
                                     removeClearTextFileIfAlreadyExists: Bool = false,
                                     verificationContext: VerificationContext? = nil) throws
    {
        try Crypto().decryptStream(encryptedFile: cyphertextUrl, decryptedFile: cleartextUrl,
                                   decryptionKeys: decryptionKeys, keyPacket: keyPacket,
                                   verificationKeys: verificationKeys, encryptedSignature: encryptedSignature,
                                   chunckSize: chunckSize, removeClearTextFileIfAlreadyExists: removeClearTextFileIfAlreadyExists, verificationContext: verificationContext)
    }
    
    /// decrypt armored message with a token password. if the clear content is data type. need to expose a new interface or convert result back to data
    /// - Parameters:
    ///   - encrypted: armored message
    ///   - token: token
    /// - Returns: clear text
    public static func decrypt(encrypted: ArmoredMessage, token: TokenPassword) throws -> String {
        return try Crypto().decrypt(encrypted: encrypted, token: token)
    }
}
