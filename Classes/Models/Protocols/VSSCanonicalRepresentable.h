//
//  VSSCanonicalRepresentable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#warning add documentation
@protocol VSSCanonicalRepresentable <NSObject>

+ (instancetype __nullable)createFromCanonicalForm:(NSString * __nonnull)canonicalForm;

- (NSString * __nonnull)getCanonicalForm;

@end
