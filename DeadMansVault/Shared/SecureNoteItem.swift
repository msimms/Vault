//
//  SecureNoteItem.swift
//  Created by Michael Simms on 4/22/22.
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

struct SecureNoteItemEncoding: Codable {
	var vaultVersion: UInt8     // Version of this encoding
	var heading: String         // Name of this note
	var note: String            // The note
	var tags: Array<String>?    // Tags
	var lastModifiedTime: Date? // Timestamp of the last update
}

class SecureNoteItem: SecureVaultItem {
	enum CodingKeys: CodingKey {
		case heading
		case note
		case tags
		case lastModifiedTime
	}

	var heading: String = ""
	var note: String = ""
	var tags: Array<String> = []
	var lastModifiedTime: Date?
	
	/// Constructors
	required init(from decoder: Decoder) throws {
		try super.init(from: decoder)

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.heading = try container.decode(String.self, forKey: .heading)
		self.note = try container.decode(String.self, forKey: .note)
		self.tags = try container.decode(Array<String>.self, forKey: .tags)
		self.lastModifiedTime = try container.decode(Date.self, forKey: .lastModifiedTime)
	}
	override init() {
		super.init()
	}
	init(json: SecureNoteItemEncoding) {
		super.init(json: json)
		
		self.heading = json.heading
		self.note = json.note
		self.tags = json.tags ?? []
		self.lastModifiedTime = json.lastModifiedTime
	}

	/// Encode overrides
	override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(heading, forKey: .heading)
		try container.encode(note, forKey: .note)
		try container.encode(tags, forKey: .tags)
		try container.encode(lastModifiedTime, forKey: .lastModifiedTime)

		let superencoder = container.superEncoder()
		try super.encode(to: superencoder)
	}

	/// Creates the file for the vault item.
	override func write(locationOfVaultItems: URL, masterKey: Data) throws {
		
		// Encode everything as JSON.
		let vaultData = SecureNoteItemEncoding(vaultVersion: self.vaultVersion, heading: self.heading, note: self.note, tags: self.tags, lastModifiedTime: self.lastModifiedTime)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!
		
		// Encrypt and write the data.
		try super.write(locationOfVaultItems: locationOfVaultItems, masterKey: masterKey, contents: jsonStr, itemType: VaultItemType.note)
	}
	
	/// Returns the string to use as the title when viewing this item.
	override func displayTitle() -> String {
		return self.heading
	}
	
	/// Updates the last modified timestamp.
	override func updateLastModifiedTime() {
		self.lastModifiedTime = Date()
	}
}
