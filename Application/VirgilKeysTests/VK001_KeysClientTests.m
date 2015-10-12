//
//  VK001_KeysClientTests.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "VSSKeysClientStg.h"
#import "VSSPublicKey.h"
#import "VSSActionToken.h"
#import "VSSUserDataExtended.h"

#import "Mailinator.h"
#import "MEmailMetadata.h"
#import "MEmailResponse.h"
#import "MEmail.h"
#import "MPart.h"
#import "VSSIdBundle.h"

#import <VirgilCryptoiOS/VirgilCryptoiOS.h>
#import <VirgilFrameworkiOS/VirgilFrameworkiOS.h>

/// Virgil Application Token for testing applications
static NSString *const kApplicationToken = @"e872d6f718a2dd0bd8cd7d7e73a25f49";
/// Mailinator Application Token for Virgil applications
static NSString *const kMailinatorToken = @"3b0f46370d9f44cb9b5ac0e80dda97d7";
/// Number of user data objects associated with/attached to the public key.
static const NSUInteger kTestUserDataCount = 2;
/// Each request should be done less than or equal this number of seconds.
static const NSTimeInterval kEstimatedRequestCompletionTime = 5.;
/// Time for waiting for the emails with confirmation codes sent by the Virgil Keys Service.
static const NSTimeInterval kEstimatedEmailReceivingTime = 2.;

@interface VK001_KeysClientTests : XCTestCase

@property (nonatomic, strong) VSSKeysClientStg *keysClient;
@property (nonatomic, strong) Mailinator *mailinator;

@property (nonatomic, strong) NSRegularExpression *regexp;

@property (nonatomic, strong) VSSKeyPair *keyPair;
@property (nonatomic, strong) VSSPublicKey *publicKey;

- (NSString *)userDataValue;
- (VSSUserDataExtended *)userData;
- (NSArray *)userDataListWithLength:(NSUInteger)length;
- (NSNumber *)completedConfirmationList:(NSArray *)list;

- (void)createPublicKeyWithUserDataList:(NSArray *)userDataList andHandler:(void(^)(NSError *))handler;
- (void)confirmUserDataOfPublicKey:(VSSPublicKey *)key withHandler:(void(^)(NSError *error))handler;

/**
 * @discussion This method will execute the following network requests:
 * - 1 request for public key creation.
 * for each user data for the public key, it will execute:
 * - 1 request for inbox from the mailinator service for this user data value
 * - 1 request for the latest email from the mailinator service for this user data value
 * - 1 request for the confirmation of the current user data with extracted confirmation code.
 */
- (void)createPublicKeyWithUserDataList:(NSArray *)userDataList andConfirmUserDataWithHandler:(void(^)(NSError *))handler;

@end

@implementation VK001_KeysClientTests

@synthesize keysClient = _keysClient;
@synthesize mailinator = _mailinator;
@synthesize regexp = _regexp;
@synthesize keyPair = _keyPair;
@synthesize publicKey = _publicKey;

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    self.keysClient = [[VSSKeysClientStg alloc] initWithApplicationToken:kApplicationToken];
    self.mailinator = [[Mailinator alloc] initWithApplicationToken:kMailinatorToken];
    self.regexp = [NSRegularExpression regularExpressionWithPattern:@"Your confirmation code is.+([A-Z0-9]{6})" options:NSRegularExpressionCaseInsensitive error:nil];
    self.keyPair = [[VSSKeyPair alloc] init];
}

