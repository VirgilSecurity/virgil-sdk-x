# Validating Cards

This guide shows how to validate a **Virgil Card** on a device. As previously noted, each Virgil Card contains a Digital signature that provides data integrity for the Virgil Card over its life cycle. Therefore, developers can verify the Digital Signature at any time.

During the validation process we verify, by default, two signatures:
- **from Virgil Card owner**
- **from Virgil Services**

Additionally, developers can verify the **signature of the application server**.

Set up your project environment before you begin to validate a Virgil Card, with the [getting started](https://github.com/VirgilSecurity/virgil-sdk-x/blob/docs-review/documentation-objectivec/guides/configuration/client-configuration.md) guide.

In order to validate the signature of the Virgil Card owner, **Virgil Services**, and the Application Server, we need to:

```objectivec
NSData *appPublicKey = [[NSData alloc]
	initWithBase64EncodedString:"[YOUR_APP_PUBLIC_KEY_HERE]" options:0];

// initialize High Level Api with custom verifiers
VSSCardVerifierInfo *appVerifierInfo = [[VSSCardVerifierInfo alloc]
	initWithCardId:@"[YOUR_APP_CARD_ID_HERE]" publicKeyData:appPublicKey];
VSSVirgilApiContext *context = [[VSSVirgilApiContext alloc] initWithCrypto:nil
	token:@"[YOUR_ACCESS_TOKEN_HERE]" credentials:nil
	cardVerifiers:@[appVerifierInfo]];
VSSVirgilApi *virgil = [[VSSVirgilApi alloc] initWithContext:context];

[virgil.cards searchCardsWithIdentities:@[@"alice"]
	completion:^(NSArray<VSSVirgilCard *>* aliceCards, NSError *error) {
	//...
}];
```
