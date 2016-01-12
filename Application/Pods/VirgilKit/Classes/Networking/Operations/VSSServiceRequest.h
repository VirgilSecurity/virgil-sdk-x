//
//  VSSServiceRequest.h
//  VirgilKit
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define USE_SERVICE_REQUEST_DEBUG 1
#endif

/// Debugging macro
#if USE_SERVICE_REQUEST_DEBUG
#  define VFSRDLog(...) NSLog(__VA_ARGS__)
# else
#  define VFSRDLog(...) /* nothing to log */
#endif

@class VSSServiceRequest;

typedef NS_ENUM(NSUInteger, HTTPRequestMethod) {
    GET,
    POST,
    PUT,
    DELETE
};

/**
 * Callback for operation completion.
 */
typedef void (^ServiceRequestCompletionHandler)(VSSServiceRequest * __nonnull request);

/// Default timeout value for the HTTP operations.
extern const NSTimeInterval kVirgilServiceRequestDefaultTimeout;

/// Default HTTP method for HTTP operations.
extern NSString * __nonnull const kVirgilServiceRequestDefaultMethod;

extern NSString * __nonnull const kVirgilServiceRequestErrorDomain;

/// Code for indicating of cancelled HTTP request.
extern const NSInteger kVVirgilServiceRequestCancelledErrorCode;

/// String description of cancelled HTTP request.
extern NSString * __nonnull const kVirgilServiceRequestCancelledErrorDescription;

/**
 * Base class for HTTP requests.
 */
@interface VSSServiceRequest : NSObject

/// Network operation unique identifier;
@property (nonatomic, strong, readonly) NSString * __nonnull uuid;

/// Underlying HTTP request.
@property (nonatomic, strong, readonly) NSURLRequest * __nonnull request;

/// Response for the underlying HTTP request.
@property (nonatomic, strong, readonly) NSHTTPURLResponse * __nullable response;

/// Error description if one occured.
@property (nonatomic, strong, readonly) NSError * __nullable error;

/// HTTP response body data
@property (nonatomic, strong, readonly) NSData * __nullable responseBody;

/// Callback for operation completion.
@property (nonatomic, copy) ServiceRequestCompletionHandler __nullable completionHandler;


/**
 * Initialize HTTP operation with HTTP request target URL. This is designated initializer.
 *
 * @param url Target URL for HTTP request. By default HTTP request method is POST and body is empty.
 * @return Instance of particular network operation.
 */
- (instancetype __nonnull)initWithBaseURL:(NSString * __nonnull)url;

/**
 * Set the HTTP request method.
 *
 * @param method HTTP request method to set.
 */
- (void)setRequestMethod:(HTTPRequestMethod)method;

/**
 * Set the HTTP headers with header name-value pairs derived from the dictionary.
 *
 * @param dict String to String dictionary with key-value pars for the header names and values.
 */
- (void)setRequestHeaders:(NSDictionary * __nonnull)headers;

/**
 * Set the HTTP request body with given data.
 */
- (void)setRequestBody:(NSData * __nonnull)body;

/**
 * Set the HTTP query string using key-value pairs derived from the dictionary.
 *
 * @param dict String to String dictionary with key-value pars for the request query string.
 */
- (void)setRequestQuery:(NSDictionary * __nonnull)params;

/// The following methods are supposed to be overriden in descendants.

/**
 * @return service method name (path to it) which should be called related to service base url.
 */
- (NSString * __nonnull)methodPath;

/**
 * This method is called when underlying request has been done by url session. It returns the object which is derived from the response data.
 * Root implementation returns nil.
 * 
 * @return Some object derived from the response data. NSError in case of parsing error.
 */
- (NSObject * __nullable)parseResponse;

/**
 * This method is called when underlying request has been done by url session after -parseResponse. It takes as parameter the object returned from -parseResponse. If that object contains some logical service error or parsing error - this method should process this error and return it.
 * Descendants should call super.
 *
 * @param candidate NSObject received by call to -parseResponse method.
 * @return NSError in case of any errors inside response data or during the parsing. Otherwise returns nil.
 */
- (NSError * __nullable)handleError:(NSObject * __nullable)candidate;

/**
 * This method is called when underlying request has been done by url session, after -parseResponse and after -handleError. Because of this, parameter of this method should contain coorectly parsed object and it should never be NSError or any kind of logical service error. But even not-error response may sometimes be broken by absence some mandatory params, etc.
 * Descendants should call super and check for error in return value.
 * 
 * @param candidate NSObject received by call to -parseResponse method.
 * @return NSError in case of error during handling the object. Otherwise - nil.
 */
- (NSError * __nullable)handleResponse:(NSObject * __nullable)candidate;

@end
