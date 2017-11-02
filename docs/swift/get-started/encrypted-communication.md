# Encrypted Communication

 [Set Up Server](#head1) | [Set Up Clients](#head2) | [Register Users](#head3) | [Sign & Encrypt](#head4) | [Decrypt & Verify](#head5)

It is very easy to encrypt data for secure communications in a few simple steps. In this tutorial, we are helping two people communicate with full (end-to-end) **encryption**.

Due to limited time and resources, developers often resort to third-party solutions to transfer data, which do not have an open source API, a full cycle of data security that would ensure integrity and confidentiality. Thus, all of your data could be read by the third party. Virgil offers a solution without these weaknesses.

![Encrypted Communication](/docs/swift/img/encrypted_communication_intro.png "Encrypted Communication")

See our tutorial on [Virgil & Twilio Programmable Chat](https://github.com/VirgilSecurity/virgil-demo-twilio) for best practices.


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
Now you need to register the users who will participate in encrypted communications.

To sign and encrypt a message, each user must have his own tools, which allow him to perform cryptographic operations. These tools must contain the necessary information to identify users. In Virgil Security, such tools are the Virgil Key and the Virgil Card.

![Virgil Card](/docs/swift/img/Card_introduct.png "Create Virgil Card")

When we have already set up the Virgil SDK on the server and client sides, we can finally create Virgil Cards for the users and transmit the Cards to your Server for further publication on Virgil Services.


### Generate Keys and Create Virgil Card
Use the Virgil SDK on the client side to generate a new Key Pair. Then, with recently generated Virgil Key, create user's Virgil Card. All keys are generated and stored on the client side.

In this example, we are passing on the user's username and a password, which will lock in their private encryption key. Each Virgil Card is signed by user's Virgil Key, which guarantees the Virgil Card content integrity over its life cycle.

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

**Note**: Recently created users' Virgil Cards are visible only for application users because they are related to the Application.

Read more about Virgil Cards and their types [here](/docs/swift/guides/virgil-card/creating-card.md).


### Transmit the Cards to Your Server

Next, you must serialize and transmit these Cards to your server, where you will approve and publish users' Cards.

```swift
// export a Virgil Card to string
let exportedCard = aliceCard.exportData()

// transmit the Virgil Card to the server
TransmitToServer(exportedCard)
```

Use the [approve & publish users guide](/docs/swift/guides/configuration/server.md#-approve--publish-cards) to publish users Virgil Cards on Virgil Services.


## <a name="head4"></a> Sign & Encrypt a Message

With the user's Cards in place, we are now ready to encrypt a message for encrypted communication. In this case, we will encrypt the message using the Recipient's Virgil Card.

As previously noted, we encrypt data for secure communication, but a recipient also must be sure that no third party modified any of the message's content and that they can trust a sender, which is why we provide **Data Integrity** by adding a **Digital Signature**. Therefore we must digitally sign data first and then encrypt.

![Virgil Intro](/docs/swift/img/Guides_introduction.png "Sign & Encrypt")

To sign then encrypt messages, the Sender must load their own recently generated Virgil Key and search for the receiver's Virgil Cards at Virgil Services, where all Virgil Cards are saved.

```swift
// load a Virgil Key from device storage
let aliceKey = try! virgil.keys.loadKey(withName: "[KEY_NAME]",
	password: "[OPTIONAL_KEY_PASSWORD]")

// search for Bob's cards on Virgil Services
virgil.cards.searchCards(withIdentities: ["bob"]) { bobCards, error in
	// prepare the message
	let message = "Hey Bob, are you crazy?"

	// encrypt the buffer using found Virgil Cards
	let ciphertext = (try! aliceKey.signThenEncrypt(message, for: bobCards!))
		.base64EncodedString()
}
```

To sign a message, you will need to load Alice's Virgil Key. See [Loading Key](/docs/swift/guides/virgil-key/loading-key.md) guide for more details.

Now the Receiver can verify that the message was sent by specific Sender.

### Transmission

With the signature in place, the Sender is now ready to transmit the signed and encrypted message to the Receiver.

See our tutorial on [Virgil & Twilio Programmable Chat](https://github.com/VirgilSecurity/virgil-demo-twilio) for best practices.

## <a name="head5"></a> Decrypt a Message & Verify its Signature

Once the Recipient receives the signed and encrypted message, he can decrypt and validate the message. Thus, proving that the message has not been tampered with, user verifies the signature against the Sender's Virgil Card.

To **decrypt** the encrypted message and then verify the signature, we need to load private receiver's Virgil Key and search for the sender's Virgil Card at Virgil Services.

```swift
// load a Virgil Key from device storage
let bobKey = try! virgil.keys.loadKey(withName: "[KEY_NAME]",
	password: "[OPTIONAL_KEY_PASSWORD]")

virgil.cards.getCard(withId: "[ALICE_CARD_ID]") { aliceCard, error in
	// decrypt the message
	let originalMessage = String(data: try! bobKey.decryptThenVerify(base64: ciphertext,
		from: aliceCard!), encoding: .utf8)!
}
```

In many cases you need Sender's Virgil Cards. See [Finding Cards](/docs/swift/guides/virgil-card/finding-card.md) guide to find them.
