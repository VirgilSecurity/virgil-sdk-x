//
//  VSSCanonicalRepresentable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

@protocol VSSCanonicalRepresentable <NSObject>

+ (instancetype __nullable)createFromCanonicalForm:(NSData * __nonnull)canonicalForm;

- (NSData * __nonnull)getCanonicalForm;

@end
