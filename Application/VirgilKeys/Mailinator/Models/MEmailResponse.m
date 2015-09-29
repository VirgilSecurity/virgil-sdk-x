//
//  MEmailResponse.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MEmailResponse.h"
#import "MEmail.h"

#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

static NSString *const kMERApiInboxFetchesLeft = @"apiInboxFetchesLeft";
static NSString *const kMERApiEmailFetchesLeft = @"apiEmailFetchesLeft";
static NSString *const kMERData = @"data";
static NSString *const kMERForwardsLeft = @"forwardsLeft";

@interface MEmailResponse ()

@property (nonatomic, strong, readwrite) NSNumber *apiInboxFetchesLeft;
@property (nonatomic, strong, readwrite) NSNumber *apiEmailFetchesLeft;
@property (nonatomic, strong, readwrite) MEmail *email;
@property (nonatomic, strong, readwrite) NSNumber *forwardsLeft;

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
    return [self initWithInboxFetchesLeft:nil emailFetchesLeft:nil email:nil forwardsLeft:nil];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self initWithInboxFetchesLeft:self.apiInboxFetchesLeft emailFetchesLeft:self.apiEmailFetchesLeft email:self.email forwardsLeft:self.forwardsLeft];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSNumber *inboxFetchesLeft = [[aDecoder decodeObjectForKey:kMERApiInboxFetchesLeft] as:[NSNumber class]];
    NSNumber *emailFetchesLeft = [[aDecoder decodeObjectForKey:kMERApiEmailFetchesLeft] as:[NSNumber class]];
    MEmail *email = [[aDecoder decodeObjectForKey:kMERData] as:[MEmail class]];
    NSNumber *forwardsLeft = [[aDecoder decodeObjectForKey:kMERForwardsLeft] as:[NSNumber class]];
    
    return [self initWithInboxFetchesLeft:inboxFetchesLeft emailFetchesLeft:emailFetchesLeft email:email forwardsLeft:forwardsLeft];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.apiInboxFetchesLeft != nil) {
        [aCoder encodeObject:self.apiInboxFetchesLeft forKey:kMERApiInboxFetchesLeft];
    }
    if (self.apiEmailFetchesLeft != nil) {
        [aCoder encodeObject:self.apiEmailFetchesLeft forKey:kMERApiEmailFetchesLeft];
    }
    if (self.email != nil) {
        [aCoder encodeObject:self.email forKey:kMERData];
    }
    if (self.forwardsLeft != nil) {
        [aCoder encodeObject:self.forwardsLeft forKey:kMERForwardsLeft];
    }
}

#pragma mark - VFSerializable

+ (instancetype) deserializeFrom:(NSDictionary *)candidate {
    NSNumber *inboxFetchesLeft = [candidate[kMERApiInboxFetchesLeft] as:[NSNumber class]];
    NSNumber *emailFetchesLeft = [candidate[kMERApiEmailFetchesLeft] as:[NSNumber class]];
    NSDictionary *emailCandidate = [candidate[kMERData] as:[NSDictionary class]];
    MEmail *email = [MEmail deserializeFrom:emailCandidate];
    NSNumber *forwardsLeft = [candidate[kMERForwardsLeft] as:[NSNumber class]];
    
    return [[self alloc] initWithInboxFetchesLeft:inboxFetchesLeft emailFetchesLeft:emailFetchesLeft email:email forwardsLeft:forwardsLeft];
}

#pragma mark - Overrides

- (NSNumber *)isValid {
    return [self.email isValid];
}

@end
