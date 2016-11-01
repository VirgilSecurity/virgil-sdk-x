//
//  VSSImportable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

/**
 Protocol used for Model Classes which can be imported from NSString representation (previously exported, see VSSExportable)
 */
@protocol VSSImportable <NSObject>

/**
 Initializes instance with NSString representation. (See VSSExportable)

 @param data NSString representation of isntance

 @return initialized instance
 */
- (instancetype __nullable)initWithData:(NSString * __nonnull)data;

@end
