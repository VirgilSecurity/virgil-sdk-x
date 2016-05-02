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
static NSString *const kApplicationToken = @"eyJpZCI6IjAwOTUwMWFjLWNlZmYtNDRhZC1iMGI2LTk0ZjlkYjJmYzY1YiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiIxNTJhOGM3Yi03MDNmLTRmYWMtOTcxYi02MDcyMjNjZTc1NjAiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MFgwDQYJYIZIAWUDBAICBQAERzBFAiAi1tiSdVSU6ZP8U7jRv2cN+jxkqvhrjpmT0ejIgnB/AQIhAM6H13yqn5xpkkC+GJ//aa1rS/84kpoBleDLTmv/KTge";

static NSString *const kApplicationPublicKey = @"-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEDzS4ocTOJ+edeft8wv6GR2Scd0In\nSUvNsCt6ostcyBley1UkWEgGosOluDB1q0pIjesON2B7/fuEgQSzV38zcA==\n-----END PUBLIC KEY-----\n";
static NSString *const kApplicationPrivateKey = @"-----BEGIN ENCRYPTED PRIVATE KEY-----\nMIHyMF0GCSqGSIb3DQEFDTBQMC8GCSqGSIb3DQEFDDAiBBBPmb1eLU1/ciH4go7I\nQkvGAgIN7zAKBggqhkiG9w0CCjAdBglghkgBZQMEASoEECpnDS0OMWZE1m610bHx\na/cEgZBcHuiTKRJq4hAYQOKpSd8ahdG0f+bDDL/XkZ+S/AYTPyGtI7auMcDiihAm\n9PZnb0Awhx28vVBVeuz6/18S6b+tyEehhTKw2XuXQCR7+NFUezlCAcQgLYdk/qnQ\nL1O8Cj1cmuFtEpUQLf0Tx9AlyBeAqH5xO6iHIPOMXc/HI7fmRc4oihOztb5wrbIY\nWKMd8Ug=\n-----END ENCRYPTED PRIVATE KEY-----\n";
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
- (VSSIdentityInfo *)identity;

