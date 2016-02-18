//
//  VSSRequestExtended.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestExtended.h"
#import "VSSRequest_Private.h"
#import "VSSRequestContextExtended.h"

#import "VSSCard.h"
#import "VSSPublicKey.h"
#import "VSSPrivateKey.h"
#import "NSObject+VSSUtils.h"

@import VirgilFoundation;

@interface VSSRequestExtended ()

- (VSSRequestContextExtended * __nullable)extendedContext;

@end

@implementation VSSRequestExtended

#pragma mark - Private class logic

- (VSSRequestContextExtended *)extendedContext {
    return [self.context as:[VSSRequestContextExtended class]];
}

#pragma mark - Public class logic

- (NSError *)sign {
    if (self.extendedContext.uuid.length == 0 || self.extendedContext.privateKey.key.length == 0) {
        VSSRDLog(@"Impossible to compose authentication headers for the request: request uuid or/and private key is/are not given.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-100 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to compose authentication headers for the request: request uuid or/and private key is/are not given.", @"Authentication for the request is not possible.") }];
    }
    
    /// Compose NSData to sign:
    NSData *uuidData = [self.extendedContext.uuid dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if (uuidData.length == 0 || self.request.HTTPBody.length == 0) {
        VSSRDLog(@"There is nothing to sign: no request uuid and/or request body given.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-101 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"There is nothing to sign: no request uuid and/or request body given.", @"Sign for the request is not possible.") }];
    }
    NSMutableData *toSign = [[NSMutableData alloc] initWithData:uuidData];
    [toSign appendData:self.request.HTTPBody];
    
    // Sign request body with given key.
    VSSSigner *signer = [[VSSSigner alloc] init];
    NSData *signData = [signer signData:toSign privateKey:self.extendedContext.privateKey.key keyPassword:self.extendedContext.privateKey.password];
    if (signData.length == 0) {
        VSSRDLog(@"Unable to sign request data with context private key.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-102 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to sign the request with context private key.", @"Sign for the request has failed.") }];;
    }
    
    // Encode sign to base64
    NSString *encodedSign = [signData base64EncodedStringWithOptions:0];
    if (encodedSign.length == 0) {
        VSSRDLog(@"Unable to encode received sign into base64 format.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-103 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to encode sign data to base64 format.", @"Sign for request can not be encoded.") }];;
    }
    
    /// Here we need to setup authentication headers:
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithDictionary:@{ kVSSRequestIDHeader: self.extendedContext.uuid,
                                                                                      kVSSRequestSignHeader: encodedSign }];
    if (self.extendedContext.cardId.length > 0) {
        headers[kVSSRequestSignCardIDHeader] = self.extendedContext.cardId;
    }
    [self setRequestHeaders:headers];
    return nil;
}

- (NSError *)verify {
    if (self.extendedContext.serviceCard.publicKey.key.length == 0) {
        VSSRDLog(@"Impossible to verify the signature for the response: service's public key is not given.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-108 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to verify the signature for the response: service's public key is not given.", @"Signature verification is not possible.") }];
    }
    
    /// Get response headers for signature check:
    if (self.response.allHeaderFields.count == 0 || self.responseBody.length == 0) {
        VSSRDLog(@"Impossible to verify the signature for the response: there is no headers/response body present.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-109 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to verify the signature for the response: there is no headers/response present.", @"Signature verification is not possible.") }];
    }
    
    NSString *responseID = [self.response.allHeaderFields[kVSSResponseIDHeader] as:[NSString class]];
    NSString *base64Sign = [self.response.allHeaderFields[kVSSResponseSignHeader] as:[NSString class]];
    
    if (responseID.length == 0 || base64Sign.length == 0) {
        VSSRDLog(@"Impossible to verify the signature for the response: there is no response id and/or response signature.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-110 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to verify the signature for the response: there is no response id and/or response signature.", @"Signature verification is not possible.") }];
    }

    NSData *signatureData = [[NSData alloc] initWithBase64EncodedString:base64Sign options:0];
    NSData *responseIDData = [responseID dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if (signatureData.length == 0 || responseIDData.length == 0) {
        VSSRDLog(@"Impossible to verify the signature for the response: decoding base64 to actual signature data has failed.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-111 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to verify the signature for the response: decoding base64 to actual signature data has failed.", @"Signature verification is not possible.") }];
    }
    
    NSMutableData *signedData = [NSMutableData dataWithData:responseIDData];
    [signedData appendData:self.responseBody];
    
    VSSSigner *verifier = [[VSSSigner alloc] init];
    BOOL verified = [verifier verifySignature:signatureData data:signedData publicKey:self.extendedContext.serviceCard.publicKey.key];
    if (!verified) {
        VSSRDLog(@"Signature verification has failed.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-112 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Signature verification has failed.", @"Signature verification is not possible.") }];
    }
    
    return nil;
}

- (NSError *)encrypt {
    if (self.extendedContext.serviceCard.Id.length == 0 || self.extendedContext.serviceCard.publicKey.key.length == 0 || self.request.HTTPBody.length == 0) {
        VSSRDLog(@"Impossible to encrypt the request body for the request: request body or/and public key is/are not given.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-104 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to compose encrypted body for the request: request uuid or/and request body or/and private key is/are not given.", @"Encryption for the request is not possible.") }];
    }
    /// Encrypt the request body
    VSSCryptor *cryptor = [[VSSCryptor alloc] init];
    [cryptor addKeyRecepient:self.extendedContext.serviceCard.Id publicKey:self.extendedContext.serviceCard.publicKey.key];
    NSData *encryptedBody = [cryptor encryptData:self.request.HTTPBody embedContentInfo:@YES];
    if (encryptedBody.length == 0) {
        VSSRDLog(@"Encryption of the request body has failed.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-105 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Encryption of the request body has failed.", @"Encryption for the request has failed.") }];
    }
    
    /// Set request body to a proper encrypted and base64 encoded body.
    NSData *newBodyData = [encryptedBody base64EncodedDataWithOptions:0];
    if (newBodyData.length == 0) {
        VSSRDLog(@"Unable to convert encrypted request body into base64 encoded data.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-107 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to convert encrypted request body into base64 encoded data.", @"Request body can not be properly formed.") }];
    }
    
    [self setRequestBody:newBodyData];
    return nil;
}

- (NSError *)decrypt {
    if (self.extendedContext.password.length == 0 || self.responseBody.length == 0) {
        VSSRDLog(@"Impossible to decrypt the response body for the request: context password or/and response body is/are not given.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-113 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Impossible to decrypt the response body for the request: context password or/and response body is/are not given.", @"Response body decryption is not possible.") }];
    }
    
    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedData:self.responseBody options:0];
    if (encryptedData.length == 0) {
        VSSRDLog(@"Unable to decode the encrypted response body from base64 format.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-114 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to decode the encrypted response body from base64 format.", @"Response body can not be decoded.") }];
    }
    
    VSSCryptor *decryptor = [[VSSCryptor alloc] init];
    NSData *plainResponseData = [decryptor decryptData:encryptedData password:self.extendedContext.password];
    if (plainResponseData.length == 0) {
        VSSRDLog(@"Decryption of the response body has failed.");
        return [NSError errorWithDomain:kVSSRequestErrorDomain code:-115 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Decryption of the response body has failed.", @"Response body can not be decrypted.") }];
    }
    
    self.responseBody = plainResponseData;
    return nil;
}

@end
