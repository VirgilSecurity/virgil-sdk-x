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

@property (nonatomic, readonly) NSString * __nonnull accessPublicKeyId;
@property (nonatomic, readonly) NSString * __nonnull accessPrivateKeyBase64;
@property (nonatomic, readonly) NSString * __nonnull accessPublicKeyBase64;
@property (nonatomic, readonly) NSString * __nonnull applicationId;
@property (nonatomic, readonly) NSString * __nonnull serviceURL;

@property (nonatomic, readonly) NSDictionary * __nullable config;

@end
