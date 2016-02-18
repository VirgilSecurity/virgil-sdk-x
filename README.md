## Description

VirgilSDK is a wrapper over the Virgil Security Services for Apple-based platforms. It allows user to interact with Virgil Services much easier. This framework takes care about composing correct requests and parsing the service's responds into usable model classes.  

## Getting started

VirgilSDK framework is supposed to be installed via CocoaPods. So, if you are not familiar with it it is time to install CocoaPods. Open your terminal window and execute the following line:
```
$ sudo gem install cocoapods
``` 
It will ask you about the password and then will install latest release version of CocoaPods. CocoaPods is built with Ruby and it will be installable with the default Ruby available on OS X.

If you encountered any issues during this installation, please take a look at [cocoapods.org](https://guides.cocoapods.org/using/getting-started.html) for more information.

VirgilSDK framework has 1 dependency:
 
- VirgilFoundation - this is low-level Virgil framework for performing basic security operations such as: creating key pairs, encrypting/decrypting some data and signing/verifying signatures.

You don't need to install it manually. CocoaPods will handle it for you automatically.

Now it is possible to add VirgilSDK to the particular application. So:

- Open Xcode and create a new project (in the Xcode menu: File->New->Project), or navigate to existing Xcode project using:

```
$ cd <Path to Xcode project folder>
```

- In the Xcode project's folder create a new file, give it a name *Podfile* (with a capital *P* and without any extension). The following example shows how to compose the Podfile for an iOS application. If you are planning to use other platform the process will be quite similar. You only need to change platform to correspondent value. [Here](https://guides.cocoapods.org/syntax/podfile.html#platform) you can find more information about platform values.

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
 
At this point you should be able to use VirgilSDK functionality in your code. See examples for most common tasks below.
If you encountered any issues with CocoaPods installations try to find more information at [cocoapods.org](https://guides.cocoapods.org/using/getting-started.html).

##### Swift note
Although VirgilSDK is using Objective-C as its primary language it might be quite easily used in a Swift application.
After VirgilSDK is installed as described in the *Getting started* section it is necessary to perform the following:

- Create a new header file in the Swift project.

- Name it something like *BridgingHeader.h*

- Put there the following lines:
``` objective-c
@import VirgilFoundation;
@import VirgilSDK;
```

- In the Xcode build settings find the setting called *Objective-C Bridging Header* and set the path to your *BridgingHeader.h* file. Be aware that this path is relative to your Xcode project's folder. After adding bridging header setting you should be able to use the SDK.

You can find more information about using Objective-C and Swift in the same project [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).

## Virgil Application token

Before you make any calls to the Virgil Servics you need to obtain an application token. Please, register [here](https://api.virgilsecurity.com/signin) or sign in if you already have an account.

This token is necessary for making any calls to the Virgil Services. 

#### Creating a key pair

###### Objective-C
```objective-c
@import VirgilFoundation;

//...
VSSKeyPair *keyPair = [[VSSKeyPair alloc] init];
//...
```

###### Swift
```swift
//...
let keyPair = VSSKeyPair()
//...
```

Optionally it is possible to create a new key pair protected by some password:

###### Objective-C
```objective-c
@import VirgilFoundation;

//...
VSSKeyPair *keyPair = [[VSSKeyPair alloc] initWithPassword:<#password#>];
//...
```

###### Swift
```swift
//...
let keyPair = VSSKeyPair(password:<#password#>)
//...
```

#### Setup VSSClient before making any calls

Requests to the service is an asynchronous network operation. VSSClient instance send the request and when it is done it calls completion handler block given as last parameter in any call. To get this work VSSClient instance should exist when the request is done. It is a good idea to make a property which will hold the VSSClient instance. 

#### TBD

## Requirements

Requires iOS 8.x or greater, OSX 10.11 or greater, WatchOS 2.0 or greater, tvOS 9.0 or greater.

## License

Usage is provided under the [The BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause). See LICENSE for the full details.