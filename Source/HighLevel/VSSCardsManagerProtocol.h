//
//  VSSCardsManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCard.h"
#import "VSSVirgilKey.h"
#import "VSSVirgilIdentity.h"

@protocol VSSCardsManager <NSObject>

- (VSSVirgilCard * __nullable)createCardWithIdentity:(VSSVirgilIdentity * __nonnull)identity ownerKey:(VSSVirgilKey * __nonnull)ownerKey data:(NSDictionary<NSString *, NSString *> * __nullable)data error:(NSError * __nullable * __nullable)errorPtr;

- (void)publishCard:(VSSVirgilCard * __nonnull)card completion:(void (^ __nonnull)(NSError * __nullable))callback;

@end
