//
//  VSSTestsConst.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/24/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

//In order to make this work, substitute appropriate values
@interface VSSTestsConst : NSObject

@property (nonatomic, readonly) NSString * __nonnull apiPublicKeyId;
@property (nonatomic, readonly) NSString * __nonnull apiPrivateKeyBase64;
@property (nonatomic, readonly) NSString * __nonnull apiPublicKeyBase64;
@property (nonatomic, readonly) NSString * __nonnull applicationId;
@property (nonatomic, readonly) NSURL * __nullable serviceURL;
@property (nonatomic, readonly) NSString * __nonnull existentCardId;
@property (nonatomic, readonly) NSString * __nonnull existentCardIdentity;

@property (nonatomic, readonly) NSDictionary * __nonnull config;

@end
