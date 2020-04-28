# Virgil Core SDK Objective-C/Swift

[![Build Status](https://api.travis-ci.com/VirgilSecurity/virgil-sdk-x.svg?branch=master)](https://travis-ci.com/VirgilSecurity/virgil-sdk-x)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilSDK.svg)](https://cocoapods.org/pods/VirgilSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/VirgilSDK.svg?style=flat)](https://cocoapods.org/pods/VirgilSDK)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)


[Introduction](#introduction) | [SDK Features](#sdk-features) | [Installation](#installation) | [Configure SDK](#configure-sdk) | [Usage Examples](#usage-examples) | [Docs](#docs) | [Support](#support)

## Introduction

<a href="https://developer.virgilsecurity.com/docs"><img width="230px" src="https://cdn.virgilsecurity.com/assets/images/github/logos/virgil-logo-red.png" align="left" hspace="10" vspace="6"></a> [Virgil Security](https://virgilsecurity.com) provides a set of APIs for adding security to any application. In a few simple steps you can encrypt communications, securely store data, and ensure data integrity. Virgil Security products are available for desktop, embedded (IoT), mobile, cloud, and web applications in a variety of modern programming languages.

The Virgil Core SDK is a low-level library that allows developers to get up and running with [Virgil Cards Service API](https://developer.virgilsecurity.com/docs/platform/api-reference/cards-service/) quickly and add end-to-end security to their new or existing digital solutions.

In case you need additional security functionality for multi-device support, group chats and more, try our high-level [Virgil E3Kit framework](https://github.com/VirgilSecurity/awesome-virgil#E3Kit).

## SDK Features
- Communicate with [Virgil Cards Service](https://developer.virgilsecurity.com/docs/platform/api-reference/cards-service/)
- Manage users' public keys
- Encrypt, sign, decrypt and verify data
- Store private keys in secure local storage
- Use [Virgil Crypto Library](https://github.com/VirgilSecurity/virgil-crypto-x)

## Installation

Virgil Core SDK is provided as a set of frameworks. These frameworks are distributed via Carthage and CocoaPods. In this guide you'll also find one more package - Virgil Crypto Library, that is used by the SDK to perform cryptographic operations.

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

## Configure SDK

This section contains guides on how to set up Virgil Core SDK modules for authenticating users, managing Virgil Cards and storing private keys.

### Set up authentication

Set up user authentication with tokens that are based on the [JSON Web Token standard](https://jwt.io/) with some Virgil modifications.

In order to make calls to Virgil Services (for example, to publish user's Card on Virgil Cards Service), you need to have a JSON Web Token ("JWT") that contains the user's `identity`, which is a string that uniquely identifies each user in your application.

Credentials that you'll need:

|Parameter|Description|
|--- |--- |
|App ID|ID of your Application at [Virgil Dashboard](https://dashboard.virgilsecurity.com)|
|App Key ID|A unique string value that identifies your account at the Virgil developer portal|
|App Key|A Private Key that is used to sign API calls to Virgil Services. For security, you will only be shown the App Key when the key is created. Don't forget to save it in a secure location for the next step|

#### Set up JWT provider on Client side

Use these lines of code to specify which JWT generation source you prefer to use in your project:

```swift
import VirgilSDK

// Get generated token from server-side
let authenticatedQueryToServerSide: ((String) -> Void) -> Void = { completion in
    completion("eyJraWQiOiI3MGI0NDdlMzIxZj....MK7p7Ak")
}

// Setup AccessTokenProvider
let accessTokenProvider = CallbackJwtProvider { tokenContext, completion in
    authenticatedQueryToServerSide { jwtString in
        completion(jwtString, nil)
    }
}
```

#### Generate JWT on Server side

For this subsection we've created a sample backend that demonstrates how you can set up your backend to generate the JWTs. To set up and run the sample backend locally, head over to your GitHub repo of choice:

[Node.js](https://github.com/VirgilSecurity/sample-backend-nodejs) | [Golang](https://github.com/VirgilSecurity/sample-backend-go) | [PHP](https://github.com/VirgilSecurity/sample-backend-php) | [Java](https://github.com/VirgilSecurity/sample-backend-java) | [Python](https://github.com/VirgilSecurity/virgil-sdk-python/tree/master#sample-backend-for-jwt-generation)
 and follow the instructions in README.
 
### Set up Card Verifier

Virgil Card Verifier helps you automatically verify signatures of a user's Card, for example when you get a Card from Virgil Cards Service.

By default, `VirgilCardVerifier` verifies only two signatures - those of a Card owner and Virgil Cards Service.

Set up `VirgilCardVerifier` with the following lines of code:

```swift
import VirgilSDK
import VirgilCrypto

// initialize Crypto library
let cardCrypto = VirgilCardCrypto()

let yourBackendVerifierCredentials =
    VerifierCredentials(signer: "YOUR_BACKEND",
                        publicKey: Data(base64Encoded: publicKeyStr)!)

let yourBackendWhitelist =
    try! Whitelist(verifiersCredentials: [yourBackendVerifierCredentials])

let cardVerifier = VirgilCardVerifier(cardCrypto: cardCrypto,
                                      whitelists: [yourBackendWhitelist])

```

### Set up Card Manager

This subsection shows how to set up a Card Manager module to help you manage users' public keys.

With Card Manager you can:
- specify an access Token (JWT) Provider.
- specify a Card Verifier used to verify signatures of your users, your App Server, Virgil Services (optional).

Use the following lines of code to set up the Card Manager:

```swift
// initialize cardManager and specify accessTokenProvider, cardVerifier
let cardManagerParams = CardManagerParams(cardCrypto: cardCrypto,
                                          accessTokenProvider: accessTokenProvider,
                                          cardVerifier: cardVerifier)

let cardManager = CardManager(params: cardManagerParams)
```

## Usage Examples

Before you start practicing with the usage examples, make sure that the SDK is configured. See the [Configure SDK](#configure-sdk) section for more information.

### Generate and publish Virgil Cards at Cards Service

Use the following lines of code to create a user's Card with a public key inside and publish it at Virgil Cards Service:

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

### Sign then encrypt data

Virgil Core SDK allows you to use a user's private key and their Virgil Cards to sign and encrypt any kind of data.

In the following example, we load a private key from a customized key storage and get recipient's Card from the Virgil Cards Service. Recipient's Card contains a public key which we will use to encrypt the data and verify a signature.

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

### Decrypt data and verify signature

Once the user receives the signed and encrypted message, they can decrypt it with their own private key and verify the signature with the sender's Card:

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

### Get Card by its ID

Use the following lines of code to get a user's card from Virgil Cloud by its ID:

```swift
import VirgilSDK

// using cardManager get a user's card from the Cards Service
cardManager.getCard(withId: "f4bf9f7fcbedaba0392f108c59d8f4a38b3838efb64877380171b54475c2ade8").start { result in
    switch result {
    // Card is obtained
    case .success(let card): break
    // Error occurred
    case .failure(let error): break
    }
}
```

### Get Card by user's identity

For a single user, use the following lines of code to get a user's Card by a user's `identity`:

```swift
import VirgilSDK

// using cardManager search for user's cards on Cards Service
cardManager.searchCards(identity: "Bob").start { result in
    switch result {
    // Cards are obtained
    case .success(let cards): break
    // Error occurred
    case .failure(let error): break
    }
}
```

### Revoke Card

You can revoke user's Card in case they don't need it anymore. Revoked Card can still be obtained using its identifier, but this card won't appear during search query.

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

### Generate key pair using VirgilCrypto

You can generate a key pair and save it in a secure key storage with the following code:

```swift
import VirgilCrypto

let crypto = try! VirgilCrypto()

let keyPair = try! crypto.generateKeyPair()
```

### Save and retrieve key using keychain storage

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

## Docs

Virgil Security has a powerful set of APIs, and the [Developer Documentation](https://developer.virgilsecurity.com/) can get you started today.

## License

This library is released under the [3-clause BSD License](LICENSE).

## Support

Our developer support team is here to help you. Find out more information on our [Help Center](https://help.virgilsecurity.com/).

You can find us on [Twitter](https://twitter.com/VirgilSecurity) or send us email support@VirgilSecurity.com.

Also, get extra help from our support team on [Slack](https://virgilsecurity.com/join-community).
