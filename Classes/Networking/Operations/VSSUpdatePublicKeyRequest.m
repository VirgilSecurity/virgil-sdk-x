//
//  VSSUpdatePublicKeyRequest.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/13/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VSSUpdatePublicKeyRequest.h"
#import "VSSPublicKey.h"
#import "VSSKeysModelCommons.h"
#import <VirgilFrameworkiOS/NSObject+VSSUtils.h>

#import <VirgilCryptoiOS/VSSKeyPair.h>
#import <VirgilCryptoiOS/VSSSigner.h>

@interface VSSUpdatePublicKeyRequest ()

@property (nonatomic, strong, readwrite) VSSPublicKey * __nullable publicKey;
@property (nonatomic, strong) GUID * __nonnull publicKeyId;

@end

@implementation VSSUpdatePublicKeyRequest

@synthesize publicKey = _publicKey;
@synthesize publicKeyId = _publicKeyId;

#pragma mark - Lifecycle

- (instancetype)initWithBaseURL:(NSString *)url publicKeyId:(GUID *)pkId newKeyPair:(VSSKeyPair *)keyPair keyPassword:(NSString *)keyPassword {
    self = [super initWithBaseURL:url];
    if (self == nil) {
        return nil;
    }
    
    _publicKeyId = pkId;
    
    [self setRequestMethod:PUT];
    NSMutableDictionary *dto = [[NSMutableDictionary alloc] init];
    if (keyPair.publicKey != nil) {
        NSString *encodedPk = [keyPair.publicKey base64EncodedStringWithOptions:0];
        if (encodedPk != nil) {
            dto[kVSSKeysModelPublicKey] = encodedPk;
        }
    }
    
    if (keyPair.privateKey != nil) {
        NSData *toSign = [self.uuid dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        if (toSign != nil) {
            VSSSigner *signer = [[VSSSigner alloc] init];
            NSData *sign = [signer signData:toSign privateKey:keyPair.privateKey keyPassword:keyPassword];
            if (sign != nil) {
                NSString *encodedSign = [sign base64EncodedStringWithOptions:0];
                if (encodedSign != nil) {
                    dto[kVSSKeysModelUUIDSign] = encodedSign;
                }
            }
        }
    }
    [self setRequestBodyWithObject:dto useUUID:@YES];
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)url {
    return [self initWithBaseURL:url publicKeyId:@"" newKeyPair:[[VSSKeyPair alloc] init] keyPassword:nil];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [NSString stringWithFormat:@"public-key/%@", self.publicKeyId];
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    self.publicKey = [VSSPublicKey deserializeFrom:[candidate as:[NSDictionary class]]];
    if (![[self.publicKey isValid] boolValue]) {
        self.publicKey = nil;
        return [NSError errorWithDomain:kVSSKeysBaseRequestErrorDomain code:kVSSKeysBaseRequestErrorCode userInfo:@{ NSLocalizedDescriptionKey: @"Public key deserialization from the service response has been unsuccessful." }];
    }
    return nil;
}

@end
