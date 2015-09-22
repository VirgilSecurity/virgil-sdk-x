## Description

VirgilKeysiOS framework is a wrapper over the Virgil Keys service for iOS applications. It allows user to interact with Virgil Keys service much easier. This framework takes care about composing correct requests and parsing the service's responds into usable model classes.  

## Getting started

VirgilKeysiOS framework is supposed to be installed via CocoaPods. So, if you are not familiar with it it is time to install CocoaPods. Open your terminal window and execute the following line:
```
$ sudo gem install cocoapods
``` 
It will ask you about the password and then will install latest release version of CocoaPods. CocoaPods is built with Ruby and it will be installable with the default Ruby available on OS X.

If you encountered any issues during this installation, please take a look at [cocoapods.org](https://guides.cocoapods.org/using/getting-started.html) for more information.

VirgilKeysiOS framework has 2 dependencies:
 
- VirgilCryptoiOS - this is low-level framework for performing basic security operations such as: creating key pairs, encrypting/decrypting some data and signing/verifying signs.
- VirgilFrameworkiOS - this is a small framework with some base classes which is also used for other Virgil libraries and applications.

You don't need to install any of them manually. CocoaPods will handle it for you automatically.

Now it is possible to add VirgilKeysiOS to the particular application. So:

- Open Xcode and create a new project (in the Xcode menu: File->New->Project), or navigate to existing Xcode project using:

```
$ cd <Path to Xcode project folder>
```

- In the Xcode project's folder create a new file, give it a name *Podfile* (with a capital *P* and without any extension). Put the following lines in the Podfile and save it.

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
pod 'VirgilKeysiOS'
```

- Get back to your terminal window and execute the following line:

```
$ pod install
```
 
- Close Xcode project (if it is still opened). For any further development purposes you should use Xcode *.xcworkspace* file created for you by CocoaPods.
 
At this point you should be able to use VirgilKeys functionality in your code. See examples for most common tasks below.
If you encountered any issues with CocoaPods installations try to find more information at [cocoapods.org](https://guides.cocoapods.org/using/getting-started.html).

##### Swift note
Although VirgilKeys is using Objective-C as its primary language it might be quite easily used in a Swift application.
After VirgilKeys is installed as described in the *Getting started* section it is necessary to perform the following:

- Create a new header file in the Swift project.

- Name it something like *BridgingHeader.h*

- Put there the following line:
``` objective-c
#import <VirgilKeysiOS/VirgilKeysiOS.h>
```

- In the Xcode build settings find the setting called *Objective-C Bridging Header* and set the path to your *BridgingHeader.h* file. Be aware that this path is relative to your Xcode project's folder. After adding bridging header setting you should be able to use the framework.

You can find more information about using Objective-C and Swift in the same project [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).

## Virgil Application token

Before you make any calls to the Virgil Keys Service you need to obtain an application token. Please, register [here](https://api.virgilsecurity.com/signin) or sign in if you already have an account.

After signing in press *Register an application* button and fill required fields. When it is done you should be able to copy a generated application token. This token is necessary for making any calls to the Virgil Keys Service. 

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

#### Creating a new public key at the Virgil Keys Service

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
VKUserData* userData = [[VKUserData alloc] initWithIdb:nil dataClass:UDCUserId dataType:UDTEmail value:<# email address #> confirmed:nil];
// Create a new public key candidate
VKPublicKey *publicKey = [[VKPublicKey alloc] initWithIdb:nil key:pair.publicKey userDataList:@[ userData ]];
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

#### Getting a public key associated with a particular email address

```objective-c
#import <VirgilKeysiOS/VKPublicKey.h>
#import <VirgilKeysiOS/VKKeysClient.h>

//...
@property (nonatomic, strong) VKKeysClient *keysClient;
//...
//...
// Assuming that keysClient was instantiated at some point before. If not - see 'Creating a new public key at the Virgil Keys Service' example.
// Send a request
[self.keysClient searchPublicKeyUserIdValue:<# Email address #> completionHandler:^(VKPublicKey *pubKey, NSError *error) {
	// Each request to the service is executed in a different background thread.
	// This completion handler is called NOT on the main thread.
    if (error != nil) {
        NSLog(@"Error getting public key object: '%@'", [error localizedDescription]);
        return;
    }
        
    // Process received pubKey... 
    NSLog(@"Got the public key:");
    NSLog(@"account_id: %@", pubKey.idb.containerId);
    NSLog(@"public_key_id: %@", pubKey.idb.publicKeyId);
    NSLog(@"%@", [[NSString alloc] initWithData:pubKey.key encoding:NSUTF8StringEncoding]);
}];
//...
```

#### Encryption and decryption

When the user wants to send a private message which can be read only by recipient, the user need to get the public key of the recepient as descrbed in section *Creating a new public key at the Virgil Keys Service*. When the public key is received it is possible to encrypt the private message with this key.

```objective-c
//...
#import <VirgilCryptoiOS/VCCryptor.h>
//...

