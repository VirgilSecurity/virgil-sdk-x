//
//  VKUserData.m
//  VirgilKeysSDK
//
//  Created by Pavel Gorb on 9/7/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import "VKUserData.h"
#import "VKIdBundle.h"
#import <VirgilFrameworkiOS/VFUserData_Protected.h>
#import <VirgilFrameworkiOS/NSObject+VFUtils.h>

@interface VKUserData ()

@property (nonatomic, copy, readwrite) VKIdBundle *Id;
@property (nonatomic, copy, readwrite) NSNumber *Confirmed;

@end

@implementation VKUserData

@synthesize Id = _Id;
@synthesize Confirmed = _Confirmed;

#pragma mark - Lifecycle

- (instancetype)initWithId:(VKIdBundle *)Id Class:(VFUserDataClass)Class Type:(VFUserDataType)Type Value:(NSString *)Value Confirmed:(NSNumber *)Confirmed {
    self = [super initWithClass:Class Type:Type Value:Value];
    if (self == nil) {
        return nil;
    }

    _Id = [Id copy];
    _Confirmed = [Confirmed copy];
    return self;
}

- (instancetype)initWithUserData:(VKUserData *)userData {
    return [self initWithId:userData.Id Class:userData.Class Type:userData.Type Value:userData.Value Confirmed:userData.Confirmed];
}

- (instancetype)initWithClass:(VFUserDataClass)Class Type:(VFUserDataType)Type Value:(NSString *)Value {
    return [self initWithId:nil Class:Class Type:Type Value:Value Confirmed:@NO];
}

- (instancetype)init {
    return [self initWithId:nil Class:UDCUnknown Type:UDTUnknown Value:nil Confirmed:@NO];
}

#pragma mark - NSCopying protocol implementation

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithId:self.Id Class:self.Class Type:self.Type Value:self.Value Confirmed:self.Confirmed];
}

#pragma mark - NSCoding protocol implementation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VKIdBundle *Id = [[aDecoder decodeObjectForKey:kVKModelId] as:[VKIdBundle class]];
    NSNumber *classCandidate = [[aDecoder decodeObjectForKey:kVFModelClass] as:[NSNumber class]];
    NSNumber *typeCandidate = [[aDecoder decodeObjectForKey:kVFModelType] as:[NSNumber class]];
    NSString *value = [[aDecoder decodeObjectForKey:kVFModelValue] as:[NSString class]];
    NSNumber *confirmed = [[aDecoder decodeObjectForKey:kVKModelConfirmed] as:[NSNumber class]];
    
    return [self initWithId:Id Class:(VFUserDataClass)[classCandidate unsignedIntegerValue] Type:(VFUserDataType)[typeCandidate unsignedIntegerValue] Value:value Confirmed:confirmed];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.ID != nil) {
        [aCoder encodeObject:self.Id forKey:kVKModelId];
    }
    if (self.Confirmed != nil) {
        [aCoder encodeObject:self.Confirmed forKey:kVKModelConfirmed];
    }
}

#pragma mark - VKSerializable

+ (instancetype)deserializeFrom:(NSDictionary *)candidate {
    NSDictionary *idBundle = [candidate[kVKModelId] as:[NSDictionary class]];
    VKIdBundle *Id = [VKIdBundle deserializeFrom:idBundle];

    NSString *classCandidate = [candidate[kVFModelClass] as:[NSString class]];
    NSString *typeCandidate = [candidate[kVFModelType] as:[NSString class]];
    NSString *value = [candidate[kVFModelValue] as:[NSString class]];
    NSNumber *confirmed = [candidate[kVKModelConfirmed] as:[NSNumber class]];
    
    return [[self alloc] initWithId:Id Class:[self userDataClassFromString:classCandidate] Type:[self userDataTypeFromString:typeCandidate] Value:value Confirmed:confirmed];
}

#pragma mark - Overrides 

- (NSNumber *)isValid {
    BOOL valid = NO;
    valid = ( [super isValid] && (self.Id.userDataId.length > 0) );
    return [NSNumber numberWithBool:valid];
}

@end
