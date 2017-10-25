# Exporting Card

This guide shows how to export a **Virgil Card** to the string representation.

Set up your project environment before you begin to export a Virgil Card, with the [getting started](/documentation-objectivec/guides/configuration/client-configuration.md) guide.

In order to export a Virgil Card, we need to:

- Initialize the **Virgil SDK**

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

- Use the code below to export the Virgil Card to its string representation.

```objectivec
// export a Virgil Card to string
NSString *exportedCard = [aliceCard exportData];
```

The same mechanism works for **Global Virgil Card**.
