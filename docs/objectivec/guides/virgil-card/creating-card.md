# Creating Card

This guide shows how to create a user's **Virgil Card** – the main entity of **Virgil Services**. Every user or device is represented by Virgil Card with all necessary identification information.

Every developer can create a user's **Virgil Card** (visible within the Application) or **Global Virgil Card** (visible to anybody and not related to the Application).

See our [Use Cases](https://github.com/VirgilSecurity/virgil-sdk-x/tree/docs-review/docs/objectivec/get-started) to find out what you can do with Virgil Cards. If you need to create a Global Virgil Card, start with the guide, [Creating a Global Card](/docs/objectivec/guides/virgil-card/creating-global-card.md).

After a Virgil Card is created, it's published at Virgil Card Service, where an owner can find their Virgil Cards at any time.

**Warning**: You cannot change a Virgil Card content after it is published.

Each Virgil Card contains a  permanent digital signature that provides data integrity for the Virgil Card over its life-cycle.



### Let's start to create a user's Virgil Card

Set up your project environment before you begin to create a user's Virgil Card, with the [getting started](/docs/objectivec/guides/configuration/client.md) guide.


The Virgil Card creation procedure is shown in the figure below.

![Virgil Card Generation](/docs/objectivec/img/Card_introduct.png "Create Virgil Card")


In order to create a Virgil Card:

1. Developers need to initialize the **Virgil SDK**

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

Users' Virgil Card creation is carried out on the client side.

2. Once the SDK is ready, we can proceed to the next step:
  – Generate and save a **Virgil Key** (it's also necessary to enter the Virgil Key's name and password)
  – Create a Virgil Card using the recently generated Virgil Key


  ```objectivec
  // generate a new Virgil Key
  VSSVirgilKey *aliceKey = [virgil.keys generateKey];

  // save the Virgil Key into the storage
  [aliceKey storeWithName:@"[KEY_NAME]" password:@"[KEY_PASSWORD]" error:nil];

  // create identity for Alice
  VSSUserIdentity *aliceIdentity = [virgil.identities
    createUserIdentityWithValue:@"alice" type:@"name"];

  // create a Virgil Card
  VSSVirgilCard *aliceCard = [virgil.cards createCardWithIdentity:aliceIdentity
    ownerKey:aliceKey error:nil];
  ```

The Virgil Key will be saved into default device storage. Developers can also change the Virgil Key's storage directory as needed during Virgil SDK initialization.

**Warning**: Virgil doesn't keep a copy of your Virgil Key. If you lose a Virgil Key, there is no way to recover it.

3. Developers have to transmit the Virgil Card to the App's server side where it will be signed, validated and then published on Virgil Services (this is necessary for further operations with the Virgil Card).

```objectivec
// export a Virgil Card to string
NSString *exportedCard = [aliceCard exportData];
```

A user's Virgil Card is related to its Application, so the developer must identify their Application.

On the Application's Server Side, one must:

 - Initialize the Virgil SDK and enter the Application **credentials** (**App ID**, **App Key**, and **App Key password**).

 ```objectivec
 // this language is not supported yet.
 ```


-  Import a Virgil Card from its string representation.

```objectivec
// import a Virgil Card from string
VSSVirgilCard *aliceCard = [virgil.cards
  importVirgilCardFromData:exportedAliceCard];
```

-  Then publish a Virgil Card on Virgil Services.

```objectivec
// publish a Virgil Card
[virgil.cards publishCard:aliceCard completion:^(NSError *error) {
	//...
}];
```

Developers also can create a Virgil Card using the Virgil CLI.
