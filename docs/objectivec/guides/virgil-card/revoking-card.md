# Revoking Card

This guide shows how to revoke a **Virgil Card** from Virgil Services.

Before you begin to revoke a Virgil Card, set up your project environment with the [getting started](/docs/objectivec/guides/configuration/client.md) guide.

To revoke a Virgil Card, we need to:

- Initialize the **Virgil SDK** and enter Application **credentials** (**App ID**, **App Key**, **App Key password**)

```objectivec
// this language is not supported yet.
```

- Get Alice's Virgil Card by **ID** from **Virgil Services**
- Revoke Alice's Virgil Card from Virgil Services

```objectivec
// get a Virgil Card by ID
[virgil.cards getCardWithId:@"[USER_CARD_ID_HERE]"
	completion:^(VSSVirgilCard *aliceCard, NSError *error) {
		[virgil.cards revokeCard:aliceCard completion:^(NSError *error) {
		//...
	}];
}];
```
