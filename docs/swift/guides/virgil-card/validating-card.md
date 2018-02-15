# Validating Cards

This guide shows how to validate a **Virgil Card** on a device. As previously noted, each Virgil Card contains a Digital signature that provides data integrity for the Virgil Card over its life cycle. Therefore, developers can verify the Digital Signature at any time.

During the validation process we verify, by default, two signatures:
- **from Virgil Card owner**
- **from Virgil Services**

Additionally, developers can verify the **signature of the application server**.

Set up your project environment before you begin to validate a Virgil Card, with the [getting started](/docs/swift/guides/configuration/client.md) guide.

To validate the signature of the Virgil Card owner, **Virgil Services**, and the Application Server, we need to:

```swift
// initialize High Level Api with custom verifiers
let appVerifierInfo = VSSCardVerifierInfo(cardId: "[YOUR_APP_CARD_ID_HERE]",
	publicKeyData: appPublicKey)
let context = VSSVirgilApiContext(crypto: nil, token: [YOUR_ACCESS_TOKEN_HERE],
	credentials: nil, cardVerifiers: [appVerifierInfo])

let virgil = VSSVirgilApi(context: context)

virgil.cards.searchCards(withIdentities: ["alice"]) { aliceCards, error in
	//...
}
```
