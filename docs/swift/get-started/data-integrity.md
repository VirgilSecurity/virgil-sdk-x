## Data Integrity

[Set Up Server](#head1) | [Set Up Clients](#head2) | [Register Users](#head3) | [Sign Data](#head4) | [Find User's Card](#head5) | [Verify Data](#head6)

Use **Virgil** to verify the integrity of data. **Data Integrity** is essential to anyone who wants to guarantee that their data has not been tampered with.


<!-- ![Virgil Signature Intro](/img/Signature_introduction.png "Data integrity") -->

## <a name="head1"></a> Set Up Server
Your server should be able to authorize your users, store Application Virgil Key and use **Virgil SDK** for cryptographic operations or for some requests to Virgil Services.

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
Now you need to register users. We are creating a Virgil Key and Card for each user that sends verified data.
Cards are stored with Virgil and contain user's public encryption keys.

![Virgil Card](/docs/swift/img/Card_introduct.png "Create Virgil Card")

When we have already set up the Virgil SDK on the server and client sides, we can finally create Virgil Cards for the users and transmit the Cards to your Server for further publication on Virgil Services.


### Generate Keys and Create Virgil Card
Use the Virgil SDK on client side to generate a new Key Pair, and then, using recently generated Virgil Key, create user's Virgil Card. All keys are generated and stored on the client side.

In this example, we are passing on user's username and password, which will lock in their private encryption key. Each Virgil Card is signed by user's Virgil Key, which guarantees Virgil Card content integrity over its life cycle.

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

**Warning**: Virgil doesn't keep the copy of your Virgil Key. If you lose a Virgil Key, there is no way to recover it.

**Note**: Recently created users' Virgil Cards are visible only for application users because they are related to the Application.

Read more about Virgil Cards and their types [here](/docs/swift/guides/virgil-card/creating-card.md).


### Transmit the Cards to Your Server

Next, you must serialize and transmit this cards to your server, where you approve and publish users' Cards.

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

## <a name="head4"></a> Sign Data

With the sender's Cards in place, we are now ready to ensure the Data Integrity by creating a **Digital Signature**. This signature ensures that the third party hasn't modified messages' content and you can trust a sender.

```swift
// prepare a message
let message = "Hey Bob, hope you are doing well."

// generate signature
let signature = try! aliceKey.generateSignature(for: message)
```

To create a signature, you need to load Alice's Virgil Key. The [Loading Key](/docs/swift/guides/virgil-key/loading-key.md) guide provides more details

### Transmission

The Sender is now ready to transmit the signature and message to the Receiver.

See our guide on Transmitting Data for best practices, or check our tutorial on [Secure IP Messaging with Twilio](https://github.com/VirgilSecurity/virgil-demo-twilio).


## <a name="head5"></a> Find User's Card

Client verifies received message using sender's Virgil Card.

To look up sender's card, we use the same identifier as for card publishing: `alice`.

```swift
// search for all User's Virgil Cards.
self.api.cards.searchCards(withIdentities: ["alice"]) { aliceCards, error in
	//...
}
```

The identifier for a Virgil Card can be any ID you prefer, for example, a username or user ID. The [Finding Card](/docs/swift/guides/virgil-card/finding-card.md) guide provides more details.

This returns all cards for Alice, which we can use to verify the data.


## <a name="head6"></a> Verify Data

With sender's Cards, we check the Digital Signature and can verify the Integrity of the message.

```swift
// verify signature using Alice's Virgil Card*/
aliceCards.verify(message, withSignature: signature)
```

To create a signature, you need to load Alice's Virgil Key. The [Loading Key](/docs/swift/guides/virgil-key/loading-key.md) guide provides more details.
