//
//  VK001_KeysClientTests.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "BridgingHeader.h"

/// Virgil Application Token for testing applications
static NSString *const kApplicationToken = @"eyJpZCI6IjMyYTAwZDEwLWYyNTgtNDVjMi04YTQyLTY5OGFhYTU5NjhhNiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiI2MTNiYTEwYy1lODQ5LTRkNTctODhlMy03YTZmZjdlZmVkYmEiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MIGbMA0GCWCGSAFlAwQCAgUABIGJMIGGAkEAhcP5jjV88b/uRVwuILO8sCrqXElVLGrAi9YzHMxkp0rrDIjHtC7LKN3nGAs1z8N80yWHXDEpzv6YNiv6M9aoIgJBAJ+s8BOCDkMSdDoXN4G0KwQuzxWpm+x8Id1qEv+sYb1FRHlbpvwvJMH0kfMNwq42TwlGDvZTDQZRbN1N2OnX55k=";
/// Mailinator Application Token for Virgil applications
static NSString *const kMailinatorToken = @"3b0f46370d9f44cb9b5ac0e80dda97d7";
/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;
/// Time for waiting for the emails with confirmation codes sent by the Virgil Keys Service.
static const NSTimeInterval kEstimatedEmailReceivingTime = 2.;

@interface VSS001_ClientTests : XCTestCase

@property (nonatomic, strong) VSSClient *client;
@property (nonatomic, strong) Mailinator *mailinator;

@property (nonatomic, strong) NSRegularExpression *regexp;

@property (nonatomic, strong) VSSKeyPair *keyPair;
@property (nonatomic, strong) VSSPublicKey *publicKey;

@property (nonatomic, strong) VSSCard *card;
@property (nonatomic, strong) NSString *validationToken;

- (NSString *)identityValue;
- (NSDictionary *)identity;

- (void)createConfirmedCardWithConfirmationHandler:(void(^)(NSError *))handler;
- (void)confirmIdentity:(NSDictionary *)identity actionId:(NSString *)actionId withHandler:(void(^)(NSError *error))handler;

@end

@implementation VSS001_ClientTests

@synthesize client = _client;
@synthesize mailinator = _mailinator;
@synthesize regexp = _regexp;
@synthesize keyPair = _keyPair;
@synthesize publicKey = _publicKey;
@synthesize card = _card;
@synthesize validationToken = _validationToken;

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    
    self.client = [[VSSClient alloc] initWithApplicationToken:kApplicationToken serviceConfig:[VSSServiceConfigStg serviceConfig]];
    self.mailinator = [[Mailinator alloc] initWithApplicationToken:kMailinatorToken serviceConfig:[MailinatorConfig serviceConfig]];
    self.regexp = [NSRegularExpression regularExpressionWithPattern:@"Your confirmation code is.+([A-Z0-9]{6})" options:NSRegularExpressionCaseInsensitive error:nil];
    self.keyPair = [[VSSKeyPair alloc] init];
}

