# Finding Card

This guide shows how to find a **Virgil Card**. As previously noted, all Virgil Cards are saved at **Virgil Services** after their publication. Thus, every user can find their own Virgil Card or another user's Virgil Card on Virgil Services. It should be noted that users' Virgil Cards will only be visible to application users. Global Virgil Cards will be visible to anybody.

Set up your project environment before you begin to find a Virgil Card, with the [getting started](/docs/swift/guides/configuration/client.md) guide.


To search for an **Application** or **Global Virgil Card** you need to initialize the **Virgil SDK**:

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```


### Application Cards

There are two ways to find an Application Virgil Card on Virgil Services:

The first one allows developers to get the Virgil Card by its unique **ID**

```swift
virgil.cards.getCard(withId: "[ALICE_CARD_ID]") { aliceCard, error in
	//...
}
```


The second one allows developers to find Virgil Cards by *identity* and *identityType*

```swift
// search for all User's Virgil Cards.
self.api.cards.searchCards(withIdentities: ["alice"]) { aliceCards, error in
	//...
}

// search for all User's Virgil Cards with identity type 'member'
virgil.api.cards.searchCards(withIdentityType: "member",
	identities: ["bob"]) { bobCards, error in
	//...
}
```



### Global Cards

```swift
// search for all Global Virgil Cards
virgil.cards.searchGlobalCards(withIdentities: ["bob@virgilsecurity.com"])
	{ bobGlobalCards, error in
	//...
}

// search for Application Virgil Card
virgil.cards.searchGlobalCards(withIdentities: ["com.username.appname"])
	{ appCards, error in
	//...
}
```
