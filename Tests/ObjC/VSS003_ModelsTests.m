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

@end

@implementation VSS003_ModelsTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:[[VSSCrypto alloc] init]];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_CardImportExport {
    VSSCard *card = [self.utils instantiateCard];
    
    NSString *exportedData = [card exportData];
    
    VSSCard *importedCard = [[VSSCard alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkCard:card isEqualToCard:importedCard]);
}

- (void)test002_RevokeCardImportExport {
    VSSRevokeCard *revokeCard = [VSSRevokeCard revokeCardWithCardId:@"testId" reason:VSSCardRevocationReasonUnspecified];
    
    NSString *exportedData = [revokeCard exportData];
    
    VSSRevokeCard *importedRevokeCard = [[VSSRevokeCard alloc] initWithData:exportedData];
    
    XCTAssert([self.utils checkRevokeCard:revokeCard isEqualToRevokeCard:importedRevokeCard]);
}

@end
