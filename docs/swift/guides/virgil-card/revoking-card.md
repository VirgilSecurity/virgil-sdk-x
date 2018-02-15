# Revoking Card

This guide shows how to revoke a **Virgil Card** from Virgil Services.

Set up your project environment before you begin to revoke a Virgil Card, with the [getting started](/docs/swift/guides/configuration/client.md) guide.

To revoke a Virgil Card, we need to:

- Initialize the **Virgil SDK** and enter Application **credentials** (**App ID**, **App Key**, **App Key password**)

```swift
// this language is not supported yet.
```

- Get Alice's Virgil Card by **ID** from **Virgil Services**
- Revoke Alice's Virgil Card from Virgil Services

```swift
// get a Virgil Card by ID
virgil.cards.getCard(withId: "[USER_CARD_ID_HERE]") { aliceCard, error in
	virgil.cards.revoke(aliceCard!) { error in
		//...
	}
}
```
