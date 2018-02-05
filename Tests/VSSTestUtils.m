//
//  VSSTestUtils.m
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/29/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSTestUtils.h"

@implementation VSSTestUtils

- (instancetype __nonnull)initWithCrypto:(VSMVirgilCrypto *)crypto consts:(VSSTestsConst *)consts {
    self = [super init];
    if (self) {
        self.consts = consts;
        self.crypto = crypto;
    }
    return self;
}

- (VSSRawSignedModel *)instantiateRawSignedModelWithKeyPair:(VSMVirgilKeyPair *)keyPair identity:(NSString *)identity error:(NSError * __nullable * __nullable)errorPtr {
    
    VSMVirgilKeyPair *kp = keyPair != nil ? keyPair : [self.crypto generateKeyPairAndReturnError:errorPtr];
    NSString *idty = identity != nil ? identity : [[NSUUID alloc] init].UUIDString;
    
    NSData *exportedPublicKey = [self.crypto exportPublicKey: kp.publicKey];
    NSString *publicKeyBase64 = [exportedPublicKey base64EncodedStringWithOptions:0];
    
    VSSRawCardContent *content = [[VSSRawCardContent alloc] initWithIdentity:idty publicKey:publicKeyBase64 previousCardId:nil version:nil createdAt:NSDate.date];
    
    NSData *snapshot = [content snapshot];
    
    VSSRawSignedModel *rawCard = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot signatures:nil];
    
    VSMVirgilCardCrypto *cardCrypto = [[VSMVirgilCardCrypto alloc] initWithVirgilCrypto:self.crypto];
    VSSModelSigner *signer = [[VSSModelSigner alloc] initWithCrypto:cardCrypto];
    [signer selfSignWithModel:rawCard privateKey:keyPair.privateKey additionalData:nil error:errorPtr];

    return rawCard;
}

- (NSString * __nonnull)getTokenStringWithIdentity:(NSString * __nonnull)identity error:(NSError * __nullable * __nullable)errorPtr {
    VSMVirgilPrivateKeyExporter *exporter = [[VSMVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:self.crypto password:nil];
    NSData *privKey = [[NSData alloc] initWithBase64EncodedString:_consts.accessPrivateKeyBase64 options:0];
    VSMVirgilPrivateKey *privateKey = (VSMVirgilPrivateKey *)[exporter importPrivateKeyFrom:privKey error:errorPtr];
    
    VSMVirgilAccessTokenSigner *tokenSigner = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:self.crypto];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:self.consts.accessPublicKeyId accessTokenSigner:tokenSigner appId:self.consts.applicationId ttl:1000];
    
    VSSJwt *jwtToken = [generator generateTokenWithIdentity:identity additionalData:nil error:errorPtr];

    NSString *strToken = [jwtToken stringRepresentation];
    
    NSData *pubKey = [[NSData alloc] initWithBase64EncodedString:_consts.accessPublicKeyBase64 options:0];
    VSMVirgilPublicKey *key = [self.crypto importPublicKeyFrom:pubKey error:errorPtr];
    
    VSSJwtVerifier *verifier = [[VSSJwtVerifier alloc] initWithApiPublicKey:key apiPublicKeyIdentifier:_consts.accessPublicKeyId accessTokenSigner:tokenSigner];
    
    if ([verifier verifyTokenWithJwtToken:jwtToken] == false) {
        return nil;
    }
    
    return strToken;
}

- (id<VSSAccessToken> __nonnull)getTokenWithIdentity:(NSString * __nonnull)identity ttl:(NSTimeInterval)ttl error:(NSError * __nullable * __nullable)errorPtr {
    VSMVirgilPrivateKeyExporter *exporter = [[VSMVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:self.crypto password:nil];
    NSData *privKey = [[NSData alloc] initWithBase64EncodedString:_consts.accessPrivateKeyBase64 options:0];
    VSMVirgilPrivateKey *privateKey = (VSMVirgilPrivateKey *)[exporter importPrivateKeyFrom:privKey error:errorPtr];
    
    VSMVirgilAccessTokenSigner *tokenSigner = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:self.crypto];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:self.consts.accessPublicKeyId accessTokenSigner:tokenSigner appId:self.consts.applicationId ttl:ttl];
    
    VSSJwt *jwtToken = [generator generateTokenWithIdentity:identity additionalData:nil error:errorPtr];
    return jwtToken;
}

