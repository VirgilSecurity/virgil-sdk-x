# Importing Card

This guide shows how to import a **Virgil Card** from the string representation.

Set up your project environment before you begin to import a Virgil Card, with the [getting started](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/configuration/client-configuration.md) guide.


In order to import the Virgil Card, we need to:

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
