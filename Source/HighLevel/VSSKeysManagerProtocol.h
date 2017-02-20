//
//  VSSKeysManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilKey.h"

@protocol VSSKeysManager <NSObject>

//VirgilKey Generate();

/// <summary>
/// Loads the <see cref="VirgilKey"/> from current storage by specified key name.
/// </summary>
/// <param name="keyName">The name of the Key.</param>
/// <param name="keyPassword">The Key password.</param>
/// <returns>An instance of <see cref="VirgilKey"/> class.</returns>
/// <exception cref="ArgumentException"></exception>
/// <exception cref="VirgilKeyIsNotFoundException"></exception>
//VirgilKey Load(string keyName, string keyPassword = null);

/// <summary>
/// Removes the <see cref="VirgilKey"/> from the storage.
/// </summary>
//void Destroy(string keyName);

@end
