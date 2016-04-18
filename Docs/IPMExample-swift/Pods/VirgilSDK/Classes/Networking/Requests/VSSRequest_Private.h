//
//  VSSRequest_Private.h
//  VirgilSDK
//
//  Created by Pavel Gorb on 1/12/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequest.h"

@interface VSSRequest ()

@property (nonatomic, strong) NSURLRequest * __nonnull request;
@property (nonatomic, strong) NSHTTPURLResponse * __nullable response;
@property (nonatomic, strong) NSError * __nullable error;
@property (nonatomic, strong) NSData * __nullable responseBody;

@end
