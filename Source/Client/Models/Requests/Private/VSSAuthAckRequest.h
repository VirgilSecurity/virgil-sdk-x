//
//  VSSAuthAckRequest.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 3/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSModelCommons.h"
#import "VSSSerializable.h"
#import "VSSBaseModel.h"

@interface VSSAuthAckRequest : VSSBaseModel <VSSSerializable>

@property (nonatomic, copy, readonly) NSData * __nonnull encryptedMessage;

- (instancetype __nonnull)initWithEncryptedMesasge:(NSData * __nonnull)encryptedMessage;

- (instancetype __nonnull)init NS_UNAVAILABLE;

@end
