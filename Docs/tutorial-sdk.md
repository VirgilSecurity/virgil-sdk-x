# Tutorial Objective-C/Swift SDK 

- [Introduction](#introduction)
- [Install](#install)
- [Swift note](#swift-note)
- [Obtaining an Access Token](#obtaining-an-access-token)
- [Identity Check](#identity-check)
  - [Request Verification](#request-verification)
  - [Confirm and Get a validation Token](#confirm-and-get-a-validation-token)
- [Cards and Public Keys](#cards-and-public-keys)
  - [Publish a Virgil Card](#publish-a-virgil-card)
  - [Search for Cards](#search-for-cards)
  - [Search for Application Cards](#search-for-application-cards)
  - [Trust a Virgil Card](#trust-a-virgil-card)
  - [Untrust a Virgil Card](#untrust-a-virgil-card)
  - [Revoke a Virgil Card](#revoke-a-virgil-card)
  - [Get a Public Key](#get-a-public-key)
- [Private Keys](#private-keys)
  - [Store a Private Key](#store-a-private-key)
  - [Get a Private Key](#get-a-private-key)
  - [Destroy a Private Key](#destroy-a-private-key)

##Introduction

This tutorial explains how to use the Virgil Security Services with SDK library in Objective-C/Swift applications. 

##Install

You can easily add SDK dependency to your project using CocoaPods. So, if you are not familiar with this dependency manager it is time to install CocoaPods. Open your terminal window and execute the following line:
```
$ sudo gem install cocoapods
``` 
It will ask you about the password and then will install latest release version of CocoaPods. CocoaPods is built with Ruby and it will be installed with the default Ruby available in OS X.
If you encounter any issues during this installation, please take a look at [cocoapods.org](https://guides.cocoapods.org/using/getting-started.html) for more information.

Now it is possible to add VirgilSDK to the particular application. So:

- Open Xcode and create a new project (in the Xcode menu: File->New->Project), or navigate to an existing Xcode project using:

```
$ cd <Path to Xcode project folder>
```

- In the Xcode project's folder create a new file, give it a name *Podfile* (with a capital *P* and without any extension). The following example shows how to compose the Podfile for an iOS application. If you are planning to use another platform, the process will be quite similar. You only need to change a platform to the correspondent value. [Here](https://guides.cocoapods.org/syntax/podfile.html#platform) you can find more information about the platform values.

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Put your Xcode target name here>' do
	pod 'VirgilSDK'
end
```

- Get back to your terminal window and execute the following line:

```
$ pod install
```
 
- Close Xcode project (if it is still opened). For any further development purposes you should use Xcode *.xcworkspace* file created for you by CocoaPods.
 
At this point you should be able to use VirgilSDK pod in your code. If you encountered any issues with CocoaPods installations, try to find more information at [cocoapods.org](https://guides.cocoapods.org/using/getting-started.html).

## Swift note

Although VirgilSDK pod is using Objective-C as its primary language it might be quite easily used in a Swift application.
After pod is installed as described above it is necessary to perform the following:

- Create a new header file in the Swift project.
- Name it something like *BridgingHeader.h*
- Put there the following lines:

###### Objective-C
``` objective-c
@import VirgilFoundation;
@import VirgilSDK;
```

- In the Xcode build settings find the setting called *Objective-C Bridging Header* and set the path to your *BridgingHeader.h* file. Be aware that this path is relative to your Xcode project's folder. After adding bridging header setting you should be able to use the SDK.

You can find more information about using Objective-C and Swift in the same project [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).

##Obtaining an Access Token

First you must create a free Virgil Security developer's account by signing up [here](https://developer.virgilsecurity.com/account/signup). Once you have your account you can [sign in](https://developer.virgilsecurity.com/account/signin) and generate an access token for your application.

The access token provides an authenticated secure access to the Virgil Security Services and is passed with each API call. The access token also allows the API to associate your app’s requests with your Virgil Security developer's account.

Simply add your access token to the client constuctor as an application token.

###### Objective-C
```objective-c
//...
@property (nonatomic, strong) VSSClient * __nonnull client;
//...
self.client = [[VSSClient alloc] 
				initWithApplicationToken:<# Virgil Access Token #>];
//...
```

###### Swift
```swift
//...
private var client: VSSClient! = nil
//...
let client = VSSClient(applicationToken: <# Virgil Access Token #>)
//...
```

## Client setup 

Before any calls to Virgil Security Services VSSClient instance should perform an additional setup.

```objective-c
//...
[self.client setupClientWithCompletionHandler:^(NSError * _Nullable error) 
	{
    if (error != nil) {
        NSLog(@"Virgil Client has not been set up properly: %@", 
        		[error localizedDescription]);
        return;        
    }
    // VSSClient is ready to work.
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.setupClientWithCompletionHandler { (error) -> Void in 
    if error != nil {
        print("Virgil Client has not been set up properly: 
        		\(error!.localizedDescription)")
        return
    }
    // VSSClient is ready to work.
    //...
}
//...
```

## Identity Check

All the Virgil Security services are strongly interconnected with the Identity Service. It determines the ownership of the identity being checked using particular mechanisms and as a result it generates a temporary token to be used for the operations which require an identity verification. 

#### Request Verification

Initialize the identity verification process.

###### Objective-C
```objective-c
//...
[self.client verifyIdentityWithType:VSSIdentityTypeEmail 
	value:<# Email address #> 
	completionHandler:^(GUID *actionId, NSError *error) {
	    if (error != nil) {
	        NSLog(@"Error identity verification: %@", 
	        		[error localizedDescription]);
	        return;
	    }
    
    // Store actionId, it will be necessary to confirm identity 
    // and obtain verificationToken.
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.verifyIdentityWithType(.Email, value: <# Email address #>) 
	{ (actionId, error) -> Void in
	    if error != nil {
	        print("Error identity verification: 
	        		\(error!.localizedDescription)")
	        return
    }
    
    // Store actionId, it will be necessary to confirm identity 
    // and obtain verificationToken.
    //...
}
//...
```

#### Confirm and Get a validation Token

Confirm the identity and get a temporary token.

###### Objective-C
```objective-c
//...
// ttl parameter is NSNumber integer for "Time to live" in seconds value.
// ctl parameter is NSNumber integer for "Counts to live" value. 
[self.client 
	confirmIdentityWithActionId:<# Action ID from verification step #> 
	code:<# Code from email #> 
	ttl:<# Time to live or nil #> 
	ctl:<# Counts to live or nil #> 
	completionHandler:^(VSSIdentityType type, 
		NSString *value, 
		NSString *validationToken, 
		NSError *error) {
		    if (error != nil) {
		        NSLog(@"Error identity confirmation: %@", 
		        	[error localizedDescription]);
		        return;
		    }

    // Use validationToken for further operations, e.g publishing a Virgil Card.
    //...
}];
//...
```

###### Swift
```swift
//...
// ttl parameter is NSNumber integer for "Time to live" in seconds value.
// ctl parameter is NSNumber integer for "Counts to live" value.
self.client.confirmIdentityWithActionId
	(<# Action ID from verification step #>, 
	code: <# Code from email #>, 
	ttl: <# Time to live or nil #>, 
	ctl: <# Counts to live or nil #>, 
	completionHandler: { (itype, ivalue, ivalToken, error) -> Void in
    if error != nil {
        print("Error identity confirmation: \(error!.localizedDescription)")
        return
    }
    
    // Use ivalToken for further operations, e.g publishing a Virgil Card.
    //...    
})
//...
```

## Cards and Public Keys

A Virgil Card is the main entity of the Public Keys Service, it includes the information about the user and his public key. The Virgil Card identifies the user by one of his available types, such as an email, a phone number, etc.

#### Publish a Virgil Card

An identity token which can be received [here](#identity-check) is used during the registration.

###### Objective-C
```objective-c
//...
NSDictionary *identity = @{
    kVSSModelType: [VSSIdentity stringFromIdentityType:VSSIdentityTypeEmail], 
    kVSSModelValue: <# Email Address #>,
    kVSSModelValidationToken: <# Validation token from confirmaton step #>    
};
[self.client 
	createCardWithPublicKey:<# Public key data #> 
	identity:identity data:<# Custom NSDictionary or nil #> 
	signs:<# NSArray of signatures or nil #> 
	privateKey:<# VSSPrivateKey object #> 
	completionHandler:^(VSSCard *card, NSError *error) {
	    if (error != nil) {
	        NSLog(@"Error creating Virgil Card: %@", 
	        	[error localizedDescription]);
	        return;
	    }
    
    //Virgil Card has been saved at Virgil Keys Service.
    // Use card object for further references.
    //...
}];
//...
```

###### Swift
```swift
//...
let identity = [ 
    kVSSModelType: VSSIdentity.stringFromIdentityType(.Email), 
    kVSSModelValue: <# Email Address #>,
    kVSSModelValidationToken: <# Validation token from confirmaton step #> 
]
self.client.createCardWithPublicKey(<# Public key data #>, 
	identity: identity as [NSObject : AnyObject], 
	data: nil, 
	signs: nil, 
	privateKey: <# VSSPrivateKey object #>, 
	completionHandler: { (card, error) -> Void in
	    if error != nil {
	        print("Error creating Virgil Card: \(error!.localizedDescription)")
	        return
	    }
    
    //Virgil Card has been saved at Virgil Keys Service.
    // Use card object for further references.
    //...
})
//...
```

#### Search for Cards

Search for the Virgil Card by provided parameters.

###### Objective-C
```objective-c
//...
[self.client 
	searchCardWithIdentityValue:<# Email Address #> 
	type:VSSIdentityTypeEmail 
	relations:nil 
	unconfirmed:nil 
	completionHandler:^(NSArray<VSSCard *> * _Nullable cards, 
		NSError * _Nullable error) {
		    if (error != nil) {
		        NSLog(@"Error searching for Virgil Cards: %@", 
		        	[error localizedDescription]);
		        return;
		    }
    
    // cards contains an array of VSSCard objects which fit given parameters.
    // Quite often it might be only one VSSCard in the array.
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.searchCardWithIdentityValue(<# Email Address #>, 
	type: .Email, 
	relations: nil, 
	unconfirmed: nil) { (cards, error) -> Void in
	    if error != nil {
	        print("Error searching for Virgil Cards: 
	        	\(error!.localizedDescription)")
	        return
	    }
    
    // cards contains an array of VSSCard objects which fit given parameters.
    // Quite often it might be only one VSSCard in the array.
    //...
}
//...
```

#### Search for Application Cards

Search for the Virgil Cards by a defined pattern. The example below returns a list of applications for Virgil Security company.

###### Objective-C
```objective-c
//...
[self.client searchAppCardWithIdentityValue:@"com.virgil.*" 
	completionHandler:^(NSArray<VSSCard *> * _Nullable cards, 
	NSError * _Nullable error) {
	    if (error != nil) {
	        NSLog(@"Error searching for Virgil Cards: %@", 
	        	[error localizedDescription]);
	        return;
	    }
    
    // cards contains an array of VSSCard objects which fit given identity value.
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.searchAppCardWithIdentityValue("com.virgil.*") 
	{ (cards, error) -> Void in
    if error != nil {
        print("Error searching for Virgil Cards: \(error!.localizedDescription)")
        return
    }
    
    // cards contains an array of VSSCard objects which fit given identity value
    //...
}
//...
```

#### Trust a Virgil Card

Any Virgil Card user can act as a certification center within the Virgil Security ecosystem. Every user can certify another's Virgil Card and build a net of trust based on it.

The example below demonstrates how to certify a user's Virgil Card by signing its hash attribute. 

 
###### Objective-C
```objective-c
//...
VSSSigner *signer = [[VSSSigner alloc] init];
NSData *hashData = 
	[[NSData alloc] 
	initWithBase64EncodedString:<# VSSCard to be trusted #>.Hash options:0];
NSData *digest = 
	[signer signData:hashData 
	privateKey:<# VSSPrivateKey object #>.key 
	keyPassword:<# VSSPrivateKey object #>.password];
    
[self.client 
	signCardWithCardId:<# VSSCard to be trusted #>.Id 
	digest:digest 
	signerCard:<# VSSCard which is used to compose trust #> 
	privateKey:<# VSSPrivateKey object #> 
			completionHandler:^(VSSSign * _Nullable sign, NSError * _Nullable error) 
			{
		    if (error != nil) {
		        NSLog(@"Error signing Virgil Card: %@", 
		        	[error localizedDescription]);
		        return;
		    }
    
    //...
}];
//...
```

###### Swift
```swift
//...
let signer = VSSSigner()
let hashData = NSData(base64EncodedString: <# VSSCard to be trusted #>.Hash, 
		options: .IgnoreUnknownCharacters)
let digest = signer.signData(hashData, 
		privateKey: <# VSSPrivateKey object #>.key, 
		keyPassword: <# VSSPrivateKey object #>.password)

self.client.signCardWithCardId(<# VSSCard which need to be trusted #>.Id, 
		digest: digest, 
		signerCard: <# VSSCard which is used to compose trust #>, 
		privateKey: <# VSSPrivateKey object #>) 
		{ (sign, error) -> Void in
		    if error != nil {
		        print("Error signing Virgil Card: 
		        	\(error!.localizedDescription)")
		        return
    }
    
    //...
}
//...
```

#### Untrust a Virgil Card

Naturally it is possible to stop trusting the Virgil Card owner as in all relations. This is not an exception in Virgil Security system.

###### Objective-C
```objective-c
//...
[self.client 
	unsignCardWithId:<# VSSCard which should not be trusted any more #>.Id 
	signerCard:<# VSSCard which was used to compose trust #> 
	privateKey:[<# VSSKeyPair object #> privateKey] 
	completionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
        NSLog(@"Error unsigning Virgil Card: %@", [error localizedDescription]);
        return;
    }
    
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.unsignCardWithId(<# VSSCard which should not be trusted any more #>.Id, 
signerCard: <# VSSCard which was used to compose trust #>, 
privateKey: <# VSSKeyPair object #>.privateKey()) 
{ (error) -> Void in
    if error != nil {
        print("Error unsigning Virgil Card: \(error!.localizedDescription)")
        return
    }
    
    //...
}
//...
```

#### Revoke a Virgil Card

This operation is used to delete the Virgil Card from the search and mark it as deleted. 

###### Objective-C
```objective-c
//...
// It is not necessary to compose identity dictionary for 
// unconfirmed Virgil Cards. Just pass nil.
NSDictionary *identity = @{
    kVSSModelType: [VSSIdentity stringFromIdentityType:VSSIdentityTypeEmail],
    kVSSModelValue: <# Email Address #>,
    kVSSModelValidationToken: <# Validation token from confirmaton step #>
};
[self.client deleteCardWithCardId:<# VSSCard to be deleted #>.Id
 identity:identity 
 privateKey:<# VSSPrivateKey object #> 
 completionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
        NSLog(@"Error deleting Virgil Card: %@", [error localizedDescription]);
        return;
    }
    
    //...
}];
//...
```

###### Swift
```swift
//...
// It is not necessary to compose identity dictionary for 
// unconfirmed Virgil Cards. Just pass nil.
let identity = [ 
    kVSSModelType: VSSIdentity.stringFromIdentityType(.Email), 
    kVSSModelValue: <# Email Address #>,
    kVSSModelValidationToken: <# Validation token from confirmaton step #> 
]
self.client.deleteCardWithCardId(<# VSSCard to be deleted #>.Id, 
identity: identity as [NSObject : AnyObject], 
privateKey: <# VSSPrivateKey object #>) { (error) -> Void in
      if error != nil {
        print("Error deleting Virgil Card: \(error!.localizedDescription)")
        return
    }
    
    //...      
}
//...
```

#### Get a Public Key

Gets a public key from the Public Keys Service by the specified ID.

###### Objective-C
```objective-c
//...
[client getPublicKeyWithId:<# Public key ID #> 
completionHandler:^(VSSPublicKey * _Nullable key, NSError * _Nullable error) {
    if (error != nil) {
        NSLog(@"Error getting Public key: %@", [error localizedDescription]);
        return;
    }
    
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.getPublicKeyWithId("") { (publicKey, error) -> Void in
    if error != nil {
        print("Error getting public key: \(error!.localizedDescription)")
        return
    }
    
    //...
}
//...
```

## Private Keys

The security of private keys is crucial for the public key cryptosystems. Anyone who can obtain a private key can use it to impersonate the rightful owner during all communications and transactions on intranets or on the internet. Therefore, private keys must be in the possession only of authorized users, and they must be protected from unauthorized use.

Virgil Security provides a set of tools and services for storing private keys in a safe storage which lets you synchronize your private keys between the devices and applications.

Usage of this service is optional.

#### Store a Private Key

Private key can be added for storage only in case you have already registered a public key on the Public Keys Service.

Use the public key identifier on the Public Keys Service to save the private keys. 

The Private Keys Service stores private keys the original way as they were transferred. That's why we strongly recommend to trasfer the keys which were generated with a password.

###### Objective-C
```objective-c
//...
[self.client storePrivateKey:<# VSSPrivateKey object #> 
cardId:<# Virgil Card ID of the card with corresponding public key #> 
completionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
        NSLog(@"Error storing a private key: %@", [error localizedDescription]);
        return;
    }
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.storePrivateKey(<# VSSPrivateKey object #>, 
cardId: <# Virgil Card ID of the card with corresponding public key #>) 
{ (error) -> Void in
    if error != nil {
        print("Error storing a private key: \(error!.localizedDescription)")
        return
    }
    
    //...
}
//...
```

#### Get a Private Key

To get a private key you need to pass a prior verification of the Virgil Card where your public key is used.
  
###### Objective-C
```objective-c
//...
NSDictionary *identity = @{
    kVSSModelType: [VSSIdentity stringFromIdentityType:VSSIdentityTypeEmail], 
    kVSSModelValue: <# Email Address #>,
    kVSSModelValidationToken: <# Validation token from confirmaton step #>    
};
// password parameter represents a password which will be used 
// by Virgil Service to encrypt the response. 
// If this parameter is nil, VSSClient will generate password automatically. 
// This password is freshly generated every time this request takes place. 
// VSSClient will never use the same password twice. 
[self.client grabPrivateKeyWithIdentity:identity 
cardId:<# Virgil Card ID #> 
password:<# Specific password for response encryption 
	or nil to generate it automatically #> 
completionHandler:^(NSData * _Nullable keyData, 
	GUID * _Nullable cardId, 
	NSError * _Nullable error) {
    if (error != nil) {
        NSLog(@"Error getting the private key: %@", 
        	[error localizedDescription]);
        return;
    }
    
    // keyData contains the NSData object with private key in the same form
    // as it was stored (e.g. it might be in password-protected form).
    //...
}];
//...
```

###### Swift
```swift
//...
let identity = [ 
    kVSSModelType: VSSIdentity.stringFromIdentityType(.Email), 
    kVSSModelValue: <# Email Address #>,
    kVSSModelValidationToken: <# Validation token from confirmaton step #> 
]
// password parameter represents a password which will be used by 
// Virgil Service to encrypt the response. 
// If this parameter is nil, VSSClient will generate password automatically. 
// This password is generated freshly every time this request takes place. 
// VSSClient will never use the same password twice. 
self.client.grabPrivateKeyWithIdentity(identity, 
	cardId: <# Virgil Card ID #>, 
	password: <# Specific password for response encryption 
			or nil to generate it automatically #>) 
	{ (keyData, cardId, error) -> Void in
	    if error != nil {
	        print("Error getting the private key: 
	        	\(error!.localizedDescription)")
	        return
	    }
    
    // keyData contains the NSData object with private key in the same form as it was stored (e.g. it might be in password-protected form).
    //...
}
//...
```

#### Destroy a Private Key

This operation deletes the private key from the service without a possibility to be restored. 
  
###### Objective-C
```objective-c
//...
[client deletePrivateKey:<# VSSPrivateKey object #> 
cardId:<# Virgil Card ID #> 
completionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
        NSLog(@"Error deleting the private key: %@", 
        	[error localizedDescription]);
        return;
    }
    //...
}];
//...
```

###### Swift
```swift
//...
self.client.deletePrivateKey(<# VSSPrivateKey object #>, 
	cardId: <# Virgil Card ID #>) { (error) -> Void in
    if error != nil {
        print("Error deleting the private key: 
        	\(error!.localizedDescription)")
        return
    }
    //...
}
//...
```

## See Also

* [Quickstart](quickstart.md)
* [Reference API for SDK](sdk-reference-api.md)
