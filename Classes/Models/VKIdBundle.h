//
//  VKIdBundle.h
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/11/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <VirgilFrameworkiOS/VFModel.h>

extern NSString *const kVKModelId;
extern NSString *const kVKModelContainerId;
extern NSString *const kVKModelPublicKeyId;
extern NSString *const kVKModelUserDataId;
extern NSString *const kVKModelConfirmed;
extern NSString *const kVKModelPublicKey;
extern NSString *const kVKModelUserData;
extern NSString *const kVKModelActionToken;
extern NSString *const kVKModelUserIDs;
extern NSString *const kVKModelConfirmationCode;
extern NSString *const kVKModelConfirmationCodes;
extern NSString *const kVKModelUUIDSign;

typedef NSString GUID;

@interface VKIdBundle : VFModel

@property (nonatomic, copy, readonly) GUID *containerId;
@property (nonatomic, copy, readonly) GUID *publicKeyId;
@property (nonatomic, copy, readonly) GUID *userDataId;

- (instancetype)initWithContainerId:(GUID *)containerId publicKeyId:(GUID *)publicKeyId userDataId:(GUID *)userDataId NS_DESIGNATED_INITIALIZER;

@end
