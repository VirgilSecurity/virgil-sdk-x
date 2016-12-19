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

@property (nonatomic, readonly) NSString * __nonnull applicationToken;
@property (nonatomic, readonly) NSString * __nonnull applicationPublicKeyBase64;
@property (nonatomic, readonly) NSString * __nonnull applicationPrivateKeyBase64;
@property (nonatomic, readonly) NSString * __nonnull applicationPrivateKeyPassword;
@property (nonatomic, readonly) NSString * __nonnull applicationIdentityType;
@property (nonatomic, readonly) NSString * __nonnull applicationId;
@property (nonatomic, readonly) NSString * __nonnull mailinatorToken;

@end