- (void)tearDown {
    self.client = nil;
    self.mailinator = nil;
    self.regexp = nil;
    self.keyPair = nil;
    self.publicKey = nil;
    self.card = nil;
    self.validationToken = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_createCardAndConfirmIdentity {
    // Create test expectation object.
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil card should be created and its identity should be confirmed."];

    NSUInteger numberOfRequests = 7;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    [self.client setupClientWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"VSSClient setup has failed");
            return;
        }
        [self createConfirmedCardWithConfirmationHandler:^(NSError *error) {
            if (error != nil) {
                XCTFail(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            XCTAssertNotNil(self.card, @"Virgil Card should be created.");
            XCTAssertNotNil(self.card.Id, @"Virgil Card should have ID.");
            XCTAssertTrue([[self.card isConfirmed] boolValue], @"Virgil Card should be created confirmed.");
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test002_getExistingPublicKey {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil public key should be returned."];
    
    NSUInteger numberOfRequests = 8;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;

    [self.client setupClientWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"VSSClient setup has failed");
            return;
        }
        [self createConfirmedCardWithConfirmationHandler:^(NSError *error) {
            if (error != nil) {
                XCTFail(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
            [self.client getPublicKeyWithId:self.card.publicKey.Id card:self.card privateKey:privateKey completionHandler:^(VSSPublicKeyExtended * _Nullable key, NSError * _Nullable error) {
                if (error != nil) {
                    XCTFail(@"Error: %@", [error localizedDescription]);
                    return;
                }
                
                XCTAssertNotNil(key, @"Public key should be returned.");
                [ex fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test003_attachNewCard {
    // Create test expectation object.
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil card should be created and its identity should be NOT confirmed."];
    
    NSUInteger numberOfRequests = 8;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    [self.client setupClientWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"VSSClient setup has failed");
            return;
        }
        [self createConfirmedCardWithConfirmationHandler:^(NSError *error) {
            if (error != nil) {
                XCTFail(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
            [self.client createCardWithPublicKeyId:self.card.publicKey.Id identity:[self identity] data:nil signs:nil privateKey:privateKey completionHandler:^(VSSCard * _Nullable card, NSError * _Nullable error) {
                if (error != nil) {
                    XCTFail(@"Error: %@", [error localizedDescription]);
                    return;
                }
                
                XCTAssertNotNil(card, @"Virgil Card should be created.");
                XCTAssertNotNil(card.Id, @"Virgil Card should have ID.");
                XCTAssertFalse([[card isConfirmed] boolValue], @"Virgil Card should be created unconfirmed.");
                
                [ex fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test004_storeAndGrabPrivateKey {
    // Create test expectation object.
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Private key should be stored and then read."];
    
    NSUInteger numberOfRequests = 9;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    [self.client setupClientWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"VSSClient setup has failed");
            return;
        }
        [self createConfirmedCardWithConfirmationHandler:^(NSError *error) {
            if (error != nil) {
                XCTFail(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
            [self.client storePrivateKey:privateKey cardId:self.card.Id completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    XCTFail(@"Error: %@", [error localizedDescription]);
                    return;
                }
                
                NSMutableDictionary *idtt = [NSMutableDictionary dictionary];
                idtt[kVSSModelType] = [VSSIdentity stringFromIdentityType:self.card.identity.type];
                idtt[kVSSModelValue] = self.card.identity.value;
                idtt[kVSSModelValidationToken] = self.validationToken;
                
                [self.client grabPrivateKeyWithIdentity:idtt cardId:self.card.Id password:nil completionHandler:^(NSData * _Nullable keyData, GUID * _Nullable cardId, NSError * _Nullable error) {
                    if (error != nil) {
                        XCTFail(@"Error: %@", [error localizedDescription]);
                        return;
                    }
                    
                    XCTAssertEqualObjects(cardId, self.card.Id, @"Virgil card IDs should match.");
                    XCTAssertEqualObjects(keyData, privateKey.key, @"Private key data returned should match data which was sent.");
                    
                    [ex fulfill];
                }];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

#pragma mark - Private class logic

- (NSString *)identityValue {
    NSString *candidate = [[[NSUUID UUID] UUIDString] lowercaseString];
    NSString *identity = [candidate stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [NSString stringWithFormat:@"%@@mailinator.com", identity];
}

- (NSDictionary *)identity {
    return @{ kVSSModelType: [VSSIdentity stringFromIdentityType:VSSIdentityTypeEmail], kVSSModelValue: [self identityValue] };
}

- (void)createConfirmedCardWithConfirmationHandler:(void(^)(NSError *))handler {
    NSDictionary *identity = [self identity];
    [self.client verifyIdentityWithType:[VSSIdentity identityTypeFromString:identity[kVSSModelType]] value:identity[kVSSModelValue] completionHandler:^(GUID *actionId, NSError *error) {
        if (error != nil) {
            if (handler != nil) {
                handler(error);
            }
            return;
        }
        
        [self confirmIdentity:identity actionId:actionId withHandler:handler];
    }];
}

- (void)confirmIdentity:(NSDictionary *)identity actionId:(NSString *)actionId withHandler:(void(^)(NSError *error))handler {
    // Get the Mailinator inbox name
    NSString *val = [identity[kVSSModelValue] as:[NSString class]];
    NSString *inbox = [val substringToIndex:[val rangeOfString:@"@"].location];
    [self.mailinator getInbox:inbox completionHandler:^(NSArray *metadataList, NSError *error) {
        if (error != nil) {
            // We can't get emails list and we can't get confirmation code.
            // Identity will not be confirmed.
            if (handler != nil) {
                handler(error);
            }
            return;
        }
        // We have got the inbox for this particular user data.
        if (metadataList.count == 0) {
            // But there is no any mails in the inbox.
            // We can't get the confirmation code.
            if (handler != nil) {
                handler([NSError errorWithDomain:@"TestDomain" code:-1 userInfo:nil]);
            }
            return;
        }
        // Get the latest metadata from the list (it is the first object)
        MEmailMetadata *metadata = [metadataList[0] as:[MEmailMetadata class]];
        [self.mailinator getEmail:metadata.mid completionHandler:^(MEmail *email, NSError *error) {
            if (error != nil) {
                // We can't get the email and code.
                if (handler != nil) {
                    handler(error);
                }
                return;
            }
            
            // Extract the email body text
            MPart *bodyPart = [email.parts[0] as:[MPart class]];
            // Try to find the actual confirmation code in body
            NSTextCheckingResult *matchResult = [self.regexp firstMatchInString:bodyPart.body options:NSMatchingReportCompletion range:NSMakeRange(0, bodyPart.body.length)];
            if (matchResult == nil || matchResult.range.location == NSNotFound) {
                // There is no match in the email body.
                // Confirmation code is absent or can not be extracted.
                if (handler != nil) {
                    handler([NSError errorWithDomain:@"TestDomain" code:-2 userInfo:nil]);
                }
                return;
            }
            // If we have a match
            NSString *match = [bodyPart.body substringWithRange:matchResult.range];
            // Now match string should contain something like "Your confirmation code is ....."
            // Actual code is the last 6 charachters.
            // Extract the code
            NSString *code = [match substringFromIndex:match.length - 6];
            [self.client confirmIdentityWithActionId:actionId code:code ttl:nil ctl:@10 completionHandler:^(VSSIdentityType type, NSString *value, NSString *validationToken, NSError *error) {
                if (error != nil) {
                    if (handler != nil) {
                        handler(error);
                    }
                    return;
                }

                if (![value isEqualToString:identity[kVSSModelValue]] && validationToken.length == 0) {
                    if (handler != nil) {
                        handler([NSError errorWithDomain:@"TestDomain" code:-3 userInfo:nil]);
                    }
                    return;
                }
                self.validationToken = validationToken;
                NSMutableDictionary *identityExt = [[NSMutableDictionary alloc] initWithDictionary:identity];
                identityExt[kVSSModelValidationToken] = validationToken;
                
                VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
                [self.client createCardWithPublicKey:self.keyPair.publicKey identity:identityExt data:nil signs:nil privateKey:privateKey completionHandler:^(VSSCard *card, NSError *error) {
                    self.card = card;
                    if (handler != nil) {
                        handler(error);
                    }
                    return;
                }];
            }];
        }];
    }];
}

@end