- (void)tearDown {
    self.keysClient = nil;
    self.mailinator = nil;
    self.regexp = nil;
    self.keyPair = nil;
    self.publicKey = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)test001_createPublicKeyAndConfirmUserData {
    // Create test expectation object.
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Public key should be created and user data should be confirmed."];
    // Total estimated number of network requests:
    // 3 requests for each user data: mailinator inbox + mailinator email + user data confirm
    // And one general request for public key create.
    NSUInteger numberOfRequests = kTestUserDataCount * 3 + 1;
    // Calculate the request timeout:
    // Number of Requests * Base Timeout for Request.
    // Let's put the Base Timeout for request as 5 seconds.
    // After the public key has been created we should wait a little bit (it will send confirmation codes to email addresses and these mails should reach the mail boxes). Put this waiting for emails time as 2 seconds.
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    NSArray *userDataList = [self userDataListWithLength:kTestUserDataCount];
    [self createPublicKeyWithUserDataList:userDataList andConfirmUserDataWithHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
        
        XCTAssertNotNil(self.publicKey, @"Public key should be get successfully");
        
        [ex fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test002_getExistingPublicKey {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Public key should be get after creation."];
    
    NSUInteger numberOfRequests = kTestUserDataCount * 3 + 1 + 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    NSArray *userDataList = [self userDataListWithLength:kTestUserDataCount];
    [self createPublicKeyWithUserDataList:userDataList andConfirmUserDataWithHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
        
        [self.keysClient getPublicKeyId:self.publicKey.idb.publicKeyId completionHandler:^(VSSPublicKey *pubKey, NSError *getError) {
            if (getError != nil) {
                XCTFail(@"Error: %@", [getError localizedDescription]);
                return;
            }
            
            self.publicKey = pubKey;
            XCTAssertNotNil(self.publicKey, @"Public key should be get successfully");
            XCTAssertNotNil(self.publicKey.key, @"Actual key data should be returned within Public Key structure.");
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test003_updateExistingPublicKey {
    VSSKeyPair *newKeyPair = [[VSSKeyPair alloc] init];
    
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Public key should be updated after creation."];
    
    NSUInteger numberOfRequests = kTestUserDataCount * 3 + 1 + 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    NSArray *userDataList = [self userDataListWithLength:kTestUserDataCount];
    [self createPublicKeyWithUserDataList:userDataList andConfirmUserDataWithHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
        VSSPrivateKey *pKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
        [self.keysClient updatePublicKeyId:self.publicKey.idb.publicKeyId privateKey:pKey newKeyPair:newKeyPair newKeyPassword:nil completionHandler:^(VSSPublicKey *pubKey, NSError *updateError) {
            if (updateError != nil) {
                XCTFail(@"Error: %@", [updateError localizedDescription]);
                return;
            }
            
            XCTAssertNotEqualObjects(self.publicKey.key, pubKey.key, @"Public key data should be updated.");
            XCTAssertEqualObjects(newKeyPair.publicKey, pubKey.key, @"Updated public key should contain the exact data which was generated in the new key pair.");
            
            [ex fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test004_deleteExistingPublicKey {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"Public key should be deleted after creation."];
    
    NSUInteger numberOfRequests = 1/*create the key*/ + kTestUserDataCount * 3 /*user datas confirm*/ + 1/* delete the key*/ + 1/*try to get the deleted key*/;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;

    NSArray *userDataList = [self userDataListWithLength:kTestUserDataCount];
    [self createPublicKeyWithUserDataList:userDataList andConfirmUserDataWithHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
        
        VSSPrivateKey *pKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
        [self.keysClient deletePublicKeyId:self.publicKey.idb.publicKeyId privateKey:pKey completionHandler:^(VSSActionToken *actionToken, NSError *delError) {
            if (delError != nil) {
                XCTFail(@"Public key should be successfully deleted.");
                return;
            }
            
            // try to get the deleted public key.
            [self.keysClient getPublicKeyId:self.publicKey.idb.publicKeyId completionHandler:^(VSSPublicKey *pubKey, NSError *getError) {
                if (getError != nil) {
                    [ex fulfill];
                    return;
                }
                
                XCTFail(@"Deleted public key should never be returned. Expected business logic error here.");
                return;
            }];
            
        }];
    }];
    
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Expectation failed: %@", error);
        }
    }];
}

- (void)test005_addUserDataToExistingPublicKey {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"User data should be added."];
    
    NSUInteger numberOfRequests = 3 + 1 + 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    NSArray *userDataList = [self userDataListWithLength:1];
    [self createPublicKeyWithUserDataList:userDataList andConfirmUserDataWithHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }
        
        NSArray *userDataList1 = [self userDataListWithLength:1];
        VSSUserDataExtended *ud = [userDataList1[0] as:[VSSUserDataExtended class]];
        VSSPrivateKey *pKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
        [self.keysClient createUserData:ud publicKeyId:self.publicKey.idb.publicKeyId privateKey:pKey completionHandler:^(VSSUserDataExtended *uData, NSError *udError) {
            if (udError != nil) {
                XCTFail(@"User data should be created successfully: %@", [udError localizedDescription]);
                return;
            }
            
            [self.keysClient searchPublicKeyId:self.publicKey.idb.publicKeyId privateKey:pKey completionHandler:^(VSSPublicKey *pubKey, NSError *getError) {
                if (getError != nil) {
                    XCTFail(@"Error: %@", [getError localizedDescription]);
                    return;
                }
                
                XCTAssertTrue(pubKey.userDataList.count - self.publicKey.userDataList.count == 1, @"Public key should now have one additional user data.");

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

- (void)test006_deleteUserDataFromExistingPublicKey {
    XCTestExpectation * __weak ex = [self expectationWithDescription:@"User data should be deleted."];
    
    NSUInteger numberOfRequests = kTestUserDataCount * 3 + 1 + 1 + 1;
    NSTimeInterval timeout = numberOfRequests * kEstimatedRequestCompletionTime + kEstimatedEmailReceivingTime;
    
    NSArray *userDataList = [self userDataListWithLength:2];
    [self createPublicKeyWithUserDataList:userDataList andConfirmUserDataWithHandler:^(NSError *error) {
        if (error != nil) {
            XCTFail(@"Error: %@", [error localizedDescription]);
            return;
        }

        VSSPrivateKey *pKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
        [self.keysClient searchPublicKeyId:self.publicKey.idb.publicKeyId privateKey:pKey completionHandler:^(VSSPublicKey *pubKey, NSError *getError) {
            if (getError != nil) {
                XCTFail(@"Error: %@", [getError localizedDescription]);
                return;
            }
            
            VSSUserDataExtended *ud = [pubKey.userDataList[0] as:[VSSUserDataExtended class]];
            [self.keysClient deleteUserDataId:ud.idb.userDataId publicKeyId:pubKey.idb.publicKeyId privateKey:pKey completionHandler:^(NSError *udError) {
                if (udError != nil) {
                    XCTFail(@"User data should be created successfully: %@", [udError localizedDescription]);
                    return;
                }
                
                [self.keysClient searchPublicKeyId:pubKey.idb.publicKeyId privateKey:pKey completionHandler:^(VSSPublicKey *pubKey1, NSError *getError) {
                    if (getError != nil) {
                        XCTFail(@"Error: %@", [getError localizedDescription]);
                        return;
                    }
                    
                    XCTAssertTrue(pubKey.userDataList.count - pubKey1.userDataList.count == 1, @"Public key should now have one user data less than initially created.");
                    
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

- (NSString *)userDataValue {
    NSString *candidate = [[[NSUUID UUID] UUIDString] lowercaseString];
    NSString *userId = [candidate stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [NSString stringWithFormat:@"%@@mailinator.com", userId];
}

- (VSSUserDataExtended *)userData {
    return [[VSSUserDataExtended alloc] initWithDataClass:UDCUserId dataType:UDTEmail value:[self userDataValue]];
}

- (NSArray *)userDataListWithLength:(NSUInteger)length {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        [list addObject:[self userData]];
    }
    return list;
}

- (NSNumber *)completedConfirmationList:(NSArray *)list {
    NSNumber* completed = @YES;
    for (NSNumber *conf in list) {
        if (![conf boolValue]) {
            return conf;
        }
    }
    return completed;
}

- (void)createPublicKeyWithUserDataList:(NSArray *)userDataList andHandler:(void(^)(NSError *))handler {
    VSSPublicKey *pKey = [[VSSPublicKey alloc] initWithKey:self.keyPair.publicKey userDataList:userDataList];
    VSSPrivateKey *privKey = [[VSSPrivateKey alloc] initWithKey:self.keyPair.privateKey password:nil];
    [self.keysClient createPublicKey:pKey privateKey:privKey completionHandler:^(VSSPublicKey *pubKey, NSError *error) {
        if (error != nil) {
            if (handler != nil) {
                handler(error);
            }
            return;
        }
        
        self.publicKey = pubKey;
        if (handler != nil) {
            handler(nil);
        }
    }];
}

- (void)confirmUserDataOfPublicKey:(VSSPublicKey *)key withHandler:(void(^)(NSError *error))handler {
    // Just some object to use in synchronization
    NSObject *mutex = [[NSObject alloc] init];
    // Create an array of flags to monitor the fact that all user data from the public key's list are comfirmed.
    NSMutableArray *confirmationsList = [[NSMutableArray alloc] initWithCapacity:key.userDataList.count];
    
    for(VSSUserDataExtended *ud in key.userDataList) {
        // Add the flag that userData is not confirmed yet.
        [confirmationsList addObject:@NO];
        // Get the Mailinator inbox name
        NSString *inbox = [ud.value substringToIndex:[ud.value rangeOfString:@"@"].location];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
            // Request the inbox for this user data value from the Mailinator
            [self.mailinator getInbox:inbox completionHandler:^(NSArray *metadataList, NSError *inboxError) {
                if (inboxError != nil) {
                    // We can't get emails list and we can't get confirmation code.
                    // User data will not be confirmed.
                    if (handler != nil) {
                        handler(inboxError);
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
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
                    // Get the email with the code:
                    [self.mailinator getEmail:metadata.mid completionHandler:^(MEmail *email, NSError *emailError) {
                        if (emailError != nil) {
                            // We can't get the email and code.
                            if (handler != nil) {
                                handler(emailError);
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
                        // Send the confirmation
                        [self.keysClient persistUserDataId:ud.idb.userDataId confirmationCode:code completionHandler:^(NSError *keysError) {
                            if (keysError != nil) {
                                // Confirmation failed.
                                if(handler != nil) {
                                    handler(keysError);
                                }
                                return;
                            }
                            // Confirmation successful!
                            NSUInteger index = [key.userDataList indexOfObject:ud];
                            if (index != NSNotFound) {
                                @synchronized(mutex) {
                                    confirmationsList[index] = @YES;
                                }
                            }
                            
                            // Check if all of the user data confirmed - call handler without error, signalling that all is OK.
                            @synchronized(mutex) {
                                NSNumber *num = [self completedConfirmationList:confirmationsList];
                                if ([num boolValue]) {
                                    if (handler != nil) {
                                        handler(nil);
                                    }
                                }
                                
                            }
                        }];
                        
                    }];
                });
            }];
        });
    }
}

- (void)createPublicKeyWithUserDataList:(NSArray *)userDataList andConfirmUserDataWithHandler:(void(^)(NSError *))handler {
    [self createPublicKeyWithUserDataList:userDataList andHandler:^(NSError *error) {
        if (error != nil) {
            if (handler != nil) {
                handler(error);
            }
            return;
        }
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kEstimatedEmailReceivingTime * NSEC_PER_SEC)), queue, ^{
            // At this point public key should be created and confirmation codes should reach the user data inboxes.
            [self confirmUserDataOfPublicKey:self.publicKey withHandler:^(NSError *udError) {
                if (udError != nil) {
                    if (handler != nil) {
                        handler(udError);
                    }
                    return;
                }
                
                if (handler != nil) {
                    handler(nil);
                }
            }];
        });
    }];
}

@end
