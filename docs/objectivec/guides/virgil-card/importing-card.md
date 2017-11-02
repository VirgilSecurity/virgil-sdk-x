# Importing Card

This guide shows how to import a **Virgil Card** from the string representation.

Before you begin to import a Virgil Card, set up your project environment with the [getting started](/docs/objectivec/guides/configuration/client.md) guide.


To import the Virgil Card, we need to:

- Initialize the **Virgil SDK**

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

- Use the code below to import the Virgil Card from its string representation

```objectivec
// import a Virgil Card from string
VSSVirgilCard *aliceCard = [virgil.cards
  importVirgilCardFromData:exportedAliceCard];
```
