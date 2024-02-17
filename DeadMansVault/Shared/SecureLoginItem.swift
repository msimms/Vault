//
//  SecureLoginItem.swift
//  Created by Michael Simms on 12/13/21.
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

struct SecureLoginItemEncoding: Codable {
	var vaultVersion: UInt8                    // Version of this encoding
	var title: String?                         // Website title
	var website: String                        // Website name or URL
	var username: String?                      // Login username (optional)
	var email: String?                         // Login email (optional)
	var password: String?                      // Login password (optional)
	var note: String?                          // Notes (optional)
	var tags: Array<String>?                   // Tags (optional)
	var urls: Array<String>?                   // Additional URLSs (optiona)
	var lastModifiedTime: Date?                // Timestamp of the last update
	var attachments: Dictionary<String, Data>? // Data for all attachments
}

class SecureLoginItem: SecureVaultItem {
	enum CodingKeys: CodingKey {
		case title
		case website
		case username
		case email
		case password
		case note
		case tags
		case urls
		case lastModifiedTime
		case attachments
	}

	var title: String = ""
	var website: String = ""
	var username: String = ""
	var email: String = ""
	@Published var password: String = "" // Published because it can be modified by the Password Generator
	var note: String = ""
	var tags: Array<String> = []
	var urls: Array<String> = []
	var lastModifiedTime: Date?
	
	/// Constructors
	required init(from decoder: Decoder) throws {
		try super.init(from: decoder)
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.title = try container.decode(String.self, forKey: .title)
		self.website = try container.decode(String.self, forKey: .website)
		self.username = try container.decode(String.self, forKey: .username)
		self.email = try container.decode(String.self, forKey: .email)
		self.password = try container.decode(String.self, forKey: .password)
		self.note = try container.decode(String.self, forKey: .note)
		self.tags = try container.decode(Array<String>.self, forKey: .tags)
		self.urls = try container.decode(Array<String>.self, forKey: .urls)
		self.lastModifiedTime = try container.decode(Date.self, forKey: .lastModifiedTime)
		self.attachments = try container.decode(Dictionary<String, Data>.self, forKey: .attachments)
	}
	override init() {
		super.init()
	}
	init(json: SecureLoginItemEncoding) {
		super.init(json: json)

		self.title = json.title ?? ""
		self.website = json.website
		self.username = json.username ?? ""
		self.email = json.email ?? ""
		self.password = json.password ?? ""
		self.note = json.note ?? ""
		self.tags = json.tags ?? []
		self.urls = json.urls ?? []
		self.lastModifiedTime = json.lastModifiedTime
		self.attachments = json.attachments ?? [:]
	}

	override func copy(from: SecureVaultItem) {
		let from2 = from as! SecureLoginItem
		self.title = from2.title
		self.website = from2.website
		self.username = from2.username
		self.email = from2.email
		self.password = from2.password
		self.note = from2.note
		self.tags = from2.tags
		self.urls = from2.urls
		self.lastModifiedTime = from2.lastModifiedTime
		self.attachments = from2.attachments
		
		super.copy(from: from)
	}

	/// Encode overrides
	override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(title, forKey: .title)
		try container.encode(website, forKey: .website)
		try container.encode(username, forKey: .username)
		try container.encode(email, forKey: .email)
		try container.encode(password, forKey: .password)
		try container.encode(note, forKey: .note)
		try container.encode(tags, forKey: .tags)
		try container.encode(urls, forKey: .urls)
		try container.encode(lastModifiedTime, forKey: .lastModifiedTime)
		try container.encode(attachments, forKey: .attachments)

		try super.encode(to: encoder)
	}

	/// Creates the file for the vault item.
	override func write(locationOfVaultItems: URL, masterKey: Data) throws {
		
		// Encode everything as JSON.
		let vaultData = SecureLoginItemEncoding(vaultVersion: self.vaultVersion, title: self.title, website: self.website, username: self.username, email: self.email, password: self.password, note: self.note, tags: self.tags, urls: self.urls, lastModifiedTime: self.lastModifiedTime, attachments: self.attachments)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!
		
		// Encrypt and write the data.
		try super.write(locationOfVaultItems: locationOfVaultItems, masterKey: masterKey, contents: jsonStr, itemType: VaultItemType.login)
	}

	/// Returns the string to use as the title when viewing this item.
	override func displayTitle() -> String {
		if self.title.count == 0 {
			return self.website
		}
		return self.title
	}
	
	/// Returns the string to use as the subtitle when viewing this item.
	override func displaySubtitle() -> String {
		return self.email
	}
	
	/// Called in response to the copy shortcut.. Adds the thing the user would most want to the pasteboard.
	override func copy() -> String {
		return self.password
	}

	/// Updates the last modified timestamp.
	override func updateLastModifiedTime() {
		self.lastModifiedTime = Date()
	}
}
