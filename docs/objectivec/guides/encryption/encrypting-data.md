# Encrypting Data

This guide is a short tutorial on how to **encrypt** data with Virgil Security. You will encrypt data using a Public Key, which is saved on the user's **Virgil Card**. Once encrypted, only the owner of the related Private Key will be able to decrypt the encrypted data. Therefore, you need to search for a user's Virgil Cards at **Virgil Services** and then encrypt the data using appropriate Virgil Card.

Encryption can be used to provide high levels of security to network communications, e-mails, files stored on the cloud, and other information that requires protection.


Before you begin to encrypt data, set up your project environment using [getting started](/docs/objectivec/guides/configuration/client.md) guide.

The Data Encryption procedure is shown in the figure below.

![Virgil Encryption Intro](/docs/objectivec/img/Encryption_introduction.png "Data encryption")

To encrypt a **message**, Alice has to have:
 - Bob's Virgil Cards, which should be published on **Virgil Services**.

Remember that Bob can have a **Global Virgil Card** as well as an Application Virgil Card. If Alice is not a user of a specific Application, she will only be able to find Bob's Global Virgil Cards.

Let's review the data encryption process:

1. Developers need to initialize the **Virgil SDK**

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

2. Then Alice:

  -  Searches for Bob's Virgil Card on Virgil Services
  -  Prepares the message for Bob
  -  Encrypts the message for Bob

  ```objectivec
  // search for Virgil Cards
  [virgil.cards searchCardsWithIdentities:@[@"bob"]
  	completion:^(NSArray<VSSVirgilCard *>* bobCards, NSError *error) {
  	NSString *message = @"Hey Bob, how's it going?";

  	// encrypt the buffer using found Virgil Cards
  NSString *ciphertext = [[virgil encryptString:message for:bobCards error:nil]
  	base64EncodedStringWithOptions:0];
  }];
  ```

Now Alice can send encrypted message to Bob.