//
//  VSSBaseClient.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 5/23/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#ifdef DEBUG
#define USE_SERVICE_CLIENT_DEBUG 1
#endif

/// Debugging macro
#if USE_SERVICE_CLIENT_DEBUG
#  define VSSCLDLog(...) NSLog(__VA_ARGS__)
# else
#  define VSSCLDLog(...) /* nothing to log */
#endif

/**
 Base class for all Clients.
 */
@interface VSSBaseClient : NSObject

@end