- (NSString * __nonnull)getTokenWithWrongPrivateKeyWithIdentity:(NSString * __nonnull)identity error:(NSError * __nullable * __nullable)errorPtr {
    VSMVirgilKeyPair *wrongKeyPair = [self.crypto generateKeyPairAndReturnError:errorPtr];
    VSMVirgilPrivateKey *privateKey = wrongKeyPair.privateKey;
    
    VSMVirgilAccessTokenSigner *tokenSigner = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:self.crypto];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:_consts.accessPublicKeyId accessTokenSigner:tokenSigner appId:_consts.applicationId ttl:1000];
    
    VSSJwt *jwtToken = [generator generateTokenWithIdentity:identity additionalData:nil error:errorPtr];
    
    NSString *strToken = [jwtToken stringRepresentation];
    
    return strToken;
}

-(VSSGeneratorJwtProvider * __nonnull)getGeneratorJwtProviderWithIdentity:(NSString *)identity error:(NSError * __nullable * __nullable)errorPtr {
    VSMVirgilPrivateKeyExporter *exporter = [[VSMVirgilPrivateKeyExporter alloc] initWithVirgilCrypto:_crypto password:nil];
    NSData *privKey = [[NSData alloc] initWithBase64EncodedString:_consts.accessPrivateKeyBase64 options:0];
    VSMVirgilPrivateKey *privateKey = (VSMVirgilPrivateKey *)[exporter importPrivateKeyFrom:privKey error:errorPtr];

    VSMVirgilAccessTokenSigner *tokenSigner = [[VSMVirgilAccessTokenSigner alloc] initWithVirgilCrypto:self.crypto];
    VSSJwtGenerator *generator = [[VSSJwtGenerator alloc] initWithApiKey:privateKey apiPublicKeyIdentifier:_consts.accessPublicKeyId accessTokenSigner:tokenSigner appId:_consts.applicationId ttl:1000];

    VSSGeneratorJwtProvider *generatorProvider = [[VSSGeneratorJwtProvider alloc] initWithJwtGenerator:generator defaultIdentity:identity additionalData:nil];

    return generatorProvider;
}

-(VSSRawSignature * __nullable)getSelfSignatureFromModel:(VSSRawSignedModel * __nonnull)rawCard {
    for (VSSRawSignature* signature in rawCard.signatures) {
        if ([signature.signer isEqualToString:@"self"]) {
            return signature;
        }
    }
    return nil;
}

-(VSSCardSignature * __nullable)getSelfSignatureFromCard:(VSSCard * __nonnull)card {
    for (VSSCardSignature* signature in card.signatures) {
        if ([signature.signer isEqualToString:@"self"]) {
            return signature;
        }
    }
    return nil;
}

-(NSData * __nonnull)getRandomData {
    int length = 2048;
    NSMutableData *data = [NSMutableData dataWithCapacity:length];
    for (unsigned int i = 0; i < length/4; ++i) {
        u_int32_t randomBits = arc4random();
        [data appendBytes:(void*)&randomBits length:4];
    }
    return data;
}

