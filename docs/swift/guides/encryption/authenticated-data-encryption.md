# Authenticated Data Encryption

This guide is a short tutorial on how to sign then encrypt data with Virgil Security.

This process is called **Authenticated Data Encryption**. It is a form of encryption which simultaneously provides confidentiality, integrity, and authenticity assurances on the encrypted data. During this procedure you will sign then encrypt data using Alice’s **Virgil Key**, and then Bob’s **Virgil Card**. To do this, Alice’s Virgil Key must be loaded from the appropriate storage location, then Bob’s Virgil Card must be searched for, followed by preparation of the data for transmission, which is finally signed and encrypted before being sent.


Set up your project environment before you begin to work, with the [getting started](/docs/swift/guides/configuration/client.md) guide.

The Authenticated Data Encryption procedure is shown in the figure below.

![Authenticated Data Encryption](/docs/swift/img/Guides_introduction.png "Authenticated Data Encryption")

To **sign"** and **encrypt** a **message**, Alice has to have:
 - Her Virgil Key
 - Bob's Virgil Card

Let's review how to sign and encrypt data:

1. Developers need to initialize the **Virgil SDK**:

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

2. Alice has to:

  - Load her Virgil Key from secure storage defined by default;
  - Search for Bob's Virgil Cards on **Virgil Services**;
  - Prepare a message for signature and encryption;
  - Encrypt and sign the message for Bob.

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

To load a Virgil Key from a specific storage, developers need to change the storage path during Virgil SDK initialization.

In many cases you need receiver's Virgil Cards. See [Finding Cards](/docs/swift/guides/virgil-card/finding-card.md) guide to find them.
