# Encrypted Communication

 [Set Up Server](#head1) | [Set Up Clients](#head2) | [Register Users](#head3) | [Sign & Encrypt](#head4) | [Decrypt & Verify](#head5)

It is very easy to encrypt data for secure communications in a few simple steps. In this tutorial, we are helping two people communicate with full (end-to-end) **encryption**.

Due to limited time and resources, developers often resort to third-party solutions to transfer data, which do not have an open source API, a full cycle of data security that would ensure integrity and confidentiality. Thus, all of your data could be read by the third party. Virgil offers a solution without these weaknesses.

![Encrypted Communication](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/img/encrypted_communication_intro.png "Encrypted Communication")

See our tutorial on [Virgil & Twilio Programmable Chat](https://github.com/VirgilSecurity/virgil-demo-twilio) for best practices.


## <a name="head1"></a> Set Up Server
Your server should be able to authorize your users, store Application's Virgil Key and use **Virgil SDK** for cryptographic operations or for some requests to Virgil Services. You can configure your server using the [Setup Guide](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/configuration/server-configuration.md).


## <a name="head2"></a> Set Up Clients
Set up the client side. After users register at your Application Server, provide them with an access token that authenticates users for further operations and transmit their **Virgil Cards** to the server. Configure the client side using the [Setup Guide](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/configuration/client-configuration.md).


## <a name="head3"></a> Register Users
Now you need to register the users who will participate in encrypted communications.

In order to sign and encrypt a message, each user must have his own tools, which allow him to perform cryptographic operations. These tools must contain the necessary information to identify users. In Virgil Security, such tools are the Virgil Key and the Virgil Card.

![Virgil Card](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/img/Card_introduct.png "Create Virgil Card")

When we have already set up the Virgil SDK on the server and client sides, we can finally create Virgil Cards for the users and transmit the Cards to your Server for further publication on Virgil Services.


### Generate Keys and Create Virgil Card
Use the Virgil SDK on the client side to generate a new Key Pair. Then, with recently generated Virgil Key, create user's Virgil Card. All keys are generated and stored on the client side.

In this example, we are passing on the user's username and a password, which will lock in their private encryption key. Each Virgil Card is signed by user's Virgil Key, which guarantees the Virgil Card's content integrity over its life cycle.

```objectivec
// generate a new Virgil Key
VSSVirgilKey *aliceKey = [virgil.keys generateKey];

// save the Virgil Key into storage
[aliceKey storeWithName:@"[KEY_NAME]"
  password:@"[KEY_PASSWORD]" error:nil];

// create identity for Alice
VSSUserIdentity *aliceIdentity = [virgil.identities
  createUserIdentityWithValue:@"alice" type:@"name"];

// create a Virgil Card
VSSVirgilCard *aliceCard = [virgil.cards
  createCardWithIdentity:aliceIdentity ownerKey:aliceKey error:nil];
```


**Warning**: Virgil doesn't keep a copy of your Virgil Key. If you lose a Virgil Key, there is no way to recover it.

**Note**: Recently created users' Virgil Cards are visible only for application users because they are related to the Application.

Read more about Virgil Cards and their types [here](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/virgil-card/creating-card.md).


### Transmit the Cards to Your Server

Next, you must serialize and transmit these Cards to your server, where you will approve and publish users' Cards.

```objectivec
// export a Virgil Card to string
NSString *exportedCard = [aliceCard exportData];

// transmit the Virgil Card to the server
TransmitToServer(exportedCard);
```

Use the [approve & publish users guide](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/configuration/server.md#-approve--publish-cards) to publish users Virgil Cards on Virgil Services.


## <a name="head4"></a> Sign & Encrypt a Message

With the user's Cards in place, we are now ready to encrypt a message for encrypted communication. In this case, we will encrypt the message using the Recipient's Virgil Card.

As previously noted, we encrypt data for secure communication, but a recipient also must be sure that no third party modified any of the message's content and that they can trust a sender, which is why we provide **Data Integrity** by adding a **Digital Signature**. Therefore we must digitally sign data first and then encrypt.

![Virgil Intro](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/img/Guides_introduction.png "Sign & Encrypt")

In order to sign then encrypt messages, the Sender must load their own recently generated Virgil Key and search for the receiver's Virgil Cards at Virgil Services, where all Virgil Cards are saved.

```objectivec
// load a Virgil Key from device storage
VSSVirgilKey *aliceKey = [virgil.keys loadKeyWithName:@"[KEY_NAME]"
	password:@"[OPTIONAL_KEY_PASSWORD]" error:nil];

// search for Virgil Cards
[virgil.cards searchCardsWithIdentities:@[@"bob"]
	completion:^(NSArray<VSSVirgilCard *>* bobCards, NSError *error) {
	// prepare the message
	NSString *message = @"Hey Bob, are you crazy?";

	// encrypt the buffer using found Virgil Cards
	NSString *cipherText = [[aliceKey signThenEncryptString:message
		forRecipients:bobCards] base64EncodedStringWithOptions:0];
}];
```

To sign a message, you will need to load Alice's Virgil Key. See [Loading Key](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/virgil-key/loading-key.md) guide for more details.

Now the Receiver can verify that the message was sent by specific Sender.

### Transmission

With the signature in place, the Sender is now ready to transmit the signed and encrypted message to the Receiver.

See our tutorial on [Virgil & Twilio Programmable Chat](https://github.com/VirgilSecurity/virgil-demo-twilio) for best practices.

## <a name="head5"></a> Decrypt a Message & Verify its Signature

Once the Recipient receives the signed and encrypted message, he can decrypt and validate the message. Thus, proving that the message has not been tampered with, user verifies the signature against the Sender's Virgil Card.

In order to **decrypt** the encrypted message and then verify the signature, we need to load private receiver's Virgil Key and search for the sender's Virgil Card at Virgil Services.

```objectivec
// load a Virgil Key from device storage
VSSVirgilKey *bobKey = [virgil.keys loadKeyWithName:@"[KEY_NAME]"
	password:@"[OPTIONAL_KEY_PASSWORD]" error:nil];

// get a sender's Virgil Card
[virgil.cards getCardWithId:@"[ALICE_CARD_ID]"
	completion:^(VSSVirgilCard *aliceCard, NSError *error) {
	NSData *originalMessage = [[NSString alloc] initWithData:[bobKey
	decryptThenVerifyBase64String:ciphertext from:aliceCard error:nil]
	encoding:NSUTF8StringEncoding];
}];
```


In many cases you need Sender's Virgil Cards. See [Finding Cards](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/virgil-card/finding-card.md) guide to find them.
