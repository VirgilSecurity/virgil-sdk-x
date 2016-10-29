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
    
    self.utils = [[VSSTestsUtils alloc] initWithCrypto:[[VSSCrypto alloc] init] consts:[[VSSTestsConst alloc] init]];
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

@end
