# Decrypting Data

This guide is a short tutorial on how to **decrypt** encrypted data with Virgil Security.

Decryption is the reverse operation of encryption. As previously noted, Virgil Security allows you to encrypt data using public-key encryption. It's means that only the owner of the related private **Virgil Key** can decrypt the encrypted data.

Before decryption, set up your project environment with the [getting started](/docs/swift/guides/configuration/client.md) guide.

The Data Decryption procedure is shown in the figure below.

![Virgil Encryption Intro](/docs/swift/img/Encryption_introduction.png "Data decryption")

To decrypt a **message**, Bob has to have:
 - His Virgil Key

Let's review the data decryption process:

1. Developers need to initialize the **Virgil SDK**:

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```


2. Then Bob:

  - Loads the Virgil Key from the secure storage provided by default
  - Decrypts the message using his own Virgil Key

  ```swift
  // load a Virgil Key from device storage
  let bobKey = try! virgil.keys.loadKey(withName: "[KEY_NAME]",
    password: "[OPTIONAL_KEY_PASSWORD]")

  // decrypt a ciphertext using loaded Virgil Key
  let originalMessage = String(data: try! bobKey.decrypt(base64: ciphertext),
    encoding: .utf8)!
  ```

To load a Virgil Key from a specific storage, developers need to change the storage path during Virgil SDK initialization.

To decrypt data, you need Bob's stored Virgil Key. See the [Storing Keys](/docs/swift/guides/virgil-key/saving-key.md) guide for more details.
