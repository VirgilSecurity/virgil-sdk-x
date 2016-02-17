//
//  VSSConfirmIdentityRequest.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/16/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSConfirmIdentityRequest.h"
#import "VSSIdentity.h"
#import "VSSModelCommons.h"
#import "NSObject+VSSUtils.h"

@interface VSSConfirmIdentityRequest ()

@property (nonatomic, assign, readwrite) VSSIdentityType type;
@property (nonatomic, strong, readwrite) NSString * __nullable value;
@property (nonatomic, strong, readwrite) NSString * __nullable validationToken;

@end

@implementation VSSConfirmIdentityRequest

@synthesize type = _type;
@synthesize value = _value;
@synthesize validationToken = _validationToken;

- (instancetype)initWithContext:(VSSRequestContext *)context actionId:(GUID *)actionId code:(NSString *)code ttl:(NSNumber *)ttl ctl:(NSNumber *)ctl {
    self = [super initWithContext:context];
    if (self == nil) {
        return nil;
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    
    if (actionId.length > 0) {
        body[kVSSModelActionId] = actionId;
    }
    if (code.length > 0) {
        body[kVSSModelConfirmationCode] = code;
    }
    NSMutableDictionary *token = [[NSMutableDictionary alloc] init];
    if (ttl != nil) {
        token[kVSSModelTTL] = ttl;
    }
    if (ctl != nil) {
        token[kVSSModelCTL] = ctl;
    }
    if (token.count > 0) {
        body[kVSSModelToken] = token;
    }
    
    [self setRequestBodyWithObject:body];
    return self;
}

- (instancetype)initWithContext:(VSSRequestContext *)context {
    return [self initWithContext:context actionId:@"" code:@"" ttl:nil ctl:nil];
}

#pragma mark - Overrides

- (NSString *)methodPath {
    return @"confirm";
}

- (NSError *)handleResponse:(NSObject *)candidate {
    NSError *error = [super handleResponse:candidate];
    if (error != nil) {
        return error;
    }
    
    NSDictionary *confirmed = [candidate as:[NSDictionary class]];
    self.type = [VSSIdentity identityTypeFromString:[confirmed[kVSSModelType] as:[NSString class]]];
    self.value = [confirmed[kVSSModelValue] as:[NSString class]];
    self.validationToken = [confirmed[kVSSModelValidationToken] as:[NSString class]];
    return nil;
}

@end
