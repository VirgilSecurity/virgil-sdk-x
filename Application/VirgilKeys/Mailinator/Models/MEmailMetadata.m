//
//  MMessage.m
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "MEmailMetadata.h"
#import <VirgilFrameworkiOS/NSObject+VSSUtils.h>

static NSString *const kMSecondsAgo = @"seconds_ago";
static NSString *const kMId = @"id";
static NSString *const kMTo = @"to";
static NSString *const kMTime = @"time";
static NSString *const kMSubject = @"subject";
static NSString *const kMFromFull = @"fromfull";
static NSString *const kMBeenRead = @"been_read";
static NSString *const kMFrom = @"from";
static NSString *const kMIp = @"ip";

@interface MEmailMetadata()

@property (nonatomic, strong, readwrite) NSNumber *seconds_ago;
@property (nonatomic, strong, readwrite) NSString *mid;
@property (nonatomic, strong, readwrite) NSString *to;
@property (nonatomic, strong, readwrite) NSNumber *time;
@property (nonatomic, strong, readwrite) NSString *subject;
@property (nonatomic, strong, readwrite) NSString *fromfull;
@property (nonatomic, strong, readwrite) NSNumber *been_read;
@property (nonatomic, strong, readwrite) NSString *from;
@property (nonatomic, strong, readwrite) NSString *ip;

@end

@implementation MEmailMetadata

@synthesize seconds_ago = _seconds_ago;
@synthesize mid = _mid;
@synthesize to = _to;
@synthesize time = _time;
@synthesize subject = _subject;
@synthesize fromfull = _fromfull;
@synthesize been_read = _been_read;
@synthesize from = _from;
@synthesize ip = _ip;

#pragma mark - Lifecycle

- (instancetype)initWithMid:(NSString *)mid subject:(NSString *)subject from:(NSString *)from to:(NSString *)to time:(NSNumber *)time beenRead:(NSNumber *)beenRead fromfull:(NSString *)fromfull secondsAgo:(NSNumber *)secondsAgo ip:(NSString *)ip {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _mid = mid;
    _subject = subject;
    _from = from;
    _to = to;
    _time = time;
    _been_read = beenRead;
    _fromfull = fromfull;
    _seconds_ago = secondsAgo;
    _ip = ip;
    return self;
}

- (instancetype)init {
    return [self initWithMid:nil subject:nil from:nil to:nil time:nil beenRead:nil fromfull:nil secondsAgo:nil ip:nil];
}

#pragma mark - NSCopying 

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self initWithMid:[self.mid copy] subject:[self.subject copy] from:[self.from copy] to:[self.to copy] time:[self.time copy] beenRead:[self.been_read copy] fromfull:[self.fromfull copy] secondsAgo:[self.seconds_ago copy] ip:[self.ip copy]];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSNumber *seconds_ago = [[aDecoder decodeObjectForKey:kMSecondsAgo] as:[NSNumber class]];
    NSString *mid = [[aDecoder decodeObjectForKey:kMId] as:[NSString class]];
    NSString *to = [[aDecoder decodeObjectForKey:kMTo] as:[NSString class]];
    NSNumber *time = [[aDecoder decodeObjectForKey:kMTime] as:[NSNumber class]];
    NSString *subject = [[aDecoder decodeObjectForKey:kMSubject] as:[NSString class]];
    NSString *fromfull = [[aDecoder decodeObjectForKey:kMFromFull] as:[NSString class]];
    NSNumber *been_read = [[aDecoder decodeObjectForKey:kMBeenRead] as:[NSNumber class]];
    NSString *from = [[aDecoder decodeObjectForKey:kMFrom] as:[NSString class]];
    NSString *ip = [[aDecoder decodeObjectForKey:kMIp] as:[NSString class]];
    
    return [self initWithMid:mid subject:subject from:from to:to time:time beenRead:been_read fromfull:fromfull secondsAgo:seconds_ago ip:ip];
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.mid != nil) {
        [aCoder encodeObject:self.mid forKey:kMId];
    }
    if (self.subject != nil) {
        [aCoder encodeObject:self.subject forKey:kMSubject];
    }
    if (self.from != nil) {
        [aCoder encodeObject:self.from forKey:kMFrom];
    }
    if (self.to != nil) {
        [aCoder encodeObject:self.to forKey:kMTo];
    }
    if (self.time != nil) {
        [aCoder encodeObject:self.time forKey:kMTime];
    }
    if (self.been_read != nil) {
        [aCoder encodeObject:self.been_read forKey:kMBeenRead];
    }
    if (self.fromfull != nil) {
        [aCoder encodeObject:self.fromfull forKey:kMFromFull];
    }
    if (self.seconds_ago != nil) {
        [aCoder encodeObject:self.seconds_ago forKey:kMSecondsAgo];
    }
    if (self.ip != nil) {
        [aCoder encodeObject:self.ip forKey:kMIp];
    }
}

#pragma mark - VFSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSNumber *seconds_ago = [candidate[kMSecondsAgo] as:[NSNumber class]];
    NSString *mid = [candidate[kMId] as:[NSString class]];
    NSString *to = [candidate[kMTo] as:[NSString class]];
    NSNumber *time = [candidate[kMTime] as:[NSNumber class]];
    NSString *subject = [candidate[kMSubject] as:[NSString class]];
    NSString *fromfull = [candidate[kMFromFull] as:[NSString class]];
    NSNumber *been_read = [candidate[kMBeenRead] as:[NSNumber class]];
    NSString *from = [candidate[kMFrom] as:[NSString class]];
    NSString *ip = [candidate[kMIp] as:[NSString class]];
    
    return [[self alloc] initWithMid:mid subject:subject from:from to:to time:time beenRead:been_read fromfull:fromfull secondsAgo:seconds_ago ip:ip];
}

#pragma mark - Overrides

- (NSNumber *)isValid {
    return @(self.mid.length > 0);
}

@end
