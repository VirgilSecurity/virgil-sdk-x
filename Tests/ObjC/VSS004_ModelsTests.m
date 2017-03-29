//
//  VSS004_ModelsTests.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSTestsUtils.h"
#import "VSSCrypto.h"

@interface VSS004_ModelsTests : XCTestCase

@property (nonatomic) VSSTestsUtils * __nonnull utils;
@property (nonatomic) VSSTestsConst * __nonnull consts;
@property (nonatomic) VSSCrypto * __nonnull crypto;

@end

@implementation VSS004_ModelsTests

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

- (void)test001_CreateCardRequestImportExport {
    VSSCreateCardRequest *request = [self.utils instantiateCreateCardRequest];
    
    NSString *exportedData = [request exportData];
    
    VSSCreateCardRequest *importedRequest = [[VSSCreateCardRequest alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkCreateCardRequest:request isEqualToCreateCardRequest:importedRequest]);
}

- (void)test002_CreateGlobalCardRequestImportExport {
    VSSCreateEmailCardRequest *request = [self.utils instantiateEmailCreateCardRequestWithValidationToken:@"testToken"];
    
    NSString *exportedData = [request exportData];
    
    VSSCreateEmailCardRequest *importedRequest = [[VSSCreateEmailCardRequest alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkCreateGlobalCardRequest:request isEqualToCreateGlobalCardRequest:importedRequest]);
}

- (void)test003_RevokeCardRequestImportExport {
    VSSRevokeUserCardRequest *revokeRequest = [VSSRevokeUserCardRequest revokeUserCardRequestWithCardId:@"testId" reason:VSSCardRevocationReasonUnspecified];
    
    NSString *exportedData = [revokeRequest exportData];
    
    VSSRevokeCardRequest *importedRevokeRequest = [[VSSRevokeCardRequest alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkRevokeCardRequest:revokeRequest isEqualToRevokeCardRequest:importedRevokeRequest]);
}

- (void)test004_RevokeGlobalCardRequestImportExport {
    VSSRevokeEmailCardRequest *revokeRequest = [VSSRevokeEmailCardRequest revokeEmailCardRequestWithCardId:@"testId" validationToken:@"testToken" reason:VSSCardRevocationReasonUnspecified];
    
    NSString *exportedData = [revokeRequest exportData];
    
    VSSRevokeEmailCardRequest *importedRevokeRequest = [[VSSRevokeEmailCardRequest alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkRevokeGlobalCardRequest:revokeRequest isEqualToRevokeGlobalCardRequest:importedRevokeRequest]);
}

- (void)test005_CardImportExport {
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
