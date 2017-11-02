/v4/# Creating Signature

This guide is a short tutorial on how to create a **Digital Signature** with Virgil Security. A valid digital signature gives a recipient reason to believe that the message was created by a known sender, that the sender cannot deny having sent the message, and that the message was not altered in transit. It can be used with any kind of message – whether it is encrypted or not.

See our [Use Cases](https://github.com/VirgilSecurity/virgil-sdk-x/tree/v4/docs/swift) to find out what you can do with Digital Signature.

Set up your project environment before starting to create a Digital Signature, with the [getting started](/docs/swift/guides/configuration/client.md) guide.

The **Signature Creation** procedure is shown in the figure below.

![Virgil Signature Intro](/docs/swift/img/Signature_introduction.png "Create Signature")

To create a Digital Signature and sign the message, Alice has to have her **Virgil Key**.


Let's review the **Digital Signature** creation process:

- Developers need to initialize the **Virgil SDK**

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

- Load Alice's Virgil Key from the protected storage and enter the Virgil Key's password;

```swift
// load Virgil Key
let aliceKey = try! virgil.keys.loadKey(withName: "[KEY_NAME]",
  password: "[KEY_PASSWORD]")
```


To load the Virgil Key from a specific storage, developers need to change the storage path during Virgil SDK initialization.

Then Alice has to:
- Prepare the information for the message to Bob
- Sign the message using her Virgil Key

```swift
// prepare a message
let message = "Hey Bob, hope you are doing well."

// generate signature
let signature = try! aliceKey.generateSignature(for: message)
```

See our guide on [Loading Keys](/docs/swift/guides/virgil-key/loading-key.md) for more examples.

Now Alice can send a signed message to Bob.
