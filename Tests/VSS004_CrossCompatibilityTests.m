//
//  VSS004_CrossCompatibilityTests.m
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/24/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
@import VirgilSDK;
@import VirgilCrypto;

#import "VSSTestsConst.h"

@interface VSS004_CrossCompatibilityTests : XCTestCase

@end

@implementation VSS004_CrossCompatibilityTests

- (void)test001 {
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *path1 = [bundle pathForResource:@"t1_exported_as_str" ofType:@"txt"];
    XCTAssert(path1 != nil);

    NSString *rawCardString = [[NSString alloc]initWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:&error];
    XCTAssert(error == nil);
    XCTAssert(rawCardString != nil);
    
    VSSRawSignedModel *rawCard1 = [[VSSRawSignedModel alloc] initWithString:rawCardString];
    XCTAssert(rawCard1 != nil);
    
    VSSRawCardContent *cardContent1 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard1.contentSnapshot];
    XCTAssert(cardContent1 != nil);
    
    // FIXME move to utils
    XCTAssert([cardContent1.identity isEqualToString:@"test"]);
    XCTAssert([cardContent1.publicKey isEqualToString:@"MCowBQYDK2VwAyEA3J0Ivcs4/ahBafrn6mB4t+UI+IBhWjC/toVDrPJcCZk="]);
    XCTAssert([cardContent1.version isEqualToString:@"5.0"]);
    XCTAssert(cardContent1.createdAt == 1515686245);
    XCTAssert(cardContent1.previousCardId == nil);
    XCTAssert(rawCard1.signatures.count == 0);
    
    
    NSString *path2 = [bundle pathForResource:@"t1_exported_as_json" ofType:@"txt"];
    XCTAssert(path2 != nil);
    
    NSData *rawCardDic = [[NSData alloc] initWithContentsOfFile:path2];
    XCTAssert(rawCardDic != nil);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:rawCardDic options:kNilOptions error:nil];
    XCTAssert(dic != nil);
    
    VSSRawSignedModel *rawCard2 = [[VSSRawSignedModel alloc] initWithJson:dic];
    XCTAssert(rawCard2 != nil);
    
    VSSRawCardContent *cardContent2 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard2.contentSnapshot];
    XCTAssert(cardContent2 != nil);
    
    // FIXME move to utils
    XCTAssert([cardContent2.identity isEqualToString:@"test"]);
    XCTAssert([cardContent2.publicKey isEqualToString:@"MCowBQYDK2VwAyEA3J0Ivcs4/ahBafrn6mB4t+UI+IBhWjC/toVDrPJcCZk="]);
    XCTAssert([cardContent2.version isEqualToString:@"5.0"]);
    XCTAssert(cardContent2.createdAt == 1515686245);
    XCTAssert(cardContent2.previousCardId == nil);
    XCTAssert(rawCard2.signatures.count == 0);
    
// FIXME exported json compatibility
    NSData *snapshot1 = [cardContent1 snapshot];
    XCTAssert(error == nil && snapshot1 != nil);
    
    VSSRawSignedModel *newRawCard1 = [[VSSRawSignedModel alloc] initWithContentSnapshot:snapshot1 signatures:rawCard1.signatures];
    XCTAssert(newRawCard1 != nil);
    
    NSString *exportedRawCardString = [rawCard1 exportAsStringAndReturnError:&error];
    XCTAssert(error == nil);
    
    VSSRawSignedModel *newImportedRawCard1 = [[VSSRawSignedModel alloc] initWithString:exportedRawCardString];
    XCTAssert(newImportedRawCard1 != nil);
    
    VSSRawCardContent *newCardContent1 = [[VSSRawCardContent alloc] initWithSnapshot:newImportedRawCard1.contentSnapshot];
    XCTAssert(newCardContent1 != nil);
    
    XCTAssert([newCardContent1.identity isEqualToString:@"test"]);
    XCTAssert([newCardContent1.publicKey isEqualToString:@"MCowBQYDK2VwAyEA3J0Ivcs4/ahBafrn6mB4t+UI+IBhWjC/toVDrPJcCZk="]);
    XCTAssert([newCardContent1.version isEqualToString:@"5.0"]);
    XCTAssert(newCardContent1.createdAt == 1515686245);
    XCTAssert(newCardContent1.previousCardId == nil);
    XCTAssert(newImportedRawCard1.signatures.count == 0);
    
    NSDictionary *exportedRawCardJson = [newRawCard1 exportAsJsonAndReturnError:&error];
    XCTAssert(error == nil);
    NSLog(@"Message == %@",exportedRawCardJson);
    NSLog(@"Message == %@",dic);
    
    VSSRawSignedModel *newImportedRawCard2 = [[VSSRawSignedModel alloc] initWithJson:exportedRawCardJson];
    XCTAssert(newImportedRawCard2 != nil);
    
    VSSRawCardContent *newCardContent2 = [[VSSRawCardContent alloc] initWithSnapshot:newImportedRawCard2.contentSnapshot];
    XCTAssert(newCardContent2 != nil);
    
    XCTAssert([newCardContent2.identity isEqualToString:@"test"]);
    XCTAssert([newCardContent2.publicKey isEqualToString:@"MCowBQYDK2VwAyEA3J0Ivcs4/ahBafrn6mB4t+UI+IBhWjC/toVDrPJcCZk="]);
    XCTAssert([newCardContent2.version isEqualToString:@"5.0"]);
    XCTAssert(newCardContent2.createdAt == 1515686245);
    XCTAssert(newCardContent2.previousCardId == nil);
    XCTAssert(newImportedRawCard2.signatures.count == 0);
    
    
    XCTAssert(exportedRawCardJson[@"previous_card_id"] == nil);
}

