# Finding Card

This guide shows how to find a **Virgil Card**. As previously noted, all Virgil Cards are saved at **Virgil Services** after their publication. Thus, every user can find their own Virgil Card or another user's Virgil Card on Virgil Services. It should be noted that users' Virgil Cards will only be visible to application users. Global Virgil Cards will be visible to anybody.

Set up your project environment before you begin to find a Virgil Card, with the [getting started](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/configuration/client-configuration.md) guide.


In order to search for an **Application** or **Global Virgil Card** you need to initialize the **Virgil SDK**:

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```


### Application Cards

There are two ways to find an Application Virgil Card on Virgil Services:

The first one allows developers to get the Virgil Card by its unique **ID**

```objectivec
[virgil.cards getCardWithId:@"[ALICE_CARD_ID]"
	completion:^(VSSVirgilCard *aliceCard, NSError *error) {
	//...
}];
```

The second one allows developers to find Virgil Cards by *identity* and *identityType*

```objectivec
// search for all User's Virgil Cards.
[virgil.cards searchCardsWithIdentities:@[@"alice"]
	completion:^(NSArray<VSSVirgilCard *>* aliceCards, NSError *error) {
	//...
}];

// search for all User's Virgil Cards with identity type 'member'
[virgil.cards searchCardsWithIdentityType:@"member" identities:@[@"bob"]
	completion:^(NSArray<VSSVirgilCard *>* bobCards, NSError *error) {
	//...
}];
```



### Global Cards

```objectivec
// search for all Global Virgil Cards
[virgil.cards searchGlobalCardsWithIdentities:@[@"bob@virgilsecurity.com"]
	completion:^(NSArray<VSSVirgilCard *> * bobGlobalCards, NSError *error) {
	//...
}];

// search for Application Virgil Card
[virgil.cards searchGlobalCardsWithIdentities:@[@"com.username.appname"]
	completion:^(NSArray<VSSVirgilCard *> *appCards, NSError *error) {
	//...
}];
```
