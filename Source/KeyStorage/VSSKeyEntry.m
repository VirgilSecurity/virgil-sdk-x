//
//  VSSKeyEntry.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 11/2/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import "VSSKeyEntry.h"

NSString *const kVSSKeyEntryName = @"name";
NSString *const kVSSKeyEntryValue = @"value";
NSString *const kVSSKeyEntryMeta = @"meta";

@interface VSSKeyEntry () <NSCoding>

- (instancetype __nonnull)initWithName:(NSString * __nonnull)name value:(NSData * __nonnull)value meta:(NSDictionary<NSString *, NSString *> * __nullable)meta;

@end

@implementation VSSKeyEntry

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectOfClass:[NSString class] forKey:kVSSKeyEntryName];
        _value = [coder decodeObjectOfClass:[NSData class] forKey:kVSSKeyEntryValue];
        _meta = [coder decodeObjectOfClass:[NSDictionary class] forKey:kVSSKeyEntryMeta];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:kVSSKeyEntryName];
    [coder encodeObject:self.value forKey:kVSSKeyEntryValue];
    [coder encodeObject:self.meta forKey:kVSSKeyEntryMeta];
}

- (instancetype)initWithName:(NSString *)name value:(NSData *)value meta:(NSDictionary<NSString *, NSString *> *)meta {
    self = [super init];
    if (self) {
        _name = [name copy];
        _value = [value copy];
        _meta = [meta copy];
    }
    
    return self;
}

+ (VSSKeyEntry *)keyEntryWithName:(NSString *)name value:(NSData *)value meta:(NSDictionary<NSString *, NSString *> *)meta {
    return [[VSSKeyEntry alloc] initWithName:name value:value meta:meta];
}

+ (VSSKeyEntry * __nonnull)keyEntryWithName:(NSString * __nonnull)name value:(NSData * __nonnull)value {
    return [VSSKeyEntry keyEntryWithName:name value:value meta:nil];
}

@end
