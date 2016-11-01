//
//  VSSSerializable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/23/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

@protocol VSSSerializable <NSObject>

- (NSDictionary * __nonnull)serialize;

@end
