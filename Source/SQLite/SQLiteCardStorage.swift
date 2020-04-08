//
// Copyright (C) 2015-2020 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import VirgilSDK
import VirgilCrypto

/// Represents error of `SQLiteCardStorage`
///
/// - inconsistentDb: Storage turned into inconsistency state
/// - emptyIdentities: Empty identities
@objc(VTESQLiteCardStorageError) public enum SQLiteCardStorageError: Int, LocalizedError {
    case inconsistentDb = 1
    case emptyIdentities = 2

    /// Human-readable localized description
    public var errorDescription: String? {
        switch self {
        case .inconsistentDb:
            return "Storage turned into inconsistency state"
        case .emptyIdentities:
            return "Empty identities"
        }
    }
}

// swiftlint:disable identifier_name
// swiftlint:disable discouraged_optional_boolean

internal class SQLiteCardStorage {
    private enum CardsStatement: String {
        case createTable = """
        CREATE TABLE IF NOT EXISTS Cards(
        id TEXT UNIQUE NOT NULL,
        identity TEXT NOT NULL,
        is_outdated INTEGER,
        card TEXT NOT NULL);
        """

        case createIndexId = "CREATE UNIQUE INDEX IF NOT EXISTS id_index ON Cards(id);"

        case createIndexIdentity = "CREATE INDEX IF NOT EXISTS identity_index ON Cards(identity);"

        case insertCard = """
        INSERT OR REPLACE INTO Cards (id, identity, is_outdated, card) VALUES (?, ?, ?, ?);
        """

        case markOutdatedById = "UPDATE Cards SET is_outdated = ? WHERE id = ?;"

        case selectCardById = "SELECT card, is_outdated FROM Cards WHERE id = ?;"

        case selectCardByIdentities = "SELECT card FROM Cards WHERE identity in (?);"

        case selectNewestCardIds = "SELECT id FROM Cards WHERE is_outdated = 0;"

        case deleteAllCards = "DELETE FROM Cards;"
    }

    private func adaptSelectCardByIdentities(identitiesCount: Int) -> String {
        let replacementStr = [String].init(repeating: "?", count: identitiesCount).joined(separator: ",")

        return CardsStatement.selectCardByIdentities.rawValue.replacingOccurrences(of: "?", with: replacementStr)
    }

    private let crypto: VirgilCrypto
    private let verifier: CardVerifier
    private let db: SQLiteDB

    internal var dbPath: String {
        return self.db.path
    }

    internal init(userIdentifier: String, crypto: VirgilCrypto, verifier: CardVerifier) throws {
        self.crypto = crypto
        self.verifier = verifier
        self.db = try SQLiteDB(prefix: "VIRGIL_SQLITE", userIdentifier: userIdentifier, name: "cards.sqlite")

        try self.db.executeNoResult(statement: CardsStatement.createTable.rawValue)
        try self.db.executeNoResult(statement: CardsStatement.createIndexId.rawValue)
        try self.db.executeNoResult(statement: CardsStatement.createIndexIdentity.rawValue)
    }

    internal func storeCard(_ card: Card) throws {
        var currentCard: Card? = card
        var previousCard: Card? = nil

        while true {
            if let c = currentCard {
                let data = try CardManager.exportCardAsData(c)

                let stmt = try self.db.generateStmt(statement: CardsStatement.insertCard.rawValue)

                try self.db.bindIn(stmt: stmt,
                                   value1: c.identifier,
                                   value2: c.identity,
                                   value3: c.isOutdated,
                                   value4: data)

                try self.db.executeNoResult(statement: stmt)

                previousCard = c
                currentCard = c.previousCard
                continue
            }
            else if let c = previousCard, let previousCardId = c.previousCardId {
                let stmt = try self.db.generateStmt(statement: CardsStatement.markOutdatedById.rawValue)

                try self.db.bindIn(stmt: stmt, value1: true, value2: previousCardId)

                try self.db.executeNoResult(statement: stmt)
                break
            }
            else {
                break
            }
        }
    }

    internal func getCard(cardId: String) throws -> Card? {
        let stmt = try self.db.generateStmt(statement: CardsStatement.selectCardById.rawValue)

        try self.db.bindIn(stmt: stmt, value: cardId)

        guard try self.db.executeStep(statement: stmt) else {
            return nil
        }

        let cardDataBind: Data?
        let outdatedBind: Bool?

        (cardDataBind, outdatedBind) = try self.db.bindOut(stmt: stmt)

        guard let cardData = cardDataBind, let outdated = outdatedBind else {
            throw SQLiteCardStorageError.inconsistentDb
        }

        let card = try CardManager.importCard(fromData: cardData,
                                              crypto: self.crypto,
                                              cardVerifier: self.verifier)

        card.isOutdated = outdated

        guard card.identifier == cardId else {
            throw SQLiteCardStorageError.inconsistentDb
        }

        return card
    }

    internal func searchCards(identities: [String]) throws -> [Card] {
        guard !identities.isEmpty else {
            throw SQLiteCardStorageError.emptyIdentities
        }

        let adaptedSelect = self.adaptSelectCardByIdentities(identitiesCount: identities.count)
        let stmt = try self.db.generateStmt(statement: adaptedSelect)

        var index: Int32 = 1
        for identity in identities {
            try self.db.bindIn(stmt: stmt, index: index, value: identity)
            index += 1
        }

        var hasData = true
        var cards: [Card] = []

        while hasData {
            hasData = try self.db.executeStep(statement: stmt)
            guard hasData else {
                break
            }

            let cardDataBind: Data? = try self.db.bindOut(stmt: stmt)

            guard let cardData = cardDataBind else {
                throw SQLiteCardStorageError.inconsistentDb
            }

            let card = try CardManager.importCard(fromData: cardData,
                                                  crypto: self.crypto,
                                                  cardVerifier: self.verifier)

            cards.append(card)
        }

        let result = try cards
            .compactMap { card -> Card? in
                guard identities.contains(card.identity) else {
                    throw CardManagerError.gotWrongCard
                }

                if let nextCard = cards.first(where: { $0.previousCardId == card.identifier }) {
                    nextCard.previousCard = card
                    card.isOutdated = true
                    return nil
                }

                return card
            }

        return result
    }

    internal func getNewestCardIds() throws -> [String] {
        let stmt = try self.db.generateStmt(statement: CardsStatement.selectNewestCardIds.rawValue)

        var hasData = true
        var ids: [String] = []

        while hasData {
            hasData = try self.db.executeStep(statement: stmt)
            guard hasData else {
                break
            }

            let cardIdBind: String? = try self.db.bindOut(stmt: stmt)

            guard let cardId = cardIdBind else {
                throw SQLiteCardStorageError.inconsistentDb
            }

            ids.append(cardId)
        }

        return ids
    }

    internal func reset() throws {
        let stmt = try self.db.generateStmt(statement: CardsStatement.deleteAllCards.rawValue)

        try self.db.executeNoResult(statement: stmt)
    }
}
