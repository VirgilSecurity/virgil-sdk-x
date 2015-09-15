## Description

VirgilKeysiOS framework is a wrapper over the Virgil Keys service for iOS applications. This framework has two dependencies:

- VirgilCryptoiOS - this is low-level framework for performing basic security operations such as: creating key pairs, encrypting/decrypting some data and signing/verifying signs.
- VirgilFrameworkiOS - this is a small framework with some useful base classes which is used for other Virgil libraries and applications.

To get started it is necessary to register [here](https://api.virgilsecurity.com/signin), add new application and get an application token. When you have the token, this framework allows you to send requests to the Virgil Keys service.

#### Creating a key pair

```objective-c
#import <VirgilCryptoiOS/VCKeyPair.h>

//...
VCKeyPair *keyPair = [[VCKeyPair alloc] init];
//...
```

Optionally it is possible to create a new key pair protected by some password:

```objective-c
#import <VirgilCryptoiOS/VCKeyPair.h>

//...
VCKeyPair *keyPair = [[VCKeyPair alloc] initWithPassword:<# password #>];
//...
```

#### Creating a new public key with service request

Requests to the service is an asynchronous network operation. VKKeysClient instance send the request and when it is done it calls completion handler block given as last parameter in any call. To get this work VKKeysClient instance should exist when the request is done. It is a good idea to make a property which will hold the VKKeysClient instance.

```objective-c
#import <VirgilCryptoiOS/VCKeyPair.h>
#import <VirgilKeysiOS/VKPublicKey.h>
#import <VirgilKeysiOS/VKUserData.h>
#import <VirgilKeysiOS/VKKeysClient.h>

//...
@property (nonatomic, strong) VKKeysClient *keysClient;
//...
//...
// Create a new key pair
VCKeyPair *keyPair = [[VCKeyPair alloc] init];
// Create a new user data object
VKUserData* userData = [[VKUserData alloc] initWithId:nil Class:UDCUserId Type:UDTEmail Value:<# email address #> Confirmed:nil];
// Create a new public key candidate
VKPublicKey *publicKey = [[VKPublicKey alloc] initWithId:nil Key:pair.publicKey UserDataList:@[ userData ]];
// Create a new instance of the keysClient
self.keysClient = [[VKKeysClient alloc] initWithApplicationToken:<# Virgil Application Token #>];
// Create a requst
[self.keysClient createPublicKey:publicKey privateKey:keyPair.privateKey keyPassword:nil completionHandler:^(VKPublicKey *pubKey, NSError *error) {
	// Each request to the service is executed in a different background thread.
	// This completion handler is called NOT on the main thread.
    if (error != nil) {
        NSLog(@"Error creating public key object: '%@'", [error localizedDescription]);
        return;
    }
        
    // Process received pubKey...
    NSLog(@"Created public key:");
    NSLog(@"account_id: %@", pubKey.Id.containerId);
    NSLog(@"public_key_id: %@", pubKey.Id.publicKeyId);
    NSLog(@"user data attached: %lu", (unsigned long)pubKey.UserDataList.count);
}];
//...
```

## Requirements

Requires iOS 8.x or greater.

## License

Usage is provided under the [The BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause). See LICENSE for the full details.