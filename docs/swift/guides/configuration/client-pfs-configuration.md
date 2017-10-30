# Client Configuration

In order to use the Virgil Infrastructure, set up your client and implement required mechanisms using the following guide.

## Install SDK

The Virgil PFS is provided as a package.

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate VirgilSDKPFS into your Xcode project using Carthage, perform following steps:

- Create an empty file with name *Cartfile* in your project's root folder, that lists the frameworks you’d like to use in your project.
- Add the following line to your *Cartfile*

```ogdl
github "VirgilSecurity/virgil-sdk-pfs-x" "master"
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
$(SRCROOT)/Carthage/Build/iOS/VirgilSDKPFS.framework
```


## Obtain an Access Token
When users want to start sending and receiving messages in a browser or mobile device, Virgil can't trust them right away. Clients have to be provided with unique identity, thus, you need to give your users the Access Token that tells Virgil who they are and what they can do.

Each your client sends to you Access Token request with their registration request. Then, your service, responsible for handling access requests, handles them if users were successfully registered on your Application server.

```
// an example of an Access Token representation
AT.7652ee415726a1f43c7206e4b4bc67ac935b53781f5b43a92540e8aae5381b14
```

## Initialize SDK
With the Access Token, we can initialize the Virgil PFS SDK on the client side to start doing stuff like sending and receiving messages. To initialize the Virgil PFS SDK on a client side, you need to use the following code:

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```
