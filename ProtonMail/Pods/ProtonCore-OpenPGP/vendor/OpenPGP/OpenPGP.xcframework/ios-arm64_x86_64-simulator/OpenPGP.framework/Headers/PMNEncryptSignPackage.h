// AUTOGENERATED FILE - DO NOT MODIFY!
// This file was generated by Djinni from open_pgp.djinni

#import <Foundation/Foundation.h>

@interface PMNEncryptSignPackage : NSObject
- (nonnull instancetype)initWithEncrypted:(nonnull NSString *)encrypted
                                signature:(nonnull NSString *)signature;
+ (nonnull instancetype)encryptSignPackageWithEncrypted:(nonnull NSString *)encrypted
                                              signature:(nonnull NSString *)signature;

@property (nonatomic, readonly, nonnull) NSString * encrypted;

@property (nonatomic, readonly, nonnull) NSString * signature;

@end
