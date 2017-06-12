//
//  VSSBaseClient.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSBaseClient.h"
#import "VSSHTTPRequest.h"

/**
 Base class for all Clients.
 */
@interface VSSBaseClient : NSObject

@property (nonatomic) NSOperationQueue * __nonnull queue;
@property (nonatomic) NSURLSession * __nonnull urlSession;

- (void)send:(VSSHTTPRequest * __nonnull)request;

@end