// Assuming that we have some initial private string message.
NSString *message = @"This is a secret message which should be encrypted.";
// Convert it to the NSData
NSData *toEncrypt = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
// Assuming that we have received a recepient's public key from the Virgil Keys Service.
// So, VKPublicKey *recepientKey exists.

// Create a new VCCryptor instance
VCCryptor *cryptor = [[VCCryptor alloc] init];
// Now we should add a key recepient (recepientKey is a VKPublicKey instance received from the Virgil Keys Service)
[cryptor addKeyRecepient:recepientKey.idb.publicKeyId publicKey:recepientKey.key];
// And now we can easily encrypt the plain data
NSData *encryptedData = [cryptor encryptData:toEncrypt embedContentInfo:@YES];
// Now it is safe to send encryptedData to the recepient. Only person who holds the private key which corresponds to the recepientKey.Key public key is able to decrypt and read this data.
```

In case when a user needs to decrypt received encrypted message he/she needs to hold a private key which corresponds to the public key used to encrypt the data.  

```objective-c
//...
#import <VirgilCryptoiOS/VCCryptor.h>
//...

// Assuming that we have received some data encrypted using our public key from the Virgil Keys Service.
// So NSData *encryptedData exists.
// Assuming that we got VKPublicKey instance of our public key from the Virgil Keys Service.
// So VKPublicKey *myPublicKey exists.
// Assuming that we have our private key which corresponds the public key from the Virgil Keys Service.
// So NSData *myPrivateKey exists.
// Create a new VCCryptor instance
VCCryptor *decryptor = [[VCCryptor alloc] init];
// Decrypt data
NSData *plainData = [decryptor decryptData:<#encryptedData#> publicKeyId:<#myPublicKey.idb.publicKeyId#> privateKey:<#myPrivateKey#> keyPassword:<# Private key password or nil #>];
// Compose initial message from the plain decrypted data
NSString *initialMessage = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
```

#### Signing a data using a private key

Although it is possible to send an encrypted message to some particular recipient, it is still important to make the recepient sure that this encrypted message is sent exactly by you. This can be achieved with a concept of a signatures. 

Signature is a piece of data which is composed using a particular user's private key and it can be validated later using this user's public key.

```objective-c
//...
#import <VirgilCryptoiOS/VCSigner.h>
//...

// Assuming that we have some initial string message that we want to sign.
NSString *message = @"This is a message which should be signed.";
// Convert it to the NSData
NSData *toSign = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
// Assuming that we have our private key.
// So NSData *myPrivateKey exists.
// Create a new VCSigner instance
VCSigner *signer = [[VCSigner alloc] init];
// Sign the initial data
NSData *signature = [signer signData:toSign privateKey:<#myPrivateKey#> keyPassword:<# Private key password or nil #>];
if (signature.length > 0) {
    // Use composed signature data to make recipient sure about the sender identity.
}
``` 

#### Verifying a signature

To verify some signature it is necessary to get a sender's public key from the Virgil Keys Service, as described in section 'Getting a public key associated with a particular email address'. 

```objective-c
//...
#import <VirgilCryptoiOS/VCSigner.h>
//...

// Assuming that we get the public key of the user whose signature we need to verify from the Virgil Keys Service
// So VKPublicKey *senderKey exists.
// Assuming that we have a NSData object which was actually signed.
// So NSData *signedMessageData exists.
// Assuming that we have a NSData object with a signature.
// So NSData *signature exists.
// Create a new VCSigner instance
VCSigner *verifier = [[VCSigner alloc] init];
// Verify signature against the signed data and sender's public key.
BOOL verified = [verifier verifyData:<#signedMessageData#> sign:<#signature#> publicKey:<#senderKey.key#>];
if (verified) {
    // Sender is the real holder of the private key, so it might be trusted.
}
```

## Requirements

Requires iOS 8.x or greater.

## License

Usage is provided under the [The BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause). See LICENSE for the full details.