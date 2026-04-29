//
//  SecureServerItem.swift
//  Created by Michael Simms on 4/28/26.
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

struct SecureServerLogin: Codable, Hashable {
	var username: String                       // Login username
	var password: String                       // Login password

	init(username: String, password: String) {
		self.username = username
		self.password = password
	}
}

struct SecureServerItemEncoding: Codable, Hashable {
	var vaultVersion: UInt8                    // Version of this encoding
	var title: String?                         // Server title
	var uri: String                            // Server name or URL
	var logins: Array<SecureServerLogin>?
	var note: String?                          // Notes (optional)
	var tags: Array<String>?                   // Tags (optional)
	var lastModifiedTime: Date?                // Timestamp of the last update
	var attachments: Dictionary<String, Data>? // Data for all attachments
}

class SecureServerItem: SecureVaultItem {
	enum CodingKeys: CodingKey {
		case title
		case uri
		case logins
		case note
		case tags
		case lastModifiedTime
		case attachments
	}

	var title: String = ""
	var uri: String = ""
	@Published var logins: Array<SecureServerLogin> = []
	var note: String = ""
	var tags: Array<String> = []
	var urls: Array<String> = []
	var lastModifiedTime: Date?

	/// Constructors
	required init(from decoder: Decoder) throws {
		try super.init(from: decoder)

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.title = try container.decode(String.self, forKey: .title)
		self.uri = try container.decode(String.self, forKey: .uri)
		self.logins = try container.decode(Array<(SecureServerLogin)>.self, forKey: .logins)
		self.note = try container.decode(String.self, forKey: .note)
		self.tags = try container.decode(Array<String>.self, forKey: .tags)
		self.lastModifiedTime = try container.decode(Date.self, forKey: .lastModifiedTime)
		self.attachments = try container.decode(Dictionary<String, Data>.self, forKey: .attachments)
	}
	override init() {
		super.init()
	}
	init(json: SecureServerItemEncoding) {
		super.init(json: json)

		self.title = json.title ?? ""
		self.uri = json.uri
		self.logins = json.logins ?? []
		self.note = json.note ?? ""
		self.tags = json.tags ?? []
		self.lastModifiedTime = json.lastModifiedTime
		self.attachments = json.attachments ?? [:]
	}

	override func copy(from: SecureVaultItem) {
		let from2 = from as! SecureServerItem
		self.title = from2.title
		self.uri = from2.uri
		self.logins = from2.logins
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
		try container.encode(uri, forKey: .uri)
		try container.encode(logins, forKey: .logins)
		try container.encode(note, forKey: .note)
		try container.encode(tags, forKey: .tags)
		try container.encode(lastModifiedTime, forKey: .lastModifiedTime)
		try container.encode(attachments, forKey: .attachments)

		try super.encode(to: encoder)
	}

	/// Creates the file for the vault item.
	override func write(locationOfVaultItems: URL, masterKey: Data) throws {

		// Encode everything as JSON.
		let vaultData = SecureServerItemEncoding(vaultVersion: self.vaultVersion, title: self.title, uri: self.uri, logins: self.logins, note: self.note, tags: self.tags, lastModifiedTime: self.lastModifiedTime, attachments: self.attachments)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!

		// Encrypt and write the data.
		try super.write(locationOfVaultItems: locationOfVaultItems, masterKey: masterKey, contents: jsonStr, itemType: VaultItemType.login)
	}

	/// Returns the string to use as the title when viewing this item.
	override func displayTitle() -> String {
		if self.title.count == 0 {
			return self.uri
		}
		return self.title
	}

	/// Updates the last modified timestamp.
	override func updateLastModifiedTime() {
		self.lastModifiedTime = Date()
	}
}
