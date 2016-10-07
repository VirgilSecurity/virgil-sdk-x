//
//  VSSCanonicalDeserializable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/7/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

@protocol VSSCanonicalDeserializable <NSObject>

+ (instancetype __nullable)createFromCanonicalForm:(NSData * __nonnull)canonicalForm;

@end
