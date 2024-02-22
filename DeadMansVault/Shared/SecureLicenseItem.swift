//
//  SecureLicenseItem.swift
//  Created by Michael Simms on 9/14/23.
//

//	MIT License
//
//  Copyright (c) 2023 Michael J Simms. All rights reserved.
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

struct SecureLicenseItemEncoding: Codable {
	var vaultVersion: UInt8                    // Version of this encoding
	var title: String                          // Name of this license
	var licenseHolder: String                  // Name of the person/org to whom the license is registered
	var licenseKey: String                     // License number/string/whatever
	var licenseEmail: String                   // Email address associated with the license
	var note: String                           // Any notes
	var tags: Array<String>?                   // Tags
	var lastModifiedTime: Date?                // Timestamp of the last update
	var attachments: Dictionary<String, Data>? // Data for all attachments
}

class SecureLicenseItem: SecureVaultItem {
	enum CodingKeys: CodingKey {
		case title
		case licenseHolder
		case licenseKey
		case licenseEmail
		case note
		case tags
		case lastModifiedTime
		case attachments
	}

	var title: String = ""
	var licenseHolder: String = ""
	var licenseKey: String = ""
	var licenseEmail: String = ""
	var note: String = ""
	var tags: Array<String> = []
	var lastModifiedTime: Date?
	
	/// Constructors
	required init(from decoder: Decoder) throws {
		try super.init(from: decoder)

		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.title = try container.decode(String.self, forKey: .title)
		self.licenseHolder = try container.decode(String.self, forKey: .licenseHolder)
		self.licenseKey = try container.decode(String.self, forKey: .licenseKey)
		self.licenseEmail = try container.decode(String.self, forKey: .licenseEmail)
		self.note = try container.decode(String.self, forKey: .note)
		self.tags = try container.decode(Array<String>.self, forKey: .tags)
		self.lastModifiedTime = try container.decode(Date.self, forKey: .lastModifiedTime)
		self.attachments = try container.decode(Dictionary<String, Data>.self, forKey: .attachments)
	}
	override init() {
		super.init()
	}
	init(json: SecureLicenseItemEncoding) {
		super.init(json: json)
		
		self.title = json.title
		self.licenseHolder = json.licenseHolder
		self.licenseKey = json.licenseKey
		self.licenseEmail = json.licenseEmail
		self.note = json.note
		self.tags = json.tags ?? []
		self.lastModifiedTime = json.lastModifiedTime
		self.attachments = json.attachments ?? [:]
	}

	override func copy(from: SecureVaultItem) {
		let from2 = from as! SecureLicenseItem
		self.title = from2.title
		self.licenseHolder = from2.licenseHolder
		self.licenseKey = from2.licenseKey
		self.licenseEmail = from2.licenseEmail
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
		try container.encode(licenseHolder, forKey: .licenseHolder)
		try container.encode(licenseKey, forKey: .licenseKey)
		try container.encode(licenseEmail, forKey: .licenseEmail)
		try container.encode(note, forKey: .note)
		try container.encode(tags, forKey: .tags)
		try container.encode(lastModifiedTime, forKey: .lastModifiedTime)
		try container.encode(attachments, forKey: .attachments)

		try super.encode(to: encoder)
	}

	/// Creates the file for the vault item.
	override func write(locationOfVaultItems: URL, masterKey: Data) throws {
		
		// Encode everything as JSON.
		let vaultData = SecureLicenseItemEncoding(vaultVersion: self.vaultVersion, title: self.title, licenseHolder: self.licenseHolder, licenseKey: self.licenseKey, licenseEmail: self.licenseEmail, note: self.note, tags: self.tags, lastModifiedTime: self.lastModifiedTime, attachments: self.attachments)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!
		
		// Encrypt and write the data.
		try super.write(locationOfVaultItems: locationOfVaultItems, masterKey: masterKey, contents: jsonStr, itemType: VaultItemType.license)
	}
	
	/// Returns the string to use as the title when viewing this item.
	override func displayTitle() -> String {
		return self.title
	}
	
	/// Called in response to the copy shortcut.. Adds the thing the user would most want to the pasteboard.
	override func copy() -> String {
		return self.licenseKey
	}

	/// Updates the last modified timestamp.
	override func updateLastModifiedTime() {
		self.lastModifiedTime = Date()
	}
}
