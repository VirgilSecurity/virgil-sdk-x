//
//  VSSVirgilApiProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSCardsManagerProtocol.h"
#import "VSSKeysManagerProtocol.h"
#import "VSSIdentitiesManagerProtocol.h"

@protocol VSSVirgilApi <NSObject>

@property (nonatomic, readonly) id<VSSIdentitiesManager> __nonnull Identities;
@property (nonatomic, readonly) id<VSSCardsManager> __nonnull Cards;
@property (nonatomic, readonly) id<VSSKeysManager> __nonnull Keys;

- (NSData * __nullable)encryptData:(NSData * __nonnull)data for:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:for:));
- (NSData * __nullable)encryptString:(NSString * __nonnull)string for:(NSArray<VSSVirgilCard *> * __nonnull)cards error:(NSError * __nullable * __nullable)errorPtr NS_SWIFT_NAME(encrypt(_:for:));

@end
