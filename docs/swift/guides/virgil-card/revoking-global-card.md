# Revoking Global Card

This guide shows how to revoke a **Global Virgil Card**.

Set up your project environment before you begin to revoke a Global Virgil Card, with the [getting started](/docs/swift/guides/configuration/client.md) guide.

To revoke a Global Virgil Card, we need to:

-  Initialize the Virgil SDK

```swift
// this language is not supported yet.
```

- Load Alice's **Virgil Key** from the secure storage provided by default
- Load Alice's Virgil Card from **Virgil Services**
- Initiate the Card identity verification process
- Confirm the Card identity using a **confirmation code**
- Revoke the Global Virgil Card from Virgil Services

```swift
// load a Virgil Key from storage
let aliceKey = try! virgil.keys.loadKey(withName: "[KEY_NAME]",
	password: "[OPTIONAL_KEY_PASSWORD]")

// load a Virgil Card from Virgil Services
virgil.cards.getCard(withId: "[USER_CARD_ID_HERE]") { aliceCard, error in
	let aliceIdentity = virgil.identities
		.createEmailIdentity(withEmail: aliceCard!.identity)

	// initiate an identity verification process.
	aliceIdentity.check(options: nil) { error in
		aliceIdentity.confirm(withConfirmationCode: "[CONFIRMATION_CODE]")
			{ error in virgil.cards.revokeEmail(aliceCard!, identity: aliceIdentity,
					ownerKey: aliceKey) { error in
				//...
			}
		}
	}
}
```
