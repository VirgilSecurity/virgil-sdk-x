//
//  VSSCard.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/27/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCardPrivate.h"
#import "VSSCardResponsePrivate.h"

@implementation VSSCard

- (instancetype)initWithDict:(NSDictionary *)candidate {
    VSSCardResponse *response = [[VSSCardResponse alloc] initWithDict:candidate];
    
    if (response == nil) {
        return nil;
    }
    
    return [self initWithCardResponse:response];
}

- (instancetype)initWithCardResponse:(VSSCardResponse *)cardResponse {
    self = [super init];
    if (self) {
        _identifier = [cardResponse.identifier copy];
        _identity = [cardResponse.model.identity copy];
        _identityType = [cardResponse.model.identityType copy];
        _publicKeyData = [cardResponse.model.publicKeyData copy];
        _scope = cardResponse.model.scope;
        if (cardResponse.model.data != nil)
            _data = [[NSDictionary alloc] initWithDictionary:cardResponse.model.data copyItems:YES];
        if (cardResponse.model.info != nil)
            _info = [[NSDictionary alloc] initWithDictionary:cardResponse.model.info copyItems:YES];
        _createdAt = [cardResponse.createdAt copy];
        _cardVersion = [cardResponse.cardVersion copy];
        _relations = [[NSArray alloc] initWithArray:cardResponse.relations.allKeys copyItems:YES];
        _cardResponse = cardResponse;
    }
    
    return self;
}

- (instancetype)initWithData:(NSString *)data {
    NSData *jsonData = [[NSData alloc] initWithBase64EncodedString:data options:0];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error != nil || dict == nil)
        return nil;
    
    VSSCardResponse *cardResponse = [[VSSCardResponse alloc] initWithDict:dict];
    
    if (cardResponse == nil)
        return nil;
    
    return [[self.class alloc] initWithCardResponse:cardResponse];
}

- (NSString *)exportData {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self.cardResponse serialize] options:0 error:nil];
    return [jsonData base64EncodedStringWithOptions:0];
}

@end
