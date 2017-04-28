//
//  MEmailResponse.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MEmailResponse.h"
#import "MEmail.h"

#import "NSObject+VSSUtils.h"

static NSString *const kMERApiInboxFetchesLeft = @"apiInboxFetchesLeft";
static NSString *const kMERApiEmailFetchesLeft = @"apiEmailFetchesLeft";
static NSString *const kMERData = @"data";
static NSString *const kMERForwardsLeft = @"forwardsLeft";

@interface MEmailResponse ()

@property (nonatomic, strong, readwrite) NSNumber * __nonnull apiInboxFetchesLeft;
@property (nonatomic, strong, readwrite) NSNumber * __nonnull apiEmailFetchesLeft;
@property (nonatomic, strong, readwrite) MEmail * __nonnull email;
@property (nonatomic, strong, readwrite) NSNumber * __nonnull forwardsLeft;

@end

@implementation MEmailResponse

@synthesize apiInboxFetchesLeft = _apiInboxFetchesLeft;
@synthesize apiEmailFetchesLeft = _apiEmailFetchesLeft;
@synthesize email = _email;
@synthesize forwardsLeft = _forwardsLeft;

#pragma mark - Lifecycle

- (instancetype)initWithInboxFetchesLeft:(NSNumber *)inboxFetchesLeft emailFetchesLeft:(NSNumber *)emailFetchesLeft email:(MEmail *)email forwardsLeft:(NSNumber *)forwardsLeft {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _apiInboxFetchesLeft = inboxFetchesLeft;
    _apiEmailFetchesLeft = emailFetchesLeft;
    _email = email;
    _forwardsLeft = forwardsLeft;
    return self;
}

- (instancetype)init {
    return [self initWithInboxFetchesLeft:@0 emailFetchesLeft:@0 email:[[MEmail alloc] init] forwardsLeft:@0];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self initWithInboxFetchesLeft:self.apiInboxFetchesLeft emailFetchesLeft:self.apiEmailFetchesLeft email:self.email forwardsLeft:self.forwardsLeft];
}

#pragma mark - VFSerializable

+ (instancetype) deserializeFrom:(NSDictionary *)candidate {
    NSNumber *inboxFetchesLeft = [candidate[kMERApiInboxFetchesLeft] vss_as:[NSNumber class]];
    NSNumber *emailFetchesLeft = [candidate[kMERApiEmailFetchesLeft] vss_as:[NSNumber class]];
    NSDictionary *emailCandidate = [candidate[kMERData] vss_as:[NSDictionary class]];
    MEmail *email = [MEmail deserializeFrom:emailCandidate];
    NSNumber *forwardsLeft = [candidate[kMERForwardsLeft] vss_as:[NSNumber class]];
    
    return [[self alloc] initWithInboxFetchesLeft:inboxFetchesLeft emailFetchesLeft:emailFetchesLeft email:email forwardsLeft:forwardsLeft];
}

@end
