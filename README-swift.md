# Virgil Security Objective-C/Swift SDK

![VirgilSDK](https://cloud.githubusercontent.com/assets/6513916/19643783/bfbf78be-99f4-11e6-8d5a-a43394f2b9b2.png)

[![Build Status](https://api.travis-ci.org/VirgilSecurity/virgil-sdk-x.svg?branch=master)](https://travis-ci.org/VirgilSecurity/virgil-sdk-x)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilSDK.svg)](https://img.shields.io/cocoapods/v/VirgilSDK.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/VirgilSDK.svg?style=flat)](http://cocoadocs.org/docsets/VirgilSDK)
[![codecov.io](https://codecov.io/github/VirgilSecurity/virgil-sdk-x/coverage.svg)](https://codecov.io/github/VirgilSecurity/virgil-sdk-x/)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)

[Installation](#installation) | [Encryption Example / Decryption Example](#encryption-example) | [Initialization](#initialization) | [Documentation](#documentation) | [Migration notes](#migration-notes) | [Support](#support)

[Virgil Security](https://virgilsecurity.com) provides a set of APIs for adding security to any application. In a few steps, you can encrypt communication, securely store data, provide passwordless authentication, and ensure data integrity.

To initialize and use Virgil SDK, you need to have [Developer Account](https://developer.virgilsecurity.com/account/signin).

## Installation

The **Virgil SDK** is provided as module inside framework named **VirgilSDK**. VirgilSDK depends on another Virgil module called VirgilCrypto also packed inside framework named **VirgilCrypto**.
Both packages are distributed via Carthage and CocoaPods. Carthage is RECOMMENDED way to integrate VirgilSDK into your projects. Carthage integration is easy, convenient and you can simultaniously use CocoaPods to manage all other dependencies. CocoaPods support for versions above 4.5.0 is SUSPENDED, more info below under CocoaPods section.

Packages are available for iOS 8.0+ and macOS 10.10+.

To link frameworks to your project follow instructions depending on package manager of your choice:

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate VirgilSDK into your Xcode project using Carthage, perform following steps:

##### If you're building for iOS

1. Create an empty file with name `Cartfile` in your project's root folder, that lists the frameworks you’d like to use in your project.
1. Add the following line to your `Cartfile`

    ```ogdl
    github "VirgilSecurity/virgil-sdk-x" ~> 4.6.0
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
  $(SRCROOT)/Carthage/Build/iOS/VirgilCrypto.framework
  ```

This script works around an [App Store submission bug](http://www.openradar.me/radar?id=6409498411401216) triggered by universal binaries and ensures that necessary bitcode-related files and dSYMs are copied when archiving.

With the debug information copied into the built products directory, Xcode will be able to symbolicate the stack trace whenever you stop at a breakpoint. This will also enable you to step through third-party code in the debugger.

When archiving your application for submission to the App Store or TestFlight, Xcode will also copy these files into the dSYMs subdirectory of your application’s `.xcarchive` bundle.

##### If you're building for macOS

1. Create an empty file with name `Cartfile` in your project's root folder, that lists the frameworks you’d like to use in your project.
1. Add the following line to your `Cartfile`

    ```ogdl
    github "VirgilSecurity/virgil-sdk-x" ~> 4.6.0
    ```

1. Run `carthage update`. This will fetch dependencies into a `Carthage/Checkouts` folder inside your project's folder, then build each one or download a pre-compiled framework.
1. On your application targets’ “General” settings tab, in the “Embedded Binaries” section, drag and drop each framework you want to use from the `Carthage/Build` folder inside your project's folder including VirgilSDK.framework and VirgilCrypto.framework.

Additionally, you'll need to copy debug symbols for debugging and crash reporting on OS X.

1. On your application target’s “Build Phases” settings tab, click the “+” icon and choose “New Copy Files Phase”.
1. Click the “Destination” drop-down menu and select “Products Directory”.
1. For each framework you’re using, drag and drop its corresponding dSYM file.

### CocoaPods

**CocoaPods support for versions above 4.5.0 is SUSPENDED**.
We RECOMMEND using Carthage to integrate VirgilSDK. For versions 4.5.0 and lower you can integrate using CocoaPods without use_frameworks! option in your podfile. The reason for this is that VirgilCrypto framework, which VirgilSDK depends on, includes static library, this creates transitive dependency with static library.
More info can be found here:
https://github.com/CocoaPods/CocoaPods/issues/6848
and here:
https://github.com/CocoaPods/CocoaPods/pull/6811.



[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate VirgilSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

target '<Your Target Name>' do
    pod 'VirgilSDK', '~> 4.5.0'
end
```

Then, run the following command:

```bash
$ pod install
```

 To import VirgilSDK and VirgilCrypto after linking frameworks to your project add following lines to your source files:

###### Objective-C
``` objective-c
@import VirgilCrypto;
@import VirgilSDK;
```

###### Swift
``` swift
import VirgilCrypto
import VirgilSDK
```

## Swift note

Although VirgilSDK pod is using Objective-C as its primary language it might be quite easily used in a Swift application.
All public API is available from Swift and is bridged using NS_SWIFT_NAME where needed.

__Next:__ [Get Started with the Objective-C/Swift SDK][_getstarted].



## Initialization

Be sure that you have already registered at the [Dev Portal](https://developer.virgilsecurity.com/account/signin) and created your application.

To initialize the SDK at the __Client Side__ you need only the __Access Token__ created for a client at [Dev Portal](https://developer.virgilsecurity.com/account/signin). The Access Token helps to authenticate client's requests.

```swift
let virgil = VSSVirgilApi(token: "[ACCESS_TOKEN]")
```

> __Note:__ this client will have limited capabilities. For example, it will be able to generate new __Cards__ but it will need a server-side client to transmit these to Virgil.

To initialize the SDK at the __Server Side__ you need the application credentials (__Access Token__, __App ID__, __App Key__ and __App Key Password__) you got during Application registration at the [Dev Portal](https://developer.virgilsecurity.com/account/signin).

```swift
let url = Bundle.main.url(forResource: "[YOUR_APP_KEY_FILENAME_HERE]", withExtension: nil)!
let appPrivateKeyData = try! Data(contentsOf: url)
let credentials = VSSCredentials(appKeyData: appPrivateKeyData, appKeyPassword: "[YOUR_APP_KEY_PASSWORD_HERE]", appId: "[YOUR_APP_ID_HERE]")

let context = VSSVirgilApiContext(crypto: nil, token: "[YOUR_ACCESS_TOKEN_HERE]", credentials: credentials, cardVerifiers: nil)

let virgil = VSSVirgilApi(context: context)
```


# Encryption Example / Decryption Example

Virgil Security simplifies adding encryption to any application. With our SDK you may create unique Virgil Cards for your all users and devices. With users' Virgil Cards, you can easily encrypt any data at Client Side.

```swift
// find Alice's card(s)
virgil.cards.searchCards(withIdentities: ["alice"]) { aliceCards, error in
  // encrypt the message using Alice's cards
  let message = "Hello Alice!"
  let encryptedMessage = try! virgil.encrypt(message, for: aliceCards!)

  // transmit the message with your preferred technology
  self.transmit(message: encryptedMessage.base64EncodedString())
}
```

Alice uses her Virgil Private Key to decrypt the encrypted message.


```swift
// load Alice's Key from storage.
let aliceKey = try! virgil.keys.loadKey(withName: "alice_key_1", password: "mypassword")

// decrypt the message using the key
let originalMessage = String(data: try! aliceKey.decrypt(transferData), encoding: .utf8)!
```

__Next:__ On the page below you can find configuration documentation and the list of our guides and use cases where you can see appliance of Virgil SWIFT SDK.


## Documentation

Virgil Security has a powerful set of APIs and the documentation to help you get started:

* [Get Started](/documentation/get-started) documentation
  * [Encrypted storage](/documentation/get-started/encrypted-storage.md)
  * [Encrypted communication](/documentation/get-started/encrypted-communication.md)
  * [Data integrity](/documentation/get-started/data-integrity.md)
* [Guides](/documentation/guides)
  * [Virgil Cards](/documentation/guides/virgil-card)
  * [Virgil Keys](/documentation/guides/virgil-key)
  * [Encryption](/documentation/guides/encryption)
  * [Signature](/documentation/guides/signature)
* [Configuration](/documentation/guides/configuration)
  * [Set Up Client Side](/documentation/guides/configuration/client.md)
  * [Set Up Client (PFS) Side](/documentation/guides/configuration/server.md)

__Next__ Also, see our Virgil [.NET/C# SDK for PFS](https://github.com/VirgilSecurity/virgil-pfs-net) Encrypted Communication to protect previously intercepted traffic from being decrypted even if the main Private Key is compromised.

## Migration notes

For users of versions prior to 4.4.0 we recommend checking out version 4.4.0+ with completely new and more convenient API.
Anyway, old API is still available, so anyone can migrate with little changes to the source sode. Therefore, it is recommended to migrate to the newest version for ALL users.
List of the most important changes:
- Renaming: VSSCreateGlobalCardRequest -> VSSCreateEmailCardRequest
- Renaming: VSSCreateCardRequest -> VSSCreateUserCardRequest
- Renaming: VSSRevokeGlobalCardRequest -> VSSRevokeEmailCardRequest
- Renaming: VSSRevokeCardRequest -> VSSRevokeUserCardRequest

## License

This library is released under the [3-clause BSD License](LICENSE.md).

## Support

Our developer support team is here to help you. You can find us on [Twitter](https://twitter.com/virgilsecurity) and [email][support].

[support]: mailto:support@virgilsecurity.com
