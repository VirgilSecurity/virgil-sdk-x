//
//  VSS003_ModelsTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSTestsUtils.h"
#import "VSSCrypto.h"

@interface VSS003_ModelsTests : XCTestCase

@property (nonatomic) VSSTestsUtils * __nonnull utils;
@property (nonatomic) VSSTestsConst * __nonnull consts;
@property (nonatomic) VSSCrypto * __nonnull crypto;

@end

@implementation VSS003_ModelsTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.crypto = [[VSSCrypto alloc] init];
    self.consts = [[VSSTestsConst alloc] init];
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:self.crypto consts:self.consts];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_CardImportExport {
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
    
    NSString *exportedData = [request exportData];
    
    VSSCreateCardRequest *importedRequest = [[VSSCreateCardRequest alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkCreateCardRequest:request isEqualToCreateCardRequest:importedRequest]);
}

- (void)test002_RevokeCardImportExport {
    VSSRevokeCardRequest *revokeRequest = [VSSRevokeCardRequest revokeCardRequestWithCardId:@"testId" reason:VSSCardRevocationReasonUnspecified];
    
    NSString *exportedData = [revokeRequest exportData];
    
    VSSRevokeCardRequest *importedRevokeRequest = [[VSSRevokeCardRequest alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkRevokeCardRequest:revokeRequest isEqualToRevokeCardRequest:importedRevokeRequest]);
}

- (void)test003_CardImportExport {
    VSSCard *card = [self.utils instantiateCard];
    
    NSString *cardStr = [card exportData];
    
    VSSCard *importedCard = [[VSSCard alloc] initWithData:cardStr];
    
    XCTAssert([self.utils checkCard:card isEqualToCard:importedCard]);
    
    VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
    
    VSSPrivateKey *privateKey = [self.crypto importPrivateKeyFromData:[[NSData alloc] initWithBase64EncodedString:self.consts.applicationPrivateKeyBase64 options:0] withPassword:self.consts.applicationPrivateKeyPassword];
    VSSPublicKey *publicKey = [self.crypto extractPublicKeyFromPrivateKey:privateKey];
    NSData *publicKeyData = [self.crypto exportPublicKey:publicKey];
    
    XCTAssert([validator addVerifierWithId:self.consts.applicationId publicKeyData:publicKeyData]);
    
    XCTAssert([validator validateCardResponse:importedCard.cardResponse]);
}

@end
