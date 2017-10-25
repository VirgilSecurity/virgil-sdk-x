# Revoking Card

This guide shows how to revoke a **Virgil Card** from Virgil Services.

Set up your project environment before you begin to revoke a Virgil Card, with the [getting started](/documentation-objectivec/guides/configuration/client-configuration.md) guide.

In order to revoke a Virgil Card, we need to:

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
