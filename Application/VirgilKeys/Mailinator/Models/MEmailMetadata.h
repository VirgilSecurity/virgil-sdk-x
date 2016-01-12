//
//  MEmailMetadata.h
//  VirgilKeys
//
//  Created by Pavel Gorb on 9/23/15.
//  Copyright (c) 2015 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VirgilKit/VSSModel.h>

//{
//    "seconds_ago":475,
//    "id":"1443020156-39224991-virgil099",
//    "to":"virgil099@mailinator.com",
//    "time":1443020156801,
//    "subject":"test system",
//    "fromfull":"virgil.orbitum@gmail.com",
//    "been_read":false,
//    "from":"Pavlo Gorb",
//    "ip":"38.7.248.176"
//}

@interface MEmailMetadata : VSSModel

@property (nonatomic, strong, readonly) NSNumber *seconds_ago;
@property (nonatomic, strong, readonly) NSString *mid;
@property (nonatomic, strong, readonly) NSString *to;
@property (nonatomic, strong, readonly) NSNumber *time;
@property (nonatomic, strong, readonly) NSString *subject;
@property (nonatomic, strong, readonly) NSString *fromfull;
@property (nonatomic, strong, readonly) NSNumber *been_read;
@property (nonatomic, strong, readonly) NSString *from;
@property (nonatomic, strong, readonly) NSString *ip;

- (instancetype)initWithMid:(NSString *)mid subject:(NSString *)subject from:(NSString *)from to:(NSString *)to time:(NSNumber *)time beenRead:(NSNumber *)beenRead fromfull:(NSString *)fromfull secondsAgo:(NSNumber *)secondsAgo ip:(NSString *)ip NS_DESIGNATED_INITIALIZER;

@end
