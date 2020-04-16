# Virgil Security Objective-C/Swift SDK

[![Build Status](https://api.travis-ci.com/VirgilSecurity/virgil-sdk-x.svg?branch=master)](https://travis-ci.com/VirgilSecurity/virgil-sdk-x)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilSDK.svg)](https://cocoapods.org/pods/VirgilSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/VirgilSDK.svg?style=flat)](https://cocoapods.org/pods/VirgilSDK)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)

[Introduction](#introduction) | [SDK Features](#sdk-features) | [Installation](#installation) | [Usage Examples](#usage-examples) | [Docs](#docs) | [Support](#support)


## Introduction

<a href="https://developer.virgilsecurity.com/docs"><img width="230px" src="https://cdn.virgilsecurity.com/assets/images/github/logos/virgil-logo-red.png" align="left" hspace="10" vspace="6"></a> [Virgil Security](https://virgilsecurity.com) provides a set of APIs for adding security to any application. In a few simple steps you can encrypt communication, securely store data, provide passwordless login, and ensure data integrity.

The Virgil SDK allows developers to get up and running with Virgil API quickly and add full end-to-end security to their existing digital solutions to become HIPAA and GDPR compliant and more.

## SDK Features
- communicate with [Virgil Cards Service][_cards_service]
- manage users' Public Keys
- store private keys in secure local storage
- use Virgil [Crypto library][_virgil_crypto]
- use your own Crypto


## Installation

Virgil SDK is provided as a set of frameworks. These frameworks are distributed via Carthage and CocoaPods.  Also in this guide, you find one more package called VirgilCrypto (Virgil Crypto Library) that is used by the SDK to perform cryptographic operations.

All frameworks are available for:
- iOS 9.0+
- macOS 10.11+
- tvOS 9.0+
- watchOS 2.0+

### COCOAPODS

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate VirgilSDK into your Xcode project using CocoaPods, specify it in your *Podfile*:

```bash
target '<Your Target Name>' do
  use_frameworks!

  pod 'VirgilSDK', '~> 7.2'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate VirgilSDK into your Xcode project using Carthage, create an empty file with name *Cartfile* in your project's root folder and add following lines to your *Cartfile*

```
github "VirgilSecurity/virgil-sdk-x" ~> 7.2
```

#### Linking against prebuilt binaries

To link prebuilt frameworks to your app, run following command:

```bash
$ carthage update --no-use-binaries
```

This will build each dependency or download a pre-compiled framework from github Releases.

##### Building for iOS/tvOS/watchOS

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, add following frameworks from the *Carthage/Build* folder inside your project's folder:
 - VirgilSDK
 - VirgilCrypto
 - VirgilCryptoFoundation
 - VSCCommon
 - VSCFoundation

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase.” Create a Run Script in which you specify your shell (ex: */bin/sh*), add the following contents to the script area below the shell:

```bash
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”, e.g.:

```
$(SRCROOT)/Carthage/Build/iOS/VirgilSDK.framework
$(SRCROOT)/Carthage/Build/iOS/VirgilCrypto.framework
$(SRCROOT)/Carthage/Build/iOS/VirgilCryptoFoundation.framework
$(SRCROOT)/Carthage/Build/iOS/VSCCommon.framework
$(SRCROOT)/Carthage/Build/iOS/VSCFoundation.framework
```

##### Building for macOS

On your application target's “General” settings tab, in the “Embedded Binaries” section, drag and drop following frameworks from the Carthage/Build folder on disk:
 - VirgilSDK
 - VirgilCrypto
 - VirgilCryptoFoundation
 - VSCCommon
 - VSCFoundation

Additionally, you'll need to copy debug symbols for debugging and crash reporting on macOS.

On your application target’s “Build Phases” settings tab, click the “+” icon and choose “New Copy Files Phase”.
Click the “Destination” drop-down menu and select “Products Directory”. For each framework, drag and drop corresponding dSYM file.

## Usage Examples

Before starting practicing with the usage examples be sure that the SDK is configured. Check out our [SDK configuration guides][_configure_sdk] for more information.

#### Generate key pair using VirgilCrypto

```swift
import VirgilCrypto

let crypto = try! VirgilCrypto()

let keyPair = try! crypto.generateKeyPair()
```

#### Save and retrieve key using keychain storage

```swift
import VirgilSDK
import VirgilCrypto

let storageParams = try! KeychainStorageParams.makeKeychainStorageParams()
let keychainStorage = KeychainStorage(storageParams: storageParams)

// export key to Data
let data = try! crypto.exportPrivateKey(keyPair.privateKey)

let identity = "Alice"

// save key data
let entry = try! keychainStorage.store(data: data, withName: identity, meta: nil)

// retrieve key data
let retrievedEntry = try! keychainStorage.retrieveEntry(withName: identity)

// import key from Data
let privateKey = try! exporter.importPrivateKey(from: retrievedEntry.data)
```

#### Generate and publish user's Cards with Public Keys inside on Cards Service
Use the following lines of code to create and publish a user's Card with Public Key inside on Virgil Cards Service:

```swift
import VirgilSDK
import VirgilCrypto

// save a private key into key storage
let data = try! crypto.exportPrivateKey(keyPair.privateKey)
let entry = try! keychainStorage.store(data: data, withName: "Alice", meta: nil)

// publish user's card on the Cards Service
cardManager.publishCard(privateKey: keyPair.privateKey, publicKey: keyPair.publicKey).start { result in
    switch result {
        // Card is created
        case .success(let card): break
        // Error occured
        case .failure(let error): break
    }
}
```

#### Sign then encrypt data

Virgil SDK lets you use a user's Private key and his or her Cards to sign, then encrypt any kind of data.

In the following example, we load a Private Key from a customized Key Storage and get recipient's Card from the Virgil Cards Services. Recipient's Card contains a Public Key on which we will encrypt the data and verify a signature.

```swift
import VirgilSDK
import VirgilCrypto

// prepare a message
let messageToEncrypt = "Hello, Bob!"
let dataToEncrypt = messageToEncrypt.data(using: .utf8)!

// prepare a user's private key
let alicePrivateKeyEntry = try! keychainStorage.retrieveEntry(withName: "Alice")
let alicePrivateKey = try! crypto.importPrivateKey(from: alicePrivateKeyEntry.data)

// using cardManager search for user's cards on Cards Service
cardManager.searchCards(identities: ["Bob"]).start { result in
    switch result {
    // Cards are obtained
    case .success(let cards):
        let bobRelevantCardsPublicKeys = cards
            .map { $0.publicKey }

        // sign a message with a private key then encrypt on a public key
        let encryptedData = try! crypto.signAndEncrypt(dataToEncrypt,
                                                       with: alicePrivateKey,
                                                       for: bobRelevantCardsPublicKeys)

    // Error occured
    case .failure(let error): break
    }
}
```

#### Decrypt then verify data

Once the Users receive the signed and encrypted message, they can decrypt it with their own Private Key and verify signature with a Sender's Card:

```swift
import VirgilSDK
import VirgilCrypto

// prepare a user's private key
let bobPrivateKeyEntry = try! keychainStorage.retrieveEntry(withName: "Bob")
let bobPrivateKey = try! exporter.importPrivateKey(from: bobPrivateKeyEntry.data)

// using cardManager search for user's cards on Cards Service
cardManager.searchCards(identities: ["Alice"]).start { result in
    switch result {
    // Cards are obtained
    case .success(let cards):
        let aliceRelevantCardsPublicKeys = cards.map { $0.publicKey }

        // decrypt with a private key and verify using a public key
        let decryptedData = try! crypto.decryptAndVerify(encryptedData, 
                                                         with: bobPrivateKey,
                                                         usingOneOf: aliceRelevantCardsPublicKeys)

    // Error occured
    case .failure(let error): break
    }
}
```

#### Revoke card

User can revoke his card in case he doesn't need it anymore. Revoked card can still be obained using its identifier, but this card won't appear during search query.

```swift
import VirgilSDK

let result = cardManager.revokeCard(withId: card.identifier).start { result in
    switch result {
        // Card is revoked
        case .success: break
        // Error occured
        case .failure(let error): break
    }
}
```

## Docs
Virgil Security has a powerful set of APIs, and the documentation below can get you started today.

In order to use the Virgil SDK with your application, you will need to first configure your application. By default, the SDK will attempt to look for Virgil-specific settings in your application but you can change it during SDK configuration.

* [Configure the SDK][_configure_sdk] documentation
  * [Setup authentication][_setup_authentication] to make API calls to Virgil Services
  * [Setup Card Manager][_card_manager] to manage user's Public Keys
  * [Setup Card Verifier][_card_verifier] to verify signatures inside of user's Card
  * [Setup Key storage][_key_storage] to store Private Keys
  * [Setup your own Crypto library][_own_crypto] inside of the SDK
* [More usage examples][_more_examples]
  * [Create & publish a Card][_create_card] that has a Public Key on Virgil Cards Service
  * [Search user's Card by user's identity][_search_card]
  * [Get user's Card by its ID][_get_card]
  * [Use Card for crypto operations][_use_card]
* [Reference API][_reference_api]


## License

This library is released under the [3-clause BSD License](LICENSE).

## Support
Our developer support team is here to help you. Find out more information on our [Help Center](https://help.virgilsecurity.com/).

You can find us on [Twitter](https://twitter.com/VirgilSecurity) or send us email support@VirgilSecurity.com.

Also, get extra help from our support team on [Slack](https://virgilsecurity.com/join-community).

[_virgil_crypto]: https://github.com/VirgilSecurity/virgil-crypto-x
[_cards_service]: https://developer.virgilsecurity.com/docs/api-reference/card-service/v5
[_use_card]: https://developer.virgilsecurity.com/docs/swift/how-to/public-key-management/v5/use-card-for-crypto-operation
[_get_card]: https://developer.virgilsecurity.com/docs/swift/how-to/public-key-management/v5/get-card
[_search_card]: https://developer.virgilsecurity.com/docs/swift/how-to/public-key-management/v5/search-card
[_create_card]: https://developer.virgilsecurity.com/docs/swift/how-to/public-key-management/v5/create-card
[_own_crypto]: https://developer.virgilsecurity.com/docs/swift/how-to/setup/v5/setup-own-crypto-library
[_key_storage]: https://developer.virgilsecurity.com/docs/swift/how-to/setup/v5/setup-key-storage
[_card_verifier]: https://developer.virgilsecurity.com/docs/swift/how-to/setup/v5/setup-card-verifier
[_card_manager]: https://developer.virgilsecurity.com/docs/swift/how-to/setup/v5/setup-card-manager
[_setup_authentication]: https://developer.virgilsecurity.com/docs/swift/how-to/setup/v5/setup-authentication
[_reference_api]: https://developer.virgilsecurity.com/docs/api-reference
[_configure_sdk]: https://developer.virgilsecurity.com/docs/how-to#sdk-configuration
[_more_examples]: https://developer.virgilsecurity.com/docs/how-to#public-key-management
