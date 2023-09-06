//
//  SecureCardItem.swift
//  Created by Michael Simms on 5/14/22.
//

// MIT License
//
// Copyright (c) 2022 Mike Simms
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

struct SecureCardItemEncoding: Codable {
	var vaultVersion: UInt8     // Version of this encoding
	var name: String            // Name of this card
	var cardType: String        // Type of the card, i.e. "Visa", "MC", etc.
	var bank: String?           // Type of the card, i.e. "Visa", "MC", etc.
	var cardHolder: String      // Name on the card
	var number: String          // Card number
	var securityCode: Int       // Card security code
	var expiry: Date            // Card expiry date
	var validFrom: Date?        // Card valid from date
	var note: String?           // Notes
	var tags: Array<String>?    // Tags
	var lastModifiedTime: Date? // Timestamp of the last update
}

class SecureCardItem: SecureVaultItem {
	enum CodingKeys: CodingKey {
		case name
		case cardType
		case bank
		case cardHolder
		case number
		case securityCode
		case expiry
		case validFrom
		case note
		case tags
		case lastModifiedTime
	}

	var name: String = ""
	var cardType: String = ""
	var bank: String = ""
	var cardHolder: String = ""
	var number: String = ""
	var securityCode: Int = 0
	var expiry: Date = Date()
	var validFrom: Date?
	var note: String = ""
	var tags: Array<String> = []
	var lastModifiedTime: Date?

	/// Constructors
	required init(from decoder: Decoder) throws {
		try super.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.cardType = try container.decode(String.self, forKey: .cardType)
		self.bank = try container.decode(String.self, forKey: .bank)
		self.cardHolder = try container.decode(String.self, forKey: .cardHolder)
		self.number = try container.decode(String.self, forKey: .number)
		self.securityCode = try container.decode(Int.self, forKey: .securityCode)
		self.expiry = try container.decode(Date.self, forKey: .expiry)
		self.validFrom = try container.decode(Date.self, forKey: .validFrom)
		self.note = try container.decode(String.self, forKey: .note)
		self.tags = try container.decode(Array<String>.self, forKey: .tags)
		self.lastModifiedTime = try container.decode(Date.self, forKey: .lastModifiedTime)
	}
	override init() {
		super.init()
	}
	init(json: SecureCardItemEncoding) {
		super.init(json: json)
		
		self.name = json.name
		self.cardType = json.cardType
		self.bank = json.bank ?? ""
		self.cardHolder = json.cardHolder
		self.number = json.number
		self.securityCode = json.securityCode
		self.expiry = json.expiry
		self.validFrom = json.validFrom ?? Date()
		self.note = json.note ?? ""
		self.tags = json.tags ?? []
		self.lastModifiedTime = json.lastModifiedTime
	}

	/// Encode overrides
	override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
		try container.encode(cardType, forKey: .cardType)
		try container.encode(bank, forKey: .bank)
		try container.encode(cardHolder, forKey: .cardHolder)
		try container.encode(number, forKey: .number)
		try container.encode(securityCode, forKey: .securityCode)
		try container.encode(expiry, forKey: .expiry)
		try container.encode(validFrom, forKey: .validFrom)
		try container.encode(note, forKey: .note)
		try container.encode(tags, forKey: .tags)
		try container.encode(lastModifiedTime, forKey: .lastModifiedTime)

		let superencoder = container.superEncoder()
		try super.encode(to: superencoder)
	}

	/// Creates the file for the vault item.
	override func write(locationOfVaultItems: URL, masterKey: Data) throws {
		
		// Encode everything as JSON.
		let vaultData = SecureCardItemEncoding(vaultVersion: self.vaultVersion, name: self.name, cardType: self.cardType, bank: self.bank, cardHolder: self.cardHolder, number: self.number, securityCode: self.securityCode, expiry: self.expiry, validFrom: self.validFrom, note: self.note, tags: self.tags, lastModifiedTime: self.lastModifiedTime)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!
		
		// Encrypt and write the data.
		try super.write(locationOfVaultItems: locationOfVaultItems, masterKey: masterKey, contents: jsonStr, itemType: VaultItemType.card)
	}

	/// Returns the string to use as the title when viewing this item.
	override func displayTitle() -> String {
		return self.name
	}

	/// Updates the last modified timestamp.
	override func updateLastModifiedTime() {
		self.lastModifiedTime = Date()
	}
}
