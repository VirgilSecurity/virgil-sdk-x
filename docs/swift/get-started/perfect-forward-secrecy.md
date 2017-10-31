# Perfect Forward Secrecy

[Set Up Server](#head1) | [Set Up Clients](#head2) | [Register Users](#head3) | [Initialize PFS Chat](#head4) | [Send & Receive a Message](#head5)

Virgil Perfect Forward Secrecy (PFS) is designed to prevent a possibly compromised long-term secret key from affecting the confidentiality of past communications. In this tutorial, we are helping two people or IoT devices to communicate with end-to-end **encryption** with enabled PFS.

Create a [Developer account](https://developer.virgilsecurity.com/account/signup) and register your Application to get the possibility to use Virgil Infrastructure.

## <a name="head1"></a> Set Up Server
Your server should be able to authorize your users, store Application's Virgil Key and use **Virgil SDK** for cryptographic operations or for some requests to Virgil Services.

SWIFT is not supported on the server side.
We recommend using one of the next SDKs:
[RUBY](https://github.com/VirgilSecurity/virgil-sdk-ruby/tree/v4)
[PHP](https://github.com/VirgilSecurity/virgil-sdk-php/tree/v4)
[GO](https://github.com/VirgilSecurity/virgil-crypto-go/tree/v4)
[JAVASCRIPT](https://github.com/VirgilSecurity/virgil-sdk-javascript/tree/v4)
[JAVA](https://github.com/VirgilSecurity/virgil-sdk-java-android/tree/v4)
[PYTHON](https://github.com/VirgilSecurity/virgil-sdk-python/tree/v4)
[C#/.NET](https://github.com/VirgilSecurity/virgil-sdk-net/tree/v4)


## <a name="head2"></a> Set Up Clients
Set up the client side to provide your users with an access token after their registration at your Application Server to authenticate them for further operations and transmit their **Virgil Cards** to the server. Configure the client side using the [Setup Guide](/docs/guides/configuration/client-side-pfs).



## <a name="head3"></a> Register Users
Now you need to register the users who will participate in encrypted communications.

In order to sign and encrypt a message, each user must have his own tools, that allow him to perform cryptographic operations. These tools must contain the information necessary to identify users. In Virgil Security, these tools are the Virgil Key and the Virgil Card.

![Virgil Card](https://github.com/VirgilSecurity/virgil-sdk-swift/blob/docs-review/docs/img/Card_introduct.png "Create Virgil Card")

When we have already set up the Virgil SDK on the server & client sides, we can finally create Virgil Cards for the users and transmit the Cards to your Server for further publication on Virgil Services.


### Generate Keys and Create Virgil Card
To generate a new Key Pair, use Virgil SDK on the client side. Then create user's Virgil Card with recently generated Virgil Key. All keys are generated and stored on the client side.

In this example, we pass on the username and password, which we lock in their private encryption key. Each Virgil Card is signed by user's Virgil Key. This guarantees Virgil Card content integrity over its life cycle.

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
var aliceCard = try! virgil.cards.
  createCard(with: aliceIdentity, ownerKey:aliceKey)
```

**Warning**: Virgil doesn't keep a copy of your Virgil Key. If you lose a Virgil Key, there is no way to recover it.

In order for the Sender to be able to send a message, we also need a Virgil Card associated with the Recipient. It should be noted that recently created user Virgil Cards will be visible only for application users because they are related to the Application.

Read more about Virgil Cards and their types [here](https://github.com/VirgilSecurity/virgil-sdk-swift/blob/docs-review/docs/guides/virgil-card/creating-card.md).


### Transmit the Cards to Your Server

Next, you must serialize and transmit these cards to your server, where you will approve and publish user's Cards.

```swift
// export a Virgil Card to string
let exportedCard = aliceCard.exportData()

// transmit the Virgil Card to the server and receive response
let cardData = TransmitToServer(exportedCard)

// import card
aliceCard = virgil.cards.importVirgilCard(fromData: cardData)!
```

Use the [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-swift/blob/docs-review/docs/guides/configuration/server-configuration.md) to publish users Virgil Cards on Virgil Services.



## <a name="head4"></a> Initialize PFS Chat
With the user's Cards in place, we are now ready to initialize a PFS chat. In this case, we will use the Recipient's Private Keys, the Virgil Cards and the Access Token.

In order to begin communicating, Bob must run the initialization:

```swift
let secureChatPreferences = SecureChatPreferences (
    crypto: "[CRYPTO]", // (e.g. VSSCrypto())
    identityPrivateKey: bobKey.privateKey,
    identityCard: bobCard.card!,
    accessToken: "[YOUR_ACCESS_TOKEN_HERE]")

self.secureChat = SecureChat(preferences: secureChatPreferences)

try self.secureChat.initialize()

self.secureChat.rotateKeys(desiredNumberOfCards: 100) { error in
	//...
}
```

**Warning**: If Bob does not run the chat initialization, Alice cannot create an initial message.

Then, Alice must run the initialization:

```swift
let secureChatPreferences = SecureChatPreferences (
    crypto: "[CRYPTO]", // (e.g. VSSCrypto())
    identityPrivateKey: aliceKey.privateKey,
    identityCard: aliceCard.card!,
    accessToken: "[YOUR_ACCESS_TOKEN_HERE]")

self.secureChat = SecureChat(preferences: secureChatPreferences)

try self.secureChat.initialize()

self.secureChat.rotateKeys(desiredNumberOfCards: 100) { error in
	//...
}
```


After chat initialization, Alice and Bob can start their PFS communication.

## <a name="head5"></a> Send & Receive a Message

Once Recipients initialized a PFS Chat, they can communicate.

Alice establishes a secure PFS conversation with Bob, encrypts and sends the message to him:

```swift
func sendMessage(forReceiver receiver: User, message: String) {
    guard let session = self.chat.activeSession(
        withParticipantWithCardId: receiver.card.identifier) else {
        // start new session with recipient if session wasn't initialized yet
        self.chat.startNewSession(
            withRecipientWithCard: receiver.card) { session, error in

            guard error == nil, let session = session else {
                // Error handling
                return
            }

            // get an active session by recipient's card id
            self.sendMessage(forReceiver: receiver,
                usingSession: session, message: message)
        }
        return
    }

    self.sendMessage(forReceiver: receiver,
        usingSession: session, message: message)
}

func sendMessage(forReceiver receiver: User,
    usingSession session: SecureSession, message: String) {
    let ciphertext: String
    do {
        // encrypt the message using previously initialized session
        ciphertext = try session.encrypt(message)
    }
    catch {
        // Error handling
        return
    }

    // send a cipher message to recipient using your messaging service
    self.messenger.sendMessage(
        forReceiverWithName: receiver.name, text: ciphertext)
}
```


Then Bob decrypts the incoming message using the conversation he has just created:


```swift
func messageReceived(fromSenderWithName senderName: String, message: String) {
    guard let sender = self.users.first(where: { $0.name == senderName }) else {
        // User not found
        return
    }

    self.receiveMessage(fromSender: sender, message: message)
}

func receiveMessage(fromSender sender: User, message: String) {
    do {
        let session = try self.chat.loadUpSession(
            withParticipantWithCard: sender.card, message: message)

        // decrypt message using established session
        let plaintext = try session.decrypt(message)

        // show a message to the user
        print(plaintext)
    }
    catch {
        // Error handling
    }
}
```


With the open session, that works in both directions, Alice and Bob can continue PFS encrypted communication.
