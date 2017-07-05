//
//  PrivateApiDecl.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/26/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

@import VirgilSDK;

@interface VSSCardResponse ()

- (VSSCard * __nonnull)buildCard;

- (instancetype __nullable)initWithDict:(NSDictionary * __nonnull)candidate;

@end