- (void)createConfirmedCardWithConfirmationHandler:(void(^)(NSError *))handler;
- (void)confirmIdentity:(VSSIdentityInfo *)identity actionId:(NSString *)actionId withHandler:(void(^)(NSError *error))handler;

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
    
    self.client = [[VSSClient alloc] initWithApplicationToken:kApplicationToken];
    
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
    
    [self createConfirmedCardWithConfirmationHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
        
        XCTAssertNotNil(self.card, @"Virgil Card should be created.");
        XCTAssertNotNil(self.card.Id, @"Virgil Card should have ID.");
        XCTAssertNotNil(self.card.authorizedBy, @"Virgil Card should be created confirmed.");
        XCTAssertNotNil(self.card.createdAt, @"Virgil Card should have correct creation date.");
        
        [ex fulfill];
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
            [self.client createCardWithPublicKeyId:self.card.publicKey.Id identityInfo:[self identity] data:nil signs:nil privateKey:privateKey completionHandler:^(VSSCard * _Nullable card, NSError * _Nullable error) {
                if (error != nil) {
                    XCTFail(@"Error: %@", [error localizedDescription]);
                    return;
                }
                
                XCTAssertNotNil(card, @"Virgil Card should be created.");
                XCTAssertNotNil(card.Id, @"Virgil Card should have ID.");
                XCTAssertNil(card.authorizedBy, @"Virgil Card should be created unconfirmed.");
                
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
            
            VSSIdentityInfo *info = [[VSSIdentityInfo alloc] initWithType:self.card.identity.type value:self.card.identity.value validationToken:self.validationToken];

            [self.client getPrivateKeyWithCardId:self.card.Id identityInfo:info password:nil completionHandler:^(NSData * _Nullable keyData, GUID * _Nullable cardId, NSError * _Nullable error) {
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
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test005_createAndDeleteVirgilCard {
    // Create test expectation object.
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil card should be created and then deleted."];
    
    NSUInteger numberOfRequests = 9;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    [self createConfirmedCardWithConfirmationHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
        
        VSSIdentityInfo *info = [[VSSIdentityInfo alloc] initWithType:self.card.identity.type value:self.card.identity.value validationToken:self.validationToken];
        
        VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
        [self.client deleteCardWithCardId:self.card.Id identityInfo:info privateKey:privateKey completionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                XCTFail(@"Error: %@", [error localizedDescription]);
                return;
            }
            
            [self.client getCardWithCardId:self.card.Id completionHandler:^(VSSCard * _Nullable card, NSError * _Nullable error) {
                /// We should not get a deleted card.
                XCTAssertNil(card);
                /// Error should be returned.
                XCTAssertNotNil(error);
                
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

- (void)test006_decryptWithIncorrectPassword {
    NSString *message = @"Message to encrypt";
    NSData *toEncrypt = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    NSError *error = nil;
    VSSCryptor *cryptor = [[VSSCryptor alloc] init];
    if (![cryptor addPasswordRecipient:@"secret" error:&error]) {
        XCTFail(@"Error adding password recipient: %@", [error localizedDescription]);
        return;
    }
    
    error = nil;
    NSData *encryptedData = [cryptor encryptData:toEncrypt embedContentInfo:YES error:&error];
    if (encryptedData.length == 0) {
        XCTFail(@"Error encrypting data: %@", [error localizedDescription]);
        return;
    }
    
    error = nil;
    VSSCryptor *decryptor = [[VSSCryptor alloc] init];
    NSData* decryptedData = [decryptor decryptData:encryptedData password:@"incorrect" error:&error];
    if (decryptedData.length != 0) {
        XCTFail(@"Error: decryption with incorrect password should fail!");
        return;
    }
    NSLog(@"Unable to decrypt data using incorrect password: %@", [error localizedDescription]);
    
    error = nil;
    decryptedData = [decryptor decryptData:encryptedData password:@"secret" error:&error];
    if (decryptedData.length == 0) {
        XCTFail(@"Error decrypting data: %@", [error localizedDescription]);
        return;
    }
}

- (void)test007_createAndGetUnconfirmedCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card should be created unconfirmed."];
    
    NSUInteger numberOfRequests = 9;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
    [self.client createCardWithPublicKey:self.keyPair.publicKey identityInfo:[self identity] data:nil signs:nil privateKey:privateKey completionHandler:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Error creating unconfirmed card: %@", [error localizedDescription]);
            return;
        }
        
        XCTAssertNotNil(card, @"Virgil Card should be created.");
        XCTAssertNotNil(card.Id, @"Virgil Card should have ID.");
        XCTAssertNil(card.authorizedBy, @"Virgil Card should be created unconfirmed.");
        XCTAssertNotNil(card.createdAt, @"Virgil Card should have correct creation date.");
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
    }];
}

- (void)test008_createAndGetUnconfirmedCustomCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card with custom identity should be created unconfirmed."];
    
    NSUInteger numberOfRequests = 9;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    VSSPBKDF *pbkdf = [[VSSPBKDF alloc] initWithSalt:nil iterations:0];
    NSString *obfuscated = [pbkdf base64KeyFromPassword:@"test-identity-value" size:64 error:nil];
    if (obfuscated.length == 0) {
        XCTFail(@"Error obfuscating identity value.");
        return;
    }
    
    VSSIdentityInfo *identity = [[VSSIdentityInfo alloc] initWithType:@"private" value:obfuscated validationToken:nil];
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
    [self.client createCardWithPublicKey:self.keyPair.publicKey identityInfo:identity data:nil signs:nil privateKey:privateKey completionHandler:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Error creating unconfirmed card: %@", [error localizedDescription]);
            return;
        }
        
        XCTAssertNotNil(card, @"Virgil Card should be created.");
        XCTAssertNotNil(card.Id, @"Virgil Card should have ID.");
        XCTAssertNil(card.authorizedBy, @"Virgil Card should be created unconfirmed.");
        XCTAssertNotNil(card.createdAt, @"Virgil Card should have correct creation date.");
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
    }];
}

- (void)test009_createAndGetConfirmedCustomCard {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Virgil Card with custom identity should be created confirmed."];
    
    NSUInteger numberOfRequests = 9;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    VSSPBKDF *pbkdf = [[VSSPBKDF alloc] initWithSalt:nil iterations:0];
    NSString *obfuscated = [pbkdf base64KeyFromPassword:@"test-identity-value" size:64 error:nil];
    if (obfuscated.length == 0) {
        XCTFail(@"Error obfuscating identity value.");
        return;
    }
    VSSIdentityInfo *identity = [[VSSIdentityInfo alloc] initWithType:@"private" value:obfuscated validationToken:nil];
    NSData *keyData = [kApplicationPrivateKey dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    VSSPrivateKey *appKey = [[VSSPrivateKey alloc] initWithKey:keyData password:@"secret"];
    NSError *error = nil;
    [VSSValidationTokenGenerator setValidationTokenForIdentityInfo:identity privateKey:appKey error:&error];
    if (identity.validationToken.length == 0) {
        XCTFail(@"Error generating validation token: %@", [error localizedDescription]);
        return;
    }
    
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
    [self.client createCardWithPublicKey:self.keyPair.publicKey identityInfo:identity data:nil signs:nil privateKey:privateKey completionHandler:^(VSSCard *card, NSError *error) {
        if (error != nil) {
            XCTFail(@"Error creating unconfirmed card: %@", [error localizedDescription]);
            return;
        }
        
        XCTAssertNotNil(card, @"Virgil Card should be created.");
        XCTAssertNotNil(card.Id, @"Virgil Card should have ID.");
        XCTAssertNotNil(card.authorizedBy, @"Virgil Card should be created confirmed.");
        XCTAssertNotNil(card.createdAt, @"Virgil Card should have correct creation date.");
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
            return;
        }
    }];
}

#pragma mark - Private class logic

- (NSString *)identityValue {
    NSString *candidate = [[[NSUUID UUID] UUIDString] lowercaseString];
    NSString *identity = [[candidate stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:25];
    return [NSString stringWithFormat:@"%@@mailinator.com", identity];
}

- (VSSIdentityInfo *)identity {
    return [[VSSIdentityInfo alloc] initWithType:kVSSIdentityTypeEmail value:[self identityValue] validationToken:nil];
}

- (void)createConfirmedCardWithConfirmationHandler:(void(^)(NSError *))handler {
    VSSIdentityInfo *identity = [self identity];
    [self.client verifyIdentityWithInfo:identity extraFields:nil completionHandler:^(GUID * _Nullable actionId, NSError * _Nullable error) {
        if (error != nil) {
            if (handler != nil) {
                handler(error);
            }
            return;
        }
        
        [self confirmIdentity:identity actionId:actionId withHandler:handler];
    }];
}

- (void)confirmIdentity:(VSSIdentityInfo *)identity actionId:(NSString *)actionId withHandler:(void(^)(NSError *error))handler {
    // Get the Mailinator inbox name
    NSString *inbox = [identity.value substringToIndex:[identity.value rangeOfString:@"@"].location];
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
            [self.client confirmIdentityWithActionId:actionId code:code tokenTtl:0 tokenCtl:10 completionHandler:^(VSSIdentityInfo * _Nullable identityInfo, NSError * _Nullable error) {
                if (error != nil) {
                    if (handler != nil) {
                        handler(error);
                    }
                    return;
                }
                
                if(![identity isEqual:identityInfo] || identityInfo.validationToken.length == 0) {
                    if (handler != nil) {
                        handler([NSError errorWithDomain:@"TestDomain" code:-3 userInfo:nil]);
                    }
                    return;
                }
                
                identity.validationToken = identityInfo.validationToken;
                self.validationToken = identityInfo.validationToken;
               
                VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
                [self.client createCardWithPublicKey:self.keyPair.publicKey identityInfo:identityInfo data:nil signs:nil privateKey:privateKey completionHandler:^(VSSCard * _Nullable card, NSError * _Nullable error) {
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
