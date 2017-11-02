# Client Configuration

To use the Virgil Infrastructure, set up your client and implement the required mechanisms using the following guide.


## Install SDK

The Virgil PFS is provided as a package. The package is distributed via Carthage and CocoaPods.

The package is available for:
- iOS 7.0+

### COCOAPODS

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate VirgilSDK into your Xcode project using CocoaPods, specify it in your *Podfile*:

```bash
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'VirgilSDK', '~> 4.5.0'
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


## Obtain an Access Token
When users want to start sending and receiving messages on computer or mobile device, Virgil can't trust them right away. Clients have to be provided with a unique identity, thus, you'll need to give your users the Access Token that tells Virgil who they are and what they can do.

Each your client must send to you the Access Token request with their registration request. Then, your service that will be responsible for handling access requests must handle them in case of users successful registration on your Application server.

```
// an example of an Access Token representation
AT.7652ee415726a1f43c7206e4b4bc67ac935b53781f5b43a92540e8aae5381b14
```

## Initialize SDK

### With a Token
With Access Token, we can initialize the Virgil PFS SDK on the client side to start doing fun stuff like sending and receiving messages. To initialize the **Virgil SDK** on the client side, you need to use the following code:

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

### Without a Token

In case of a **Global Virgil Card** creation you don't need to initialize the SDK with the Access Token. For more information about the Global Virgil Card creation check out the [Creating Global Card](/docs/objectivec/guides/virgil-card/creating-global-card.md) guide.

Use the following code to initialize Virgil SDK without Access Token.

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc] init];
```
