//
//  VSSRevokeEmailCardRequest.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 1/25/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSRevokeEmailCardRequest.h"
#import "VSSSignableRequestPrivate.h"
#import "VSSRevokeCardSnapshotModelPrivate.h"
#import "VSSModelKeysPrivate.h"
#import "NSObject+VSSUtils.h"

@implementation VSSRevokeEmailCardRequest

+ (instancetype)revokeEmailCardRequestWithCardId:(NSString *)cardId validationToken:(NSString *)validationToken reason:(VSSCardRevocationReason)reason {
    VSSRevokeCardSnapshotModel *model = [[VSSRevokeCardSnapshotModel alloc] initWithCardId:cardId revocationReason:reason];
    return [[VSSRevokeEmailCardRequest alloc] initWithSnapshotModel:model validationToken:validationToken];
}

- (instancetype)initWithSnapshotModel:(VSSRevokeCardSnapshotModel *)model validationToken:(NSString *)validationToken {
    self = [super initWithSnapshotModel:model];
    
    if (self) {
        _validationToken = [validationToken copy];
    }
    
    return self;
}

- (NSDictionary *)serialize {
    NSMutableDictionary *dict = (NSMutableDictionary *)[super serialize];
    
    NSMutableDictionary *metaDict = dict[kVSSCModelMeta];
    metaDict[kVSSCModelValidation] = @{
        kVSSCModelToken: self.validationToken
    };
    
    return dict;
}

- (instancetype)initWithDict:(NSDictionary *)candidate {
    self = [super initWithDict:candidate];
    
    if (self) {
        NSString *validationToken = [candidate[kVSSCModelMeta][kVSSCModelValidation][kVSSCModelToken] vss_as:[NSString class]];
        
        if (validationToken.length == 0)
            return nil;
        
        _validationToken = [validationToken copy];
    }
    
    return self;
}

@end

