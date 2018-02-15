# Importing Virgil Key

This guide shows how to export a **Virgil Key** from a Base64 encoded string representation.

Before you begin to import a Virgil Key, set up your project environment with the [getting started](/docs/objectivec/guides/configuration/client.md) guide.

To import a Virgil Key, we need to:

- Initialize **Virgil SDK**

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

- Choose a Base64 encoded string
- Import the Virgil Key from the Base64 encoded string

```objectivec
// initialize a buffer from base64 encoded string
NSData *aliceKeyData = [[NSData alloc]
  initWithBase64EncodedString:@"[BASE64_ENCODED_VIRGIL_KEY]" options:0];

// import Virgil Key from buffer
VSSVirgilKey *aliceKey = [virgil.keys importKeyFromData:aliceKeyData
  password:@"[OPTIONAL_KEY_PASSWORD]"];
```
