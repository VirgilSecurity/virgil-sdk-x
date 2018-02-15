# Encrypting Data

This guide is a short tutorial on how to **encrypt** data with Virgil Security. You will encrypt data using a Public Key, which is saved on the user's **Virgil Card**. Once encrypted, only the owner of the related Private Key will be able to decrypt the encrypted data. Therefore, you need to search for a user's Virgil Cards at **Virgil Services** and then encrypt the data using appropriate Virgil Card.

Encryption can be used to provide high levels of security to network communications, e-mails, files stored on the cloud, and other information that requires protection.

For original information about encryption, its syntax and parameters, follow the link [here](https://github.com/VirgilSecurity/virgil/blob/wiki/wiki/glossary.md#encryption).

Before you begin to encrypt data, set up your project environment using [getting started](/docs/swift/guides/configuration/client.md) guide.

The Data Encryption procedure is shown in the figure below.

![Virgil Encryption Intro](/docs/swift/img/Encryption_introduction.png "Data encryption")

To encrypt a **message**, Alice has to have:
 - Bob's Virgil Cards, which should be published on **Virgil Services**.

Remember that Bob can have a **Global Virgil Card** as well as an Application Virgil Card. If Alice is not a user of a specific Application, she will only be able to find Bob's Global Virgil Cards.

Let's review the data encryption process:

1. Developers need to initialize the **Virgil SDK**

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

2. Then Alice:

  -  Searches for Bob's Virgil Card on Virgil Services
  -  Prepares the message for Bob
  -  Encrypts the message for Bob

  ```swift
  // search for Virgil Cards
  virgil.cards.searchCards(withIdentities: ["bob"]) { bobCards, error in
  	let message = "Hey Bob, how's it going?"

  	// encrypt the buffer using found Virgil Cards
  	let ciphertext = (try! virgil.encrypt(message, for: bobCards!))
  		.base64EncodedString()
  }
  ```

Now Alice can send encrypted message to Bob.
