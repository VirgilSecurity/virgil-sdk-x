![VirgilSDK](https://cloud.githubusercontent.com/assets/6513916/19643783/bfbf78be-99f4-11e6-8d5a-a43394f2b9b2.png)

[![Build Status](https://api.travis-ci.org/VirgilSecurity/virgil-sdk-x.svg?branch=master)](https://travis-ci.org/VirgilSecurity/virgil-sdk-x)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilSDK.svg)](https://img.shields.io/cocoapods/v/VirgilSDK.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/VirgilSDK.svg?style=flat)](http://cocoadocs.org/docsets/VirgilSDK)
[![codecov.io](https://codecov.io/github/VirgilSecurity/virgil-sdk-x/coverage.svg)](https://codecov.io/github/VirgilSecurity/virgil-sdk-x/)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)

# Objective-C/Swift SDK Programming Guide

Welcome to the SDK Programming Guide. This guide is a practical introduction to creating apps for the iOS platform with Virgil Security features. The code examples in this guide are written in both Objective-C and Swift.

In this guide you will find code for every task you need to implement in order to create an application using Virgil Security services. It also includes a description of main classes and methods. The aim of this guide is to get you up and running quickly. You should be able to copy and paste the code provided into your own apps and use it with minumal changes.

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Swift note](#swift-note)
* [User and App Credentials](#user-and-app-credentials)
* [Creating a Virgil Card](#creating-a-virgil-card)
* [Search for Virgil Cards](#search-for-virgil-cards)
* [Validating Virgil Cards](#validating-virgil-cards)
* [Get a Virgil Card](#get-a-virgil-card)
* [Revoking a Virgil Card](#revoking-a-virgil-card)
* [Global Virgil Cards](#global-virgil-cards)
* [Card relations](#card-relations)
* [Operations with Crypto Keys](#operations-with-crypto-keys)
* [Generate Keys](#generate-keys)
* [Import and Export Keys](#import-and-export-keys)
* [Keys and Keychain](#keys-and-keychain)
* [Encryption and Decryption](#encryption-and-decryption)
* [Encrypt Data](#encrypt-data)
* [Decrypt Data](#decrypt-data)
* [Generating and Verifying Signatures](#generating-and-verifying-signatures)
* [Generating a Signature](#generating-a-signature)
* [Verifying a Signature](#verifying-a-signature)
* [Authenticated Encryption](#authenticated-encryption)
* [Fingerprint Generation](#fingerprint-generation)
* [Release Notes](#release-notes)

## Requirements

- iOS 7.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate VirgilSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'VirgilSDK', '~> 4.3.0'
end
```

Then, run the following command:

```bash
$ pod install
```

> CocoaPods 0.36+ is required to build VirgilSDK 4.0.0+.

### Carthage

As of version 4.2.0 VirgilSDK is available for integration using Carthage.

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate VirgilSDK into your Xcode project using Carthage, perform following steps:

1. Create an empty file with name `Cartfile` in your project's root folder, that lists the frameworks you’d like to use in your project.
1. Add the following line to your `Cartfile`

  ```ogdl
  github "VirgilSecurity/virgil-sdk-x" ~> 4.3.0
  ```
  
1. Run `carthage update`. This will fetch dependencies into a `Carthage/Checkouts` folder inside your project's folder, then build each one or download a pre-compiled framework.
1. On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, add each framework you want to use from the `Carthage/Build` folder inside your project's folder.
1. On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script in which you specify your shell (ex: `/bin/sh`), add the following contents to the script area below the shell:

  ```sh
  /usr/local/bin/carthage copy-frameworks
  ```

  and add the paths to the frameworks you want to use under “Input Files”, e.g.:

  ```
  $(SRCROOT)/Carthage/Build/iOS/VirgilSDK.framework
  ```

## Swift note

Although VirgilSDK pod is using Objective-C as its primary language it might be quite easily used in a Swift application.
All public API is available from Swift and is bridged using NS_SWIFT_NAME where needed.

If you want to use VirgilSDK from swift it is necessary to perform the following:

- Create a new header file in the Swift project.
- Name it something like *BridgingHeader.h*
- Put there the following lines:

###### Objective-C
``` objective-c
@import VirgilCrypto;
@import VirgilSDK;
```

- In the Xcode build settings find the setting called *Objective-C Bridging Header* and set the path to your *BridgingHeader.h* file. Be aware that this path is relative to your Xcode project's folder. After adding bridging header setting you should be able to use the SDK.

You can find more information about using Objective-C and Swift in the same project [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).

## User and App Credentials

When you register an application on the Virgil developer's [dashboard](https://developer.virgilsecurity.com/dashboard), we provide you with an *appId*, *appKey* and *accessToken*.

* **appId** uniquely identifies your application in our services, it is also used to identify the Public key generated in a pair with *appKey*, for example: ```af6799a2f26376731abb9abf32b5f2ac0933013f42628498adb6b12702df1a87```
* **appKey** is a Private key that is used to perform creation and revocation of *Virgil Cards* (Public key) in Virgil services. Also the *appKey* can be used for cryptographic operations to take part in application logic. The *appKey* is generated at the time of application creation and has to be saved in secure place. 
* **accessToken** is a unique string value that provides an authenticated secure access to the Virgil services and is passed with each API call. The *accessToken* also allows the API to associate your app’s requests with your Virgil developer’s account. 

## Connecting to Virgil
Before you can use any Virgil services features in your app, you must first initialize ```VSSClient``` class. You use the ```VSSClient``` object to get access to Create, Revoke, Get and Search for *Virgil Cards* (Public keys). 

### Initializing an API Client

To create an instance of *VSSClient* class, just call its constructor with your application's *accessToken* which you generated on developer's deshboard.

###### Objective-C
```objective-c
//...
@property (nonatomic) VSSClient * __nonnull client;
//...
self.client = [[VSSClient alloc] initWithApplicationToken:<#Virgil App Token#>];
//...
```

###### Swift
```swift
//...
private var client: VSSClient!
//..
self.client = VSSClient(applicationToken: <#Virgil App token#>)
//...
```

### Initializing Crypto
The *VSSCrypto* class provides cryptographic operations in applications, such as hashing, signature generation and verification, encryption and decryption.

###### Objective-C
```objective-c
//...
@property (nonatomic) VSSCrypto * __nonnull crypto;
//...
self.crypto = [[VSSCrypto alloc] init];
//...
```

###### Swift
```swift
//...
private var crypto: VSSCrypto!
//..
self.crypto = VSSCrypto()
//...
```

## Creating a Virgil Card

A *Virgil Card* is the main entity of the Virgil services, it includes the information about the user and his public key. The *Virgil Card* identifies the user/device by one of his types. 

Collect an *appId* and *appKey* for your app. These parametes are required to create a Virgil Card in your app scope.

###### Objective-C
```objective-c
NSString *appId = <#Your appId#>;
NSString *appKeyPassword = <#Your app key password#>;
NSURL *appKeyDataURL = [[NSBundle mainBundle] URLForResource:<#Your app key name#> withExtension:@"virgilkey"];
NSData *appKeyData = [NSData dataWithContentsOfURL:appKeyDataURL];

VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKeyFromData:appKeyData withPassword:appKeyPassword];
```

###### Swift
```swift
let appId = <#String: Your appId#>
let appKeyPassword = <#String: You app key password#>
let path = Bundle.main.url(forResource: <#Your app key name#>, withExtension: "virgilkey")
let keyData = try! Data(contentsOf: path!)

let appPrivateKey = self.crypto.importPrivateKey(from: keyData, withPassword: appKeyPassword)!
```

Generate a new Public/Private keypair using *VSSCrypto* class. 

###### Objective-C
```objective-c
VSSKeyPair *aliceKeys = [self.crypto generateKeyPair];
```

###### Swift
```swift
let aliceKeys = self.crypto.generateKeyPair()
```

Prepare request
###### Objective-C
```objective-c
NSData *exportedPublicKey = [self.crypto exportPublicKey:aliceKeys.publicKey];
VSSCreateCardRequest *request = [VSSCreateCardRequest createCardRequestWithIdentity:@"alice" identityType:@"username" publicKey:exportedPublicKey];
```

###### Swift
```swift
let exportedPublicKey = self.crypto.export(publicKey: aliceKeys.publicKey)
let request = VSSCreateCardRequest(identity: "alice", identityType: "username", publicKey: exportedPublicKey)
```

then, use *VSSRequestSigner* class to sign request with owner and app keys.
###### Objective-C
```objective-c
VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];

NSError *error1;
[signer selfSignRequest:request withPrivateKey:aliceKeys.privateKey error:&error1];
NSError *error2;
[signer authoritySignRequest:request forAppId:appId withPrivateKey:appPrivateKey error:&error2];
```

###### Swift
```swift
let signer = VSSRequestSigner(crypto: self.crypto)

do {
    try signer.selfSign(request, with: aliceKeys.privateKey)
	try signer.authoritySign(request, forAppId: kApplicationId, with: appPrivateKey)
}
catch {
	//...
}
```

Publish a Virgil Card
###### Objective-C
```objective-c
[self.client createCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
    //...
}];
```

###### Swift
```swift
self.client.createCardWith(request) { card, error in
	//...
}
```

## Search for Virgil Cards
Performs the `Virgil Card`s search by criteria:
- the *Identities* request parameter is mandatory;
- the *IdentityType* is optional and specifies the *IdentityType* of a `Virgil Card`s to be found;
- the *Scope* optional request parameter specifies the scope to perform search on. Either 'global' or 'application'. The default value is 'application';

###### Objective-C
```objective-c
VSSSearchCardsCritera *criteria = [VSSSearchCardsCriteria searchCardsCriteriaWithScope:VSSCardScopeApplication identityType:@"username" identities:@[@"alice", @"bob"]];
[self.client searchCardsUsingCriteria:criteria completion:^(NSArray<VSSCard *>* foundCards, NSError *error) {
	//...
}];
```

###### Swift
```swift
let criteria = VSSSearchCardsCriteria(scope: .application, identityType: "username", identities: ["alice", "bob"])
self.client.searchCards(using: criteria) { foundCards, error in
	//...                
}
```

e## Validating Virgil Cards
This sample uses *built-in* ```VSSCardValidator``` to validate Virgil Service card responses. Default ```VSSCardValidator``` validates only *Cards Service* signature. 

###### Objective-C
```objective-c
VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];

// Your can also add another Public Key for verification.
// [validator addVerifierWithId:<#Verifier card id#> publicKey:<#Verifier public key data#>];

eBOOL isValid = [validator validateCardResponse:response];
```

###### Swift
```swift
let validator = VSSCardValidator(crypto: self.crypto)

// Your can also add another Public Key for verification.
// validator.addVerifier(withId: <#Verifier card id#>, publicKey: <#Verifier public key data#>)

let isValid = validator.validate(response)
```

For convenience you can embed validator into the client and all cards received from the Virgil service will be automatically validated for you.
If validation process failes during client queries, error will be generated.

###### Objective-C
```objective-c
self.crypto = [[VSSCrypto alloc] init];

VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];
[validator addVerifierWithId:<#Verifier card id#> publicKey:<#Verifier public key data#>];

VSSServiceConfig *config = [VSSServiceConfig serviceConfigWithToken:kApplicationToken];
config.cardValidator = validator;

self.client = [[VSSClient alloc] initWithServiceConfig:config];
```

###### Swift
```swift
self.crypto = VSSCrypto()

let validator = VSSCardValidator(crypto: self.crypto)
validator.addVerifier(withId: <#Verifier card id#>, publicKey: <#Verifier public key data#>)

let config = VSSServiceConfig(token: kApplicationToken)
config.cardValidator = validator

self.client = VSSClient(serviceConfig: config)
```

## Get a Virgil Card
###### Objective-C
```objective-c
[self.client getCardWithId:<#Your cardId#> completion:^(VSSCard *foundCard, NSError *error) {
    //...
}];
```

###### Swift
```swift
self.client.getCard(withId: <#Your cardId#>) { card, error in
    //...
}
```

## Revoking a Virgil Card

You can make Virgil Card unavailable for further use if its private key was compromised or for any other reason.

###### Objective-C
```objective-c
VSSRevokeCardRequest *revokeRequest = [VSSRevokeCardRequest revokeCardRequestWithCardId:<#Your cardId#> reason:VSSCardRevocationReasonUnspecified];

VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
NSError *error;
[signer authoritySignRequest:revokeRequest forAppId:appId withPrivateKey:appPrivateKey error:&error];

[self.client revokeCardWithRequest:revokeRequest completion:^(NSError *error) {
	//...
}];
```

###### Swift
```swift
let revokeRequest = VSSRevokeCardRequest(cardId: <#Your cardId#>, reason: .unspecified)

let signer = VSSRequestSigner(crypto: self.crypto)
do {
	try signer.authoritySign(revokeRequest, forAppId: appId, with: appPrivateKey)
}
catch {
	//...
}

self.client.revokeCardWithRequest(revokeRequest) { error in
	//...
}
```

## Global Virgil Cards
Global Virgil Cards are not bounded to specific application, but instead are verified using Virgil Registration Authority.
Virgil Global Card creation consists of 2 steps:
1. Verifying Identity and obtaining validation token
2. Creating actual Card

At this moment you can create Global Virgil Cards bounded to email address.
To confirm that you are owner of specific email address and get validation token you should 

1) Request confirmation code to your email

###### Objective-C
```objective-c
NSString *identity = @"alice@email.com";
[self.client verifyIdentity:identity identityType:@"email" extraFields:nil completion:^(NSString *actionId, NSError *error) {
	//...
}];
```

###### Swift
```swift
let identity = "alice@email.com"
self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
	//...
}
```

2) Get validation token using confirmation code

###### Objective-C
```objective-c
NSString *code = @"AAABBB"; // Confirmation code from your email
[self.client confirmIdentityWithActionId:actionId confirmationCode:code timeToLive:3600 countToLive:12 completion:^(VSSConfirmIdentityResponse *response, NSError *error) {
	//...
}];
```

###### Swift
```swift
let code = = "AAABBB" // Confirmation code from your email
self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
	//...
}
```

3) Create Global Virgil Card using validation token just like regular application Card

###### Objective-C
```objective-c
VSSKeyPair *aliceKeys = [self.crypto generateKeyPair];

NSData *exportedPublicKey = [self.crypto exportPublicKey:aliceKeys.publicKey];
VSSCreateGlobalCardRequest *request = [VSSCreateGlobalCardRequest createGlobalCardRequestWithIdentity:@"alice" identityType:@"email" validationToken: response.validationToken publicKey:exportedPublicKey];

VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];

NSError *error;
[signer selfSignRequest:request withPrivateKey:aliceKeys.privateKey error:&error];
                    
[self.client createGlobalCardWithRequest:request completion:^(VSSCard *card, NSError *error) {
	//...
}];
```

###### Swift
```swift
let aliceKeys = self.crypto.generateKeyPair()

let exportedPublicKey = self.crypto.export(publicKey: aliceKeys.publicKey)
let request = VSSCreateCardRequest(identity: "alice", identityType: "email", validationToken: response!.validationToken, publicKey: exportedPublicKey)

let signer = VSSRequestSigner(crypto: self.crypto)

do {
    try signer.selfSign(request, with: aliceKeys.privateKey)
}
catch {
	//...
}
        
self.client.createGlobalCardWith(request) { (registeredCard, error) in
    //...
}
```

Global Card Revocation process combines Revocation process of application Virgil Cards and Identity confirmation just like during Card creation.

###### Objective-C
```objective-c
NSString *identity = @"alice@email.com";
[self.client verifyIdentity:identity identityType:@"email" extraFields:nil completion:^(NSString *actionId, NSError *error) {
	NSString *code = @"AAABBB"; // Confirmation code from your email
	[self.client confirmIdentityWithActionId:actionId confirmationCode:code timeToLive:3600 countToLive:12 completion:^(VSSConfirmIdentityResponse *response, NSError *error) {
		VSSRevokeGlobalCardRequest *revokeRequest = [VSSRevokeGlobalCardRequest revokeGlobalCardRequestWithCardId:card.identifier validationToken:response.validationToken reason:VSSCardRevocationReasonUnspecified];
	    
	    VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
	    
	    NSError *error;
	    [signer authoritySignRequest:revokeRequest forAppId:card.identifier withPrivateKey:aliceKeys.privateKey error:&error];
		                    
		[self.client revokeGlobalCardWithRequest:revokeRequest completion:^(NSError *error) {
			//...
        }];
	}];
}];
```

###### Swift
```swift
let identity = "alice@email.com"
self.client.verifyIdentity(identity, identityType: "email", extraFields: nil) { actionId, error in
	let code = = "AAABBB" // Confirmation code from your email
	self.client.confirmIdentity(withActionId: actionId!, confirmationCode: code, timeToLive: 3600, countToLive: 12) { response, error in
		let revokeRequest = VSSRevokeGlobalCardRequest(cardId: card.identifier, validationToken: response!.validationToken, reason: .unspecified)
        
        let signer = VSSRequestSigner(crypto: self.crypto)
        
        try! signer.authoritySign(revokeRequest, forAppId: card.identifier, with: aliceKeys.privateKey)
        
        self.client.revokeGlobalCardWith(revokeRequest) { error in
            //...
        }
	}
}
```

## Card relations

The relation entity describes a trusted one-way relation between the source Virgil Card specified and the destination Virgil Card.
Card relations is an implementation of Web of trust concept.

### Checking for card's relations
Existing card's relations are available in a form of array with ids of virgil cards that are trusted.

###### Objective-C
```objective-c
[self.client getCardWithId:card1.identifier completion:^(VSSCard *card, NSError *error) {
    // card.relations
}];
```

###### Swift
```
self.client.getCard(withId: registeredCard1!.identifier, completion: { card, error in
	// card!.relations
})
```swift

### Creating a relation
To create card relation from card1 to card2 (meaning that card1 trusts card2) use following code snippet:

###### Objective-C
```objective-c
VSSSignedCardRequest *signedCardRequest = [VSSSignedCardRequest signedCardRequestWithSnapshot:card2.cardResponse.snapshot];
VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
[signer authoritySignRequest:signedCardRequest forAppId:card1.identifier withPrivateKey:<#Card1 private key#> error:nil];

[self.client createCardRelationWithSignedCardRequest:signedCardRequest completion:^(NSError *error) {
    //...
}];
```

###### Swift
```swift
let signedCardRequest = VSSSignedCardRequest(snapshot: card2.cardResponse.snapshot)
let signer = VSSRequestSigner(crypto: self.crypto)
try! signer.authoritySign(signedCardRequest, forAppId: card1.identifier, with: <#Card1 private key#>)

self.client.createCardRelation(with: signedCardRequest, completion: { error in
    //...
})
```

### Removing card relation
To remove card relation from card1 to card2 use following code snippet:

###### Objective-C
```objective-c
VSSRemoveCardRelationRequest *request = [VSSRemoveCardRelationRequest removeCardRelationRequestWithCardId:card2.identifier reason:VSSCardRevocationReasonCompromised];
VSSRequestSigner *signer = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
[signer authoritySignRequest:request forAppId:card1.identifier withPrivateKey:<#Card1 private key#> error:nil];

[self.client removeCardRelationWithRequest:request completion:^(NSError *error) {
	//...
}];

```

###### Swift
```swift
let request = VSSRemoveCardRelationRequest(cardId: registeredCard2!.identifier, reason: .unspecified)
let signer = VSSRequestSigner(crypto: self.crypto)
try! signer.authoritySign(request, forAppId: card1.identifier, with: <#Card1 private key#>)

self.client.removeCardRelation(with: request, completion: { error in
    //...
})
```

## Operations with Crypto Keys

### Generate Keys
The following code sample illustrates keypair generation. The default algorithm is ed25519

###### Objective-C
```objective-c
VSSKeyPair *aliceKeys = [self.crypto generateKeyPair];
```

###### Swift
```swift
let aliceKeys = self.crypto.generateKeyPair()
```

### Import and Export Keys
You can export and import your Public/Private keys to/from supported wire representation.

To export Public/Private keys, simply call one of the Export methods:

###### Objective-C
```objective-c
NSData *alicePrivateKey = [self.crypto exportPrivateKey:aliceKeys.privateKey withPassword:nil];
NSData *alicePublicKey = [self.crypto exportPublicKey:aliceKeys.publicKey];
```

###### Swift
```swift
let alicePrivateKeyData = self.crypto.export(aliceKeys.privateKey, withPassword: nil)
let alicePublicKeyData = self.crypto.export(aliceKeys.publicKey)
```

To import Public/Private keys, simply call one of the Import methods:

###### Objective-C
```objective-c
VSSPrivateKey *alicePrivateKey = [self.crypto importPrivateKeyFromData:alicePrivateKeyData withPassword:nil];
VSSPublicKey *alicePublicKey = [self.crypto importPublicKeyFromData:alicePublicKey];
```

###### Swift
```swift
let alicePrivateKey = self.crypto.import(from: alicePrivateKeyData, password: nil)
let alicePublicKey = self.crypto.import(from: alicePublicKeyData)
```

## Keys and Keychain
Virgil SDK provides convienient methods to save and retrieve keys to/from Keychain.

To store key to Keychain you can use following snippet

###### Objective-C
```objective-c
VSSKeyStorage *storage = [[VSSKeyStorage alloc] init];
VSSKeyPair *aliceKeys = [self.crypto generateKeyPair];
    
NSData *privateKeyRawData = [self.crypto exportPrivateKey:aliceKeys.privateKey withPassword:nil];
NSString *privateKeyName = @"aliceKey";
    
VSSKeyEntry *aliceKeyEntry = [VSSKeyEntry keyEntryWithName:privateKeyName value:privateKeyRawData];

NSError *error;
BOOL res = [storage storeKeyEntry:aliceKeyEntry error:&error];
```

###### Swift
```swift
let storage = VSSKeyStorage()
let aliceKeys = self.crypto.generateKeyPair()
        
let privateKeyRawData = self.crypto.export(aliceKeys.privateKey, withPassword: nil)
let privateKeyName = "aliceKey"
        
let aliceKeyEntry = VSSKeyEntry(name: privateKeyName, value: privateKeyRawData)

try! storage.store(aliceKeyEntry)
```

You can also Load key from Keychain, check its existance and remove key from Keychain.

To load key:

###### Objective-C
```objective-c
NSError *error;
VSSKeyEntry *loadedKeyEntry = [storage loadKeyEntryWithName:@"aliceKey" error:&error];
```

###### Swift
```swift
let loadedKeyEntry = try! storage.loadKeyEntry(withName: "aliceKey")
```

To check existence

###### Objective-C
```objective-c
BOOL exists = [storage existsKeyEntryWithName:@"aliceKey"];
```

###### Swift
```swift
let exists = storage.existsKeyEntry(withName: "alicaKey")
```

To remove key

###### Objective-C
```objective-c
NSError *error;
BOOL res = [storage deleteKeyEntryWithName:self.keyEntry.name error:&error];
```

###### Swift
```swift
try! storage.deleteKeyEntry(withName: "aliceKey")
```

## Encryption and Decryption

Initialize Crypto API and generate keypair.
###### Objective-C
```objective-c
VSSCrypto *crypto = [[VSSCrypto alloc] init];
VSSKeyPair *keyPair = [crypto generateKeyPair];
```

###### Swift
```swift
let crypto = VSSCrypto()
let keyPair = crypto.generateKeyPair()
```

### Encrypt Data
Data encryption using ECIES scheme with AES-GCM. You can encrypt either stream or data.
There also can be more than one recipient

*Data*
###### Objective-C
```objective-c
NSData *plainText = [@"Hello, Bob!" dataUsingEncoding:NSUTF8StringEncoding];
NSError *error;
NSData *encryptedData = [self.crypto encryptData:plainText forRecipients:@[aliceKeys.publicKey] error:&error];
```

###### Swift
```swift
let plainTextData = "Hello, Bob!".data(using: .utf8)
let encryptedData = try? crypto.encrypt(plainTextData, for: [aliceKeys.publicKey])
```

*Stream*
###### Objective-C
```objective-c
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:<#Your data file name#> withExtension:<#Your data file extension#>];
NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithURL:fileURL];
NSOutputStream *outputStreamForEncryption = [[NSOutputStream alloc] initToMemory];

NSError *error;
[self.crypto encryptStream:inputStreamForEncryption toOutputStream:outputStreamForEncryption forRecipients: @[aliceKeys.publicKey] error:&error];
```

###### Swift
```swift
let fileURL = Bundle.main.url(forResource: <#You data file name#>, withExtension: <#You data file extension#>)!
let inputStreamForEncryption = InputStream(url: fileURL)!
let outputStreamForEncryption = OutputStream.toMemory()

do {
	try self.crypto.encrypt(inputStreamForEncryption, to: outputStreamForEncryption, for: [aliceKeys.publicKey])
}
catch {
	//...            
}
```

### Decrypt Data
You can decrypt either stream or data using your private key

*Data*
###### Objective-C
```objective-c
NSError *error;
NSData *decryptedData = [self.crypto decryptData:encryptedData withPrivateKey:aliceKeys.privateKey error:&error];
```

###### Swift
```swift
let decrytedData = try? self.crypto.decrypt(encryptedData, with: aliceKeys.privateKey)
```

*Stream*
###### Objective-C
```objective-c
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:<#Your encrypted data file name#> withExtension:<#Your encrypted data file extension#>];
NSInputStream *inputStreamForDecryption = [[NSInputStream alloc] initWithURL:fileURL];
NSOutputStream *outputStreamForDecryption = [[NSOutputStream alloc] initToMemory];

NSError *error;
[self.crypto decryptStream:inputStreamForDecryption toOutputStream:outputStreamForDecryption withPrivateKey:aliceKeys.privateKey error:&error];
```

###### Swift
```swift
let fileURL = Bundle.main.url(forResource: <#Your encrypted data file name#>, withExtension: <#Your encrypted data file extension#>)!
let inputStreamForDecryption = InputStream(url: fileURL)!
let outputStreamForDecryption = OutputStream.toMemory()

do {
	try self.crypto.decrypt(inputStreamForDecryption, to: outputStreamForDecryption, with: aliceKeys.privateKey)
}
catch {
	//...            
}
```

## Generating and Verifying Signatures
This section walks you through the steps necessary to use the *VirgilCrypto* to generate a digital signature for data and to verify that a signature is authentic.

### Generating a Signature

Sign the SHA-384 fingerprint of either stream or data using your private key. To generate the signature, simply call one of the sign methods:

*Data*
###### Objective-C
```objective-c
NSData *plainTextData = [@"Hello, Bob!" dataUsingEncoding:NSUTF8StringEncoding];
NSError *error;
NSData *signature = [self.crypto generateSignatureForData:plainTextData withPrivateKey:keyPair.privateKey error:&error];
```

###### Swift
```swift
let plainTextData = "Hello, Bob!".data(using: .utf8)!
let signature = try? self.crypto.generateSignature(for: plainTextData, with: aliceKeys.privateKey)
```

*Stream*
###### Objective-C
```objective-c
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:<#Your data file name#> withExtension:<#Your data file extension#>];
NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithURL:fileURL];
NSData *signature = [self.crypto generateSignatureForStream:inputStreamForEncryption withPrivateKey:aliceKeys.privateKey error:&error];
```

###### Swift
```swift
let fileURL = Bundle.main.url(forResource: <#Your data file name#>, withExtension: <#Your data file extension#>)!
let inputStreamForSignature = InputStream(url: fileURL)!
let signature = try? self.crypto.generateSignature(for: inputStreamForSignature, with: aliceKeys.privateKey)
```

### Verifying a Signature

Verify the signature of the SHA-384 fingerprint of either stream or a data using Public key. The signature can now be verified by calling the verify method:

*Data*
###### Objective-C
```objective-c
NSError *error;
BOOL isVerified = [self.crypto verifyData:data withSignature:signature usingSignerPublicKey:aliceKeys.publicKey error:&error];
```

###### Swift
```swift
let isVerified = try? self.crypto.verifyData(data, withSignature: signature, usingSignerPublicKey: aliceKeys.publicKey)
```

*Stream*
###### Objective-C
```objective-c
NSError *error;
BOOL isVerified = [self.crypto verifyStream:stream withSignature:signature usingSignerPublicKey:aliceKeys.publicKey error:&error];
```

###### Swift
```swift
let isVerified = try? self.crypto.verifyStream(stream, withSignature: signature, usingSignerPublicKey: aliceKeys.publicKey)
```

## Authenticated Encryption
Virgil SDK contains convenient API for combining encrypt/decrypt and sign/verify procedures

*Sign and encrypt*
###### Objective-C
```objective-c
NSError *error;
NSData *signedAndEcnryptedData = [self.crypto signThenEncryptData:data withPrivateKey:senderPrivateKey forRecipients:@[receiverPublicKey] error:&error];
```

###### Swift
```swift
let signedAndEcryptedData = try? self.crypto.signThenEncrypt(data, with: senderPrivateKey, for: [receiverPublicKey])
```

*Decrypt and verify*
###### Objective-C
```objective-c
NSError *error;
NSData *decryptedAndVerifiedData = [self.crypto decryptThenVerifyData:signedAndEcnryptedData withPrivateKey:receiverPrivateKey usingSignerPublicKey:senderPublicKey error:&error];
```

###### Swift
```swift
let decryptedAndVerifiedData = try? self.crypto.decryptThenVerify(signedAndEcryptedData, with: receiverPrivateKey, using: senderPublicKey)
```

## Fingerprint Generation
The default Fingerprint algorithm is SHA-256.
###### Objective-C
```objective-c
VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:data];
```

###### Swift
```swift
let fingerprint = self.crypto.calculateFingerprint(for: data)
```

## Release Notes
- Please read the latest note here: [https://github.com/VirgilSecurity/virgil-sdk-x/releases](https://github.com/VirgilSecurity/virgil-sdk-x/releases)
