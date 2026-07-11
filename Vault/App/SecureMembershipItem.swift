//
//  SecureMembershipItem.swift
//  Created by Michael Simms on 7/8/26.
//

//	MIT License
//
//  Copyright (c) 2026 Michael J Simms. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import Foundation

struct SecureMembershipItemEncoding: Codable {
	var vaultVersion: UInt8                    // Version of this encoding
	var title: String                          // Title for this membership card
	var membershipNumber: String               // Membership number/string/whatever
	var memberSinceYY: String?                 // Membership since (year)
	var memberSinceMM: String?                 // Membership since (month)
	var note: String                           // The note
	var tags: Array<String>?                   // Tags
	var lastModifiedTime: Date?                // Timestamp of the last update
	var attachments: Dictionary<String, Data>? // Data for all attachments
}

class SecureMembershipItem: SecureVaultItem {
	enum CodingKeys: CodingKey {
		case title
		case membershipNumber
		case memberSinceYY
		case memberSinceMM
		case note
		case tags
		case lastModifiedTime
		case attachments
	}

	var title: String = ""
	var membershipNumber: String = ""
	var memberSinceYY: String = ""
	var memberSinceMM: String = ""
	var note: String = ""
	var tags: Array<String> = []
	var lastModifiedTime: Date?

	/// Constructors
	required init(from decoder: Decoder) throws {
		try super.init(from: decoder)

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.title = try container.decode(String.self, forKey: .title)
		self.membershipNumber = try container.decode(String.self, forKey: .membershipNumber)
		self.memberSinceYY = try container.decode(String.self, forKey: .memberSinceYY)
		self.memberSinceMM = try container.decode(String.self, forKey: .memberSinceMM)
		self.note = try container.decode(String.self, forKey: .note)
		self.tags = try container.decode(Array<String>.self, forKey: .tags)
		self.lastModifiedTime = try container.decode(Date.self, forKey: .lastModifiedTime)
		self.attachments = try container.decode(Dictionary<String, Data>.self, forKey: .attachments)
	}
	override init() {
		super.init()
	}
	init(json: SecureMembershipItemEncoding) {
		super.init(json: json)

		self.title = json.title
		self.membershipNumber = json.membershipNumber
		self.memberSinceYY = json.memberSinceYY ?? ""
		self.memberSinceMM = json.memberSinceMM ?? ""
		self.note = json.note
		self.tags = json.tags ?? []
		self.lastModifiedTime = json.lastModifiedTime
		self.attachments = json.attachments ?? [:]
	}

	override func copy(from: SecureVaultItem) {
		let from2 = from as! SecureMembershipItem
		self.title = from2.title
		self.membershipNumber = from2.membershipNumber
		self.memberSinceYY = from2.memberSinceYY
		self.memberSinceMM = from2.memberSinceMM
		self.note = from2.note
		self.tags = from2.tags
		self.lastModifiedTime = from2.lastModifiedTime
		self.attachments = from2.attachments

		super.copy(from: from)
	}

	/// Encode overrides
	override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(title, forKey: .title)
		try container.encode(membershipNumber, forKey: .membershipNumber)
		try container.encode(memberSinceYY, forKey: .memberSinceYY)
		try container.encode(memberSinceMM, forKey: .memberSinceMM)
		try container.encode(note, forKey: .note)
		try container.encode(tags, forKey: .tags)
		try container.encode(lastModifiedTime, forKey: .lastModifiedTime)
		try container.encode(attachments, forKey: .attachments)

		try super.encode(to: encoder)
	}

	/// Creates the file for the vault item.
	override func write(locationOfVaultItems: URL, masterKey: Data) throws {

		// Encode everything as JSON.
		let vaultData = SecureMembershipItemEncoding(vaultVersion: self.vaultVersion, title: self.title, membershipNumber: self.membershipNumber, memberSinceYY: self.memberSinceYY, memberSinceMM: self.memberSinceMM, note: self.note, tags: self.tags, lastModifiedTime: self.lastModifiedTime, attachments: self.attachments)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!

		// Encrypt and write the data.
		try super.write(locationOfVaultItems: locationOfVaultItems, masterKey: masterKey, contents: jsonStr, itemType: VaultItemType.membership)
	}

	/// Returns the string to use as the title when viewing this item.
	override func displayTitle() -> String {
		return self.title
	}

	/// Called in response to the copy shortcut.. Adds the thing the user would most want to the pasteboard.
	override func copy() -> String {
		return self.note
	}

	/// Updates the last modified timestamp.
	override func updateLastModifiedTime() {
		self.lastModifiedTime = Date()
	}
}
