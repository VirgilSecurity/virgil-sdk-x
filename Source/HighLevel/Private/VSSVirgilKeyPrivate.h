//
//  VSSVirgilKeyPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/11/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilKey.h"
#import "VSSKeyPair.h"

@interface VSSVirgilKey ()

@property (nonatomic) NSString * __nonnull keyName;

- (instancetype __nonnull)initWithName:(NSString * __nonnull)name keyPair:(VSSKeyPair * __nonnull)keyPair;

@end
