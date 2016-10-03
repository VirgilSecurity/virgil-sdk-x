//
//  VSSErrorPrivate.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/30/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSError.h"
#import "VSSDeserializable.h"

@interface VSSError () <VSSDeserializable>

- (instancetype __nonnull)initWithCode:(NSInteger)code NS_DESIGNATED_INITIALIZER;

@end
