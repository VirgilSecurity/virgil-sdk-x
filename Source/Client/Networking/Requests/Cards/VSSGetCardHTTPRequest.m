//
//  VSSGetCardHTTPRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/6/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSError.h"
#import "VSSGetCardHTTPRequest.h"
#import "VSSCardResponsePrivate.h"
#import "NSObject+VSSUtils.h"

@interface VSSGetCardHTTPRequest ()

@property (nonatomic, copy, readonly) NSString * __nonnull cardId;

@property (nonatomic, readwrite) VSSCardResponse * __nullable cardResponse;

@end

@implementation VSSGetCardHTTPRequest

- (instancetype)initWithContext:(VSSHTTPRequestContext *)context cardId:(NSString *)cardId {
    self = [super initWithContext:context];
    if (self) {
        _cardId = [cardId copy];
        
        [self setRequestMethod:GET];
    }
    return self;
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return [[NSString alloc] initWithFormat:@"card/%@", self.cardId];
}

- (NSError *)handleError:(NSObject *)candidate code:(NSInteger)code {
    NSError *error = [super handleError:candidate code:code];
    if (error != nil) {
        return error;
    }
    

    if (code == 404) {
        return [[NSError alloc] initWithDomain:kVSSVirgilServiceErrorDomain code:404 userInfo:@{ NSLocalizedDescriptionKey: @"Card not found" }];
    }
    return nil;
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }

    /// Deserialize actual card
    self.cardResponse = [[VSSCardResponse alloc] initWithDict:[candidate vss_as:[NSDictionary class]]];
    
    return nil;
}

@end
