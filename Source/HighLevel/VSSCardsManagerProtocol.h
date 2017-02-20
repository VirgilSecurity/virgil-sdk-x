//
//  VSSCardsManagerProtocol.h
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 2/13/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

#import "VSSVirgilCard.h"
#import "VSSVirgilKey.h"

@protocol VSSCardsManager <NSObject>

//- (VSSVirgilCard * __nonnull)createCardWithIdentity:(NSString * __nonnull)identity ownerKey:(VSSVirgilKey * __nonnull) identityType:(NSString * __nonnull)identityType data:(NSDictionary<NSString *, NSString *> * __nullable)data;
//
///// <summary>
///// Creates a new global <see cref="VirgilCard"/> that is representing user's
///// Public key and information about identity.
///// </summary>
///// <param name="identity">The user's identity value.</param>
///// <param name="identityType">Type of the identity.</param>
///// <param name="ownerKey">The owner's <see cref="VirgilKey"/>.</param>
///// <param name="customFields">The custom fields (optional).</param>
///// <returns>A new instance of <see cref="VirgilCard"/> class, that is representing user's Public key.</returns>
//VirgilCard CreateGlobal(string identity, IdentityType identityType, VirgilKey ownerKey,
//                        Dictionary<string, string> customFields = null);
//
///// <summary>
///// Finds a <see cref="VirgilCard"/>s by specified identities in application scope.
///// </summary>
///// <param name="identities">The list of identities.</param>
///// <returns>A list of found <see cref="VirgilCard"/>s.</returns>
//Task<IEnumerable<VirgilCard>> FindAsync(params string[] identities);
//
///// <summary>
///// Finds <see cref="VirgilCard"/>s by specified identities and type in application scope.
///// </summary>
///// <param name="identityType">Type of identity</param>
///// <param name="identities">The list of sought identities</param>
///// <returns>A list of found <see cref="VirgilCard"/>s.</returns>
//Task<IEnumerable<VirgilCard>> FindAsync(string identityType, IEnumerable<string> identities);
//
///// <summary>
///// Finds <see cref="VirgilCard"/>s by specified identities and type in global scope.
///// </summary>
///// <param name="identityType">Type of identity</param>
///// <param name="identities">The list of sought identities</param>
///// <returns>A list of found <see cref="VirgilCard"/>s.</returns>
//Task<IEnumerable<VirgilCard>> FindGlobalAsync(IdentityType identityType, params string[] identities);
//
///// <summary>
///// Imports a <see cref="VirgilCard"/> from specified buffer.
///// </summary>
///// <param name="exportedCard">The Card in string representation.</param>
///// <returns>An instance of <see cref="VirgilCard"/>.</returns>
//VirgilCard Import(string exportedCard);
//
///// <summary>
///// Publishes a <see cref="VirgilCard"/> into global Virgil Services scope.
///// </summary>
///// <param name="card">The Card to be published.</param>
///// <param name="token">The identity validation token.</param>
//Task PublishGlobalAsync(VirgilCard card, IdentityValidationToken token);
//
///// <summary>
///// Publishes a <see cref="VirgilCard"/> into application Virgil Services scope.
///// </summary>
///// <param name="card">The Card to be published.</param>
//Task PublishAsync(VirgilCard card);
//
///// <summary>
///// Revokes a <see cref="VirgilCard"/> from Virgil Services.
///// </summary>
///// <param name="card">The card to be revoked.</param>
//Task RevokeAsync(VirgilCard card);
//
///// <summary>
///// Revokes a global <see cref="VirgilCard"/> from Virgil Security services.
///// </summary>
///// <param name="card">The Card to be revoked.</param>
///// <param name="key">The Key associated with the revoking Card.</param>
///// <param name="identityToken">The identity token.</param>
//Task RevokeGlobalAsync(VirgilCard card, VirgilKey key, IdentityValidationToken identityToken);
//
///// <summary>
///// Gets the <see cref="VirgilCard"/> by specified ID.
///// </summary>
///// <param name="cardId">The Card identifier.</param>
//Task<VirgilCard> GetAsync(string cardId);

@end
