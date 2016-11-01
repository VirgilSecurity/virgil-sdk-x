//
//  VSSExportable.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/13/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

/**
 Protocol used for Model Classes which can be exported to NSString representation (and then imported, see VSSImportable)
 */
@protocol VSSExportable <NSObject>

/**
 Exports instance to NSString representation (See VSSImportable)

 @return NSString representation of instance
 */
- (NSString * __nonnull)exportData;

@end
