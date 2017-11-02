# Virgil Security Objective-C/Swift SDK

![VirgilSDK](https://cloud.githubusercontent.com/assets/6513916/19643783/bfbf78be-99f4-11e6-8d5a-a43394f2b9b2.png)

[![Build Status](https://api.travis-ci.org/VirgilSecurity/virgil-sdk-x.svg?branch=master)](https://travis-ci.org/VirgilSecurity/virgil-sdk-x)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilSDK.svg)](https://img.shields.io/cocoapods/v/VirgilSDK.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/VirgilSDK.svg?style=flat)](http://cocoadocs.org/docsets/VirgilSDK)
[![codecov.io](https://codecov.io/github/VirgilSecurity/virgil-sdk-x/coverage.svg)](https://codecov.io/github/VirgilSecurity/virgil-sdk-x/)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)

[Installation](#installation) | [Initialization](#initialization) | [Encryption / Decryption Example](#encryption) |[Documentation](#documentation) | [Support](#support)

[Virgil Security](https://virgilsecurity.com) provides a set of APIs for adding security to any application. In a few simple steps you can encrypt communication, securely store data, provide passwordless login, and ensure data integrity.

To initialize and use Virgil SDK, you need to have [Developer Account](https://developer.virgilsecurity.com/account/signin).

## Installation

The **Virgil SDK** is provided as module inside framework named **VirgilSDK**. VirgilSDK depends on another Virgil module called VirgilCrypto also packed inside framework named **VirgilCrypto**. Both packages are distributed via __Carthage__ and __CocoaPods__.

Packages are available for iOS 8.0+ and macOS 10.10+.


### Carthage

To integrate VirgilSDK into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), perform following steps:

- Create an empty file with name *Cartfile* in your project's root folder, that lists the frameworks you’d like to use in your project.
- Add the following line to your *Cartfile*

  ```ogdl
  github "VirgilSecurity/virgil-sdk-x" ~> 4.6.0
  ```

- Run *carthage update*. This will fetch dependencies into a *Carthage/Checkouts* folder inside your project's folder, then build each one or download a pre-compiled framework.
- On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, add each framework you want to use from the *Carthage/Build* folder inside your project's folder.
- On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script in which you specify your shell (ex: */bin/sh*), add the following contents to the script area below the shell:

  ```sh
  /usr/local/bin/carthage copy-frameworks
  ```

  and add the paths to the frameworks you want to use under “Input Files”, e.g.:

  ```
  $(SRCROOT)/Carthage/Build/iOS/VirgilCrypto.framework
  $(SRCROOT)/Carthage/Build/iOS/VirgilSDK.framework
  ```

### CocoaPods

To integrate VirgilSDK into your Xcode project using [CocoaPods](http://cocoapods.org), specify it in your *Podfile*:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'VirgilSDK', '~> 4.5.0'
end
```
Then, run the following command:

```
$ pod install
```

> CocoaPods 0.36+ is required to build VirgilSDK 4.0.0+.

To import VirgilSDK and VirgilCrypto after linking frameworks to your project add following lines to your source files:

##### Objective-C
``` objective-c
@import VirgilCrypto;
@import VirgilSDK;
```

##### Swift
``` swift
import VirgilCrypto
import VirgilSDK
```

### Swift note

Although VirgilSDK pod is using Objective-C as its primary language it might be quite easily used in a Swift application. All public API is available from Swift and is bridged using NS_SWIFT_NAME where needed.


## Initialization

Be sure that you have already registered at the [Dev Portal](https://developer.virgilsecurity.com/account/signin) and created your application.


To initialize the SDK at the __Client Side__ you need only the __Access Token__ created for a client at [Dev Portal](https://developer.virgilsecurity.com/account/signin). The Access Token helps to authenticate client's requests.

Swift initialization:

```
let virgil = VSSVirgilApi(token: "[ACCESS_TOKEN]")
```
Objective-C initialization:

```
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

# Encryption Example

Virgil Security simplifies adding encryption to any application. With our SDK you may create unique Virgil Cards for your all users and devices. With users' Virgil Cards, you can easily encrypt any data at Client Side.

```swift
// find Alice's Virgil Card(s) at Virgil Services
virgil.cards.searchCards(withIdentities: ["alice"]) { aliceCards, error in

  // encrypt the message using Alice's Virgil Cards
  let message = "Hello Alice!"
  let encryptedMessage = try! virgil.encrypt(message, for: aliceCards!)

  // transmit the message with your preferred technology
  self.transmit(message: encryptedMessage.base64EncodedString())
}
```

Alice then uses her stored __Virgil Private Key__ to decrypt the message.


```swift
// load Alice's Virgil Key from storage.
let aliceKey = try! virgil.keys.loadKey(withName: "alice_key_1", password: "mypassword")

// decrypt the message using the Alice's Virigl Key
let originalMessage = String(data: try! aliceKey.decrypt(transferData), encoding: .utf8)!
```

__Next:__ On the page below you can find configuration documentation and the list of our guides and use cases where you can see appliance of Virgil SDK.

## Documentation

Virgil Security has a powerful set of APIs and the documentation to help you get started:

* Get Started documentation
  * Encrypted storage ([Objective-C](/docs/objectivec/get-started/encrypted-storage.md) / [Swift](/docs/swift/get-started/encrypted-storage.md))
  * Encrypted communication ([Objective-C](/docs/objectivec/get-started/encrypted-communication.md) / [Swift](/docs/swift/get-started/encrypted-communication.md))
  * Data integrity ([Objective-C](/docs/objectivec/get-started/data-integrity.md) / [Swift](/docs/swift/get-started/data-integrity.md))
* Guides
  * Virgil Cards ([Objective-C](/docs/objectivec/guides/virgil-card) / [Swift](/docs/swift/guides/virgil-card))
  * Virgil Keys ([Objective-C](/docs/objectivec/guides/virgil-key) / [Swift](/docs/swift/guides/virgil-key))
  * Encryption ([Objective-C](/docs/objectivec/guides/encryption) / [Swift](/docs/swift/guides/encryption))
  * Signature ([Objective-C](/docs/objectivec/guides/signature) / [Swift](/docs/swift/guides/signature))
* Configuration
  * Set Up Client Side ([Objective-C](/docs/objectivec/guides/configuration/client.md) / [Swift](/docs/swift/guides/configuration/client.md))

* [Reference API](http://virgilsecurity.github.io/virgil-sdk-x/)

Also, see our Virgil [Swift SDK for PFS](https://github.com/VirgilSecurity/virgil-sdk-pfs-x) Encrypted Communication to protect previously intercepted traffic from being decrypted even if the main Private Key is compromised.

## License

This library is released under the [3-clause BSD License](LICENSE.md).

## Support

Our developer support team is here to help you. You can find us on [Twitter](https://twitter.com/virgilsecurity) and [email][support].

[support]: mailto:support@virgilsecurity.com