-(BOOL)isCardsEqualWithCard:(VSSCard * __nonnull)card1 and:(VSSCard * __nonnull)card2 {
    VSSCardSignature *selfSignature1 = [self getSelfSignatureFromCard:card1];
    VSSCardSignature *selfSignature2 = [self getSelfSignatureFromCard:card2];
    
    return ([card1.identifier isEqualToString: card2.identifier] &&
            [card1.identity isEqualToString: card2.identity] &&
            [card1.version isEqualToString: card2.version] &&
            card1.isOutdated == card2.isOutdated &&
            card1.createdAt == card2.createdAt &&
            ([card1.previousCardId isEqualToString: card2.previousCardId] || (card1.previousCardId == nil && card2.previousCardId == nil)) &&
            ([self isCardsEqualWithCard:card1.previousCard and:card2.previousCard] || (card1.previousCard   == nil && card2.previousCard   == nil)) &&
            ([self isCardSignaturesEqualWithSignature:selfSignature1 and:selfSignature2] || (selfSignature1 == nil && selfSignature2 == nil)));
}

-(BOOL)isRawSignaturesEqualWithSignature:(VSSRawSignature * __nonnull)signature1 and:(VSSRawSignature * __nonnull)signature2 {
    return ([signature1.signer isEqualToString:signature2.signer] &&
            [signature1.signature isEqualToString:signature2.signature] &&
            ([signature1.snapshot isEqualToString:signature2.snapshot] || (signature1.snapshot == nil && signature2.snapshot == nil)));
}

-(BOOL)isCardSignaturesEqualWithSignature:(VSSCardSignature * __nonnull)signature1 and:(VSSCardSignature * __nonnull)signature2 {
    return ([signature1.signer isEqualToString:signature2.signer] &&
            [signature1.signature isEqualToData:signature2.signature] &&
            ([signature1.snapshot isEqualToData:signature2.snapshot] || (signature1.snapshot == nil && signature2.snapshot == nil)) &&
            ([signature1.extraFields isEqualToDictionary:signature2.extraFields] || (signature1.extraFields == nil && signature2.extraFields == nil)));
}

-(BOOL)isRawCardContentEqualWithContent:(VSSRawCardContent * __nonnull)content1 and:(VSSRawCardContent * __nonnull)content2 {
    return ([content1.identity isEqualToString: content2.identity] &&
            [content1.publicKey isEqualToString: content2.publicKey] &&
            [content1.version isEqualToString: content2.version] &&
             content1.createdAt == content2.createdAt &&
            ([content1.previousCardId isEqualToString: content2.previousCardId] || (content1.previousCardId == nil && content2.previousCardId == nil)));
}

-(BOOL)isRawSignaturesEqualWithSignatures:(NSArray<VSSRawSignature *> * __nonnull)signatures1 and:(NSArray<VSSRawSignature *> * __nonnull)signatures2 {
    
    if (signatures1.count != signatures2.count) {
        return false;
    }
    BOOL found = false;
    for (VSSRawSignature* signature1 in signatures1) {
        found = false;
        for (VSSRawSignature* signature2 in signatures1) {
            if ([signature2.signer isEqualToString:signature1.signer]) {
                found = ([signature1.signature isEqualToString:signature2.signature] &&
                         ([signature1.snapshot isEqualToString:signature2.snapshot] || (signature1.snapshot == nil && signature2.snapshot == nil)));
            }
        }
        if (found == false) {
            return false;
        }
    }
    
    return true;
}

-(BOOL)isCardSignaturesEqualWithSignatures:(NSArray<VSSCardSignature *> * __nonnull)signatures1 and:(NSArray<VSSCardSignature *> * __nonnull)signatures2 {
    
    if (signatures1.count != signatures2.count) {
        return false;
    }
    BOOL found = false;
    for (VSSRawSignature* signature1 in signatures1) {
        found = false;
        for (VSSRawSignature* signature2 in signatures1) {
            if ([signature2.signer isEqualToString:signature1.signer]) {
                found = ([signature1.signature isEqualToString:signature2.signature] &&
                         ([signature1.snapshot isEqualToString:signature2.snapshot] || (signature1.snapshot == nil && signature2.snapshot == nil)));
            }
        }
        if (found == false) {
            return false;
        }
    }
    
    return true;
}

@end
