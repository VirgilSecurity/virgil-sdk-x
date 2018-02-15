# Importing Card

This guide shows how to import a **Virgil Card** from the string representation.

Set up your project environment before you begin to import a Virgil Card, with the [getting started](/docs/swift/guides/configuration/client.md) guide.


To import the Virgil Card, we need to:

- Initialize the **Virgil SDK**

```swift
let virgil = VSSVirgilApi(token: "[YOUR_ACCESS_TOKEN_HERE]")
```

- Use the code below to import the Virgil Card from its string representation

```swift
// import a Virgil Card from string
let aliceCard = virgil.cards.importVirgilCard(fromData: exportedAliceCard)!
```
