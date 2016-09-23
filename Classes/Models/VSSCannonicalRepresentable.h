//
//  VSSCannonicalRepresentable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#warning add documentation
@protocol VSSCannonicalRepresentable <NSObject>

+ (instancetype __nullable)createFromCannonicalForm:(NSString * __nonnull)cannonicalForm;

- (NSString * __nonnull)getCannonicalForm;

@end
