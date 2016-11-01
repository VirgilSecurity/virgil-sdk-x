//
//  VSSCanonicalSerializable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

@protocol VSSCanonicalSerializable <NSObject>

- (NSData * __nonnull)getCanonicalForm;

@end
