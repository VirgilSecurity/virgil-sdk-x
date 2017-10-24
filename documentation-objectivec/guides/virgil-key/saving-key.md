# Saving Key

This guide shows how to save a **Virgil Key** from the default storage after its [generation](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/virgil-key/generating-key.md).

Before you begin to generate a Virgil Key, Set up your project environment with the [getting started](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/configuration/client-configuration.md) guide.

In order to save the Virgil Key we need to:

- Initialize the **Virgil SDK**:

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

- Save Alice's Virgil Key in the protected storage on the device

```objectivec
// save Virgil Key into storage
[aliceKey storeWithName:@"[KEY_NAME]"
  password:@"[OPTIONAL_KEY_PASSWORD]" error:nil];
```


Developers can also change the Virgil Key storage directory as needed, during Virgil SDK initialization.
