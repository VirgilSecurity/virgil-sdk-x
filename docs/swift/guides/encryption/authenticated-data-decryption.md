# Authenticated Data Decryption

This guide is short tutorial on how to decrypt and then verify data with Virgil Security.

This process is called **Authenticated Data Decryption**. During this procedure you work with encrypted and signed data, decrypting and verifying them. A recipient uses their **Virgil Key** (to decrypt the data) and **Virgil Card** (to verify data integrity).


Set up your project environment before you begin to work, with the [getting started](/docs/swift/guides/configuration/client.md) guide.

The Authenticated Data Decryption procedure is shown in the figure below.

![Virgil Intro](/docs/swift/img/Guides_introduction.png "Authenticated Data Decryption")

To decrypt and verify the message, Bob has to have:
 - His Virgil Key
 - Alice's Virgil Card

Let's review how to decrypt and verify data:

1. Developers need to initialize the **Virgil SDK**

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

2. Then Bob has to:

 - Load his own Virgil Key from secure storage, defined by default
 - Search for Alice's Virgil Card on **Virgil Services**
 - Decrypt the message using his Virgil Key and verify it using Alice's Virgil Card

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

To load a Virgil Key from a specific storage, developers need to change the storage path during Virgil SDK initialization.

To decrypt data, you need Bob's stored Virgil Key. See the [Storing Keys](/docs/swift/guides/virgil-key/saving-key.md) guide for more details.
