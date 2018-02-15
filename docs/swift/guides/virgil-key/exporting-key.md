# Exporting Virgil Key

This guide shows how to export a **Virgil Key** to the string representation.

Set up your project environment before you begin to export a Virgil Key, with the [getting started](https://github.com/VirgilSecurity/virgil-sdk-x/blob/v4/docs/swift/guides/configuration/client.md) guide.

To export the Virgil Key:

- Initialize **Virgil SDK**

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

- Alice Generates a Virgil Key
- After Virgil Key generated, developers can export Alice's Virgil Key to a Base64 encoded string

```swift
// generate a new Virgil Key
let aliceKey = virgil.keys.generateKey()

// export the Virgil Key
let exportedAliceKey = aliceKey
  .export(withPassword: "[OPTIONAL_KEY_PASSWORD]").base64EncodedString()
```

Developers also can extract Public Key from a Private Key using the Virgil CLI.
