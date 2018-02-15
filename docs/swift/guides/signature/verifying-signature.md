# Verifying Signature

This guide is a short tutorial on how to verify a **Digital Signature** with Virgil Security.

For original information about the Digital Signature follow the link [here](https://github.com/VirgilSecurity/virgil/blob/wiki/wiki/glossary.md#digital-signature).

Set up your project environment before starting to verify a Digital Signature, with the [getting started](/docs/swift/guides/configuration/client.md) guide.

The Signature Verification procedure is shown in the figure below.


![Virgil Signature Intro](/docs/swift/img/Signature_introduction.png "Verify Signature")

To verify the Digital Signature, Bob has to have Alice's **Virgil Card"**.

Let's review the Digital Signature verification process:

- Developers need to initialize the **Virgil SDK**

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

- Then Bob has to take Alice's **Virgil Card ID** and search for Alice's Virgil Card on **Virgil Services**
- Bob then verifies the signature. If the signature is invalid, Bob will receive an error message.

```swift
// search for Virgil Card
virgil.cards.getCard(withId: "[ALICE_CARD_ID_HERE]") { aliceCard, error in
	do {
		try aliceCard!.verify(message, withSignature: signature)
	}
	catch {
		// "Aha... Alice it's not you."
	}
}
```

See our guide on [Validating Cards](/docs/swift/guides/virgil-card/validating-card.md) for the best practices.