- (void)test002 {
    NSError *error;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *path1 = [bundle pathForResource:@"t2_exported_as_str" ofType:@"txt"];
    XCTAssert(path1 != nil);
    
    NSString *rawCardString = [[NSString alloc]initWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:&error];
    XCTAssert(error == nil);
    XCTAssert(rawCardString != nil);
    NSLog(@"Message == %@", rawCardString);
    
    VSSRawSignedModel *rawCard1 = [[VSSRawSignedModel alloc] initWithString:rawCardString];
    XCTAssert(rawCard1 != nil);
    
    VSSRawCardContent *cardContent1 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard1.contentSnapshot];
    XCTAssert(cardContent1 != nil);
    
    // FIXME move to utils
    XCTAssert([cardContent1.identity isEqualToString:@"test"]);
    XCTAssert([cardContent1.publicKey isEqualToString:@"MCowBQYDK2VwAyEA3J0Ivcs4/ahBafrn6mB4t+UI+IBhWjC/toVDrPJcCZk="]);
    XCTAssert([cardContent1.version isEqualToString:@"5.0"]);
    XCTAssert(cardContent1.createdAt == 1515686245);
    XCTAssert([cardContent1.previousCardId isEqualToString:@"a666318071274adb738af3f67b8c7ec29d954de2cabfd71a942e6ea38e59fff9"]);
    XCTAssert(rawCard1.signatures.count == 3);
    
    NSString *path2 = [bundle pathForResource:@"t2_exported_as_json" ofType:@"txt"];
    XCTAssert(path2 != nil);
    
    NSData *rawCardDic = [[NSData alloc] initWithContentsOfFile:path2];
    XCTAssert(rawCardDic != nil);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:rawCardDic options:kNilOptions error:nil];
    XCTAssert(dic != nil);
    
    VSSRawSignedModel *rawCard2 = [[VSSRawSignedModel alloc] initWithJson:dic];
    XCTAssert(rawCard2 != nil);
    
    VSSRawCardContent *cardContent2 = [[VSSRawCardContent alloc] initWithSnapshot:rawCard2.contentSnapshot];
    XCTAssert(cardContent2 != nil);
    
    // FIXME move to utils
    XCTAssert([cardContent2.identity isEqualToString:@"test"]);
    XCTAssert([cardContent2.publicKey isEqualToString:@"MCowBQYDK2VwAyEA3J0Ivcs4/ahBafrn6mB4t+UI+IBhWjC/toVDrPJcCZk="]);
    XCTAssert([cardContent2.version isEqualToString:@"5.0"]);
    XCTAssert(cardContent2.createdAt == 1515686245);
    XCTAssert([cardContent2.previousCardId isEqualToString:@"a666318071274adb738af3f67b8c7ec29d954de2cabfd71a942e6ea38e59fff9"]);
    XCTAssert(rawCard2.signatures.count == 3);
}


@end
