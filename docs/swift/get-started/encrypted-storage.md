# Encrypted Storage
[Set Up Server](#head1) | [Set Up Clients](#head2) | [Register Users](#head3) | [Encrypt Data](#head4) | [Decrypt Data](#head5)

You may encrypt data for secure storage in the Cloud in a few steps. In this tutorial, we show a user how to fully (end-to-end) **encrypt** data.

Privacy is even more important when it comes to cloud-based storage. If servers ever get hacked, it is necessary to know the files are safe.
Virgil Security gives developers open source API with the full cycle of data security that supports almost every platform and language.


## <a name="head1"></a> Set Up Server
Your server should be able to authorize your users, store Application's Virgil Key and use **Virgil SDK** for cryptographic operations or for some requests to Virgil Services.

SWIFT is not supported on the server side.
We recommend using one of the next SDKs:
* [RUBY](https://github.com/VirgilSecurity/virgil-sdk-ruby/tree/v4)
* [PHP](https://github.com/VirgilSecurity/virgil-sdk-php/tree/v4)
* [GO](https://github.com/VirgilSecurity/virgil-crypto-go/tree/v4)
* [JAVASCRIPT](https://github.com/VirgilSecurity/virgil-sdk-javascript/tree/v4)
* [JAVA](https://github.com/VirgilSecurity/virgil-sdk-java-android/tree/v4)
* [PYTHON](https://github.com/VirgilSecurity/virgil-sdk-python/tree/v4)
* [C#/.NET](https://github.com/VirgilSecurity/virgil-sdk-net/tree/v4)



## <a name="head2"></a> Set Up Clients
Set up the client side. After users register at your Application Server, provide them with an access token that authenticates users for further operations and transmit their **Virgil Cards** to the server. Configure the client side using the [Setup Guide](/docs/swift/guides/configuration/client.md).


## <a name="head3"></a> Register Users
Now you need to register the users who will encrypt data.

To encrypt a data each user must have his own tools, which allow him to perform cryptographic operations, and these tools must contain the necessary information to identify users. In Virgil Security, these tools are the Virgil Key and the Virgil Card.

![Virgil Card](/docs/swift/img/Card_introduct.png "Create Virgil Card")

When we have already set up the Virgil SDK on the server & client sides, we can finally create Virgil Cards for the users and transmit the Cards to your Server for further publication on Virgil Services.


### Generate Keys and Create Virgil Card
Use the Virgil SDK on the client side to generate a new Key Pair, and then create a user's Virgil Card using the recently generated Virgil Key. All keys are generated and stored on the client side.

In this example, we will pass on the user's username and a password, which will lock in their private encryption key. Each Virgil Card is signed by a user's Virgil Key, which guarantees the Virgil Card content integrity over its life cycle.

```swift
// generate a new Virgil Key
let aliceKey = virgil.keys.generateKey()

// save the Virgil Key into storage
try! aliceKey.store(withName: @"[KEY_NAME]",
  password: @"[KEY_PASSWORD]")

// create identity for Alice
let aliceIdentity = virgil.identities.
  createUserIdentity(withValue: "alice", type: "name")

// create a Virgil Card
let aliceCard = try! virgil.cards.
  createCard(with: aliceIdentity, ownerKey:aliceKey)
```

**Warning**: Virgil doesn't keep a copy of your Virgil Key. If you lose a Virgil Key, there is no way to recover it.

It should be noted that recently created user Virgil Cards will be visible only for application users because they are related to the Application.

Read more about Virgil Cards and their types [here](/docs/swift/guides/virgil-card/creating-card.md).


### Transmit the Cards to Your Server

Next, you must serialize and transmit this Card to your server, where you will approve and publish users' Cards.

```swift
// export a Virgil Card to string
let exportedCard = aliceCard.exportData()

// transmit the Virgil Card to the server
TransmitToServer(exportedCard)
```

SWIFT is not supported for publishing Virgil Cards on Virgil Services.
We recommend using one of the next SDKs:
* [RUBY](https://github.com/VirgilSecurity/virgil-sdk-ruby/tree/v4): [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-ruby/blob/v4/docs/guides/configuration/server.md#-approve--publish-cards)  
* [PHP](https://github.com/VirgilSecurity/virgil-sdk-php/tree/v4): [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-php/blob/v4/docs/guides/configuration/server-configuration.md#-approve--publish-cards)  
* [GO](https://github.com/VirgilSecurity/virgil-crypto-go/tree/v4): [approve & publish users guide](https://github.com/go-virgil/virgil/blob/v4/docs/guides/configuration/server-configuration.md#-approve--publish-cards)  
* [JAVASCRIPT](https://github.com/VirgilSecurity/virgil-sdk-javascript/tree/v4): [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-javascript/blob/v4/docs/guides/configuration/server.md#-approve--publish-cards)  
* [JAVA](https://github.com/VirgilSecurity/virgil-sdk-java-android/tree/v4): [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-java-android/blob/v4/docs/guides/configuration/server-configuration.md#-approve--publish-cards)  
* [PYTHON](https://github.com/VirgilSecurity/virgil-sdk-python/tree/v4): [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-python/blob/v4/documentation/guides/configuration/server.md#-approve--publish-cards)  
* [C#/.NET](https://github.com/VirgilSecurity/virgil-sdk-net/tree/v4): [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-net/blob/v4/documentation/guides/configuration/server.md#-approve--publish-cards)  



## <a name="head4"></a> Encrypt Data

With the Virgil Card created, we're ready to start encrypting data which will then be stored in the encrypted storage. In this case we will encrypt some data for Alice, using her own Virgil Card.

![encrypted storage](/docs/swift/img/encrypted_storage_upload.png "Encrypt data")

To encrypt data, the user must search for Virgil Cards at Virgil Services, where all Virgil Cards are saved.

```swift
// search for Virgil Cards
virgil.cards.searchCards(withIdentities: ["alice"]) { aliceCards, error in
	let url = Bundle.main.url(forResource: "FILE_NAME_HERE",
	withExtension: "FILE_EXTENSION_HERE")!
    let fileBuf = try! Data(contentsOf: url)

	// encrypt the buffer using found Virgil Cards
	let cipherFileBuf = try! virgil.encrypt(fileBuf, for: aliceCards!)
}
```

See our [guide](/docs/swift/guides/virgil-card/finding-card.md) on Finding Cards for best practices on loading Alice's card.

### Storage

With this in place, Alice is now ready to store the encrypted files to a local or remote disk (Clouds).


## <a name="head5"></a> Decrypt Data

You can easily **decrypt** your encrypted files at any time using your private Virgil Key.

![Encrypt Data](/docs/swift/img/encrypted_storage_download.png "Decrypt Data")

To decrypt your encrypted files, load the data and use your own Virgil Key to decrypt the data.

```swift
// load a Virgil Key from device storage
let aliceKey = try! virgil.keys.loadKey(withName: "[KEY_NAME]",
  password: "[OPTIONAL_KEY_PASSWORD]")

// decrypt a cipher buffer using loaded Virgil Key
let originalFileBuf = try! aliceKey.decrypt(cipherFileBuf)
```

To decrypt data, you will need your stored Virgil Key. See the [Loading Key](/docs/swift/guides/virgil-key/loading-key.md) guide for more details.
