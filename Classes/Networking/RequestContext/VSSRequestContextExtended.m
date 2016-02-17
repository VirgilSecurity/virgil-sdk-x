//
//  VSSRequestContextExtended.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 2/10/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSRequestContextExtended.h"
#import "VSSPrivateKey.h"
#import "VSSPublicKey.h"

@interface VSSRequestContextExtended ()

@property (nonatomic, strong, readwrite) VSSPublicKey * __nullable serviceKey;
@property (nonatomic, strong, readwrite) NSNumber * __nullable requestEncrypt;
@property (nonatomic, strong, readwrite) NSNumber * __nullable responseVerify;

@property (nonatomic, strong, readwrite) VSSPrivateKey * __nullable privateKey;
@property (nonatomic, strong, readwrite) GUID * __nullable cardId;
@property (nonatomic, strong, readwrite) NSString * __nullable password;

@end

@implementation VSSRequestContextExtended

@synthesize serviceKey = _serviceKey;
@synthesize requestEncrypt = _requestEncrypt;
@synthesize responseVerify = _responseVerify;

@synthesize privateKey = _privateKey;
@synthesize cardId = _cardId;
@synthesize password = _password;

- (instancetype)initWithServiceUrl:(NSString *)serviceUrl serviceKey:(VSSPublicKey *)serviceKey requestEncrypt:(NSNumber *)requestEncrypt responseVerify:(NSNumber *)responseVerify privateKey:(VSSPrivateKey *)privateKey cardId:(GUID *)cardId password:(NSString *)password {
    self = [super initWithServiceUrl:serviceUrl];
    if (self == nil) {
        return nil;
    }
    
    _serviceKey = serviceKey;
    _requestEncrypt = requestEncrypt;
    _responseVerify = responseVerify;
    _privateKey = privateKey;
    _cardId = cardId;
    _password = password;
    
    return self;
}

- (instancetype)initWithServiceUrl:(NSString *)serviceUrl {
    return [self initWithServiceUrl:serviceUrl serviceKey:nil requestEncrypt:nil responseVerify:nil privateKey:nil cardId:nil password:nil];
}

@end
