# Importing Virgil Key

This guide shows how to export a **Virgil Key** from a Base64 encoded string representation.

Set up your project environment before you begin to import a Virgil Key, with the [getting started](/docs/guides/configuration/client.md) guide.

To import a Virgil Key, we need to:

- Initialize **Virgil SDK**

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

- Choose a Base64 encoded string
- Import the Virgil Key from the Base64 encoded string

```swift
// initialize a buffer from base64 encoded string
let aliceKeyData = Data(base64Encoded: "[BASE64_ENCODED_VIRGIL_KEY]")!

// import Virgil Key from buffer
let aliceKey = virgil.keys.importKey(from: aliceKeyData,
    password: "[OPTIONAL_KEY_PASSWORD]")!
```
