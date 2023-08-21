//
//  SecureAccessPointItem.swift
//  Created by Michael Simms on 2/19/23.
//

// MIT License
//
// Copyright (c) 2023 Mike Simms
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

struct SecureAccessPointEncoding: Codable {
	var vaultVersion: UInt8     // Version of this encoding
	var name: String            // Access point name
	var password: String        // Login password
	var note: String?           // Notes (optional)
	var tags: Array<String>?    // Tags (optional)
	var lastModifiedTime: Date? // Timestamp of the last update
}

class SecureAccessPointItem: SecureVaultItem {
	var name: String = ""
	var password: String = ""
	var note: String = ""
	var tags: Array<String> = []
	var lastModifiedTime: Date?
	
	/// Constructors
	required init(from decoder: Decoder) throws {
		fatalError("init(from:) has not been implemented")
	}
	override init() {
		super.init()
	}
	init(json: SecureAccessPointEncoding) {
		super.init(json: json)

		self.name = json.name
		self.password = json.password
		if json.note != nil {
			self.note = json.note!
		}
		if json.tags != nil {
			self.tags = json.tags!
		}
		self.lastModifiedTime = json.lastModifiedTime
	}
	
	/// Creates the file for the vault item.
	override func write(locationOfVaultItems: URL, masterKey: Data) throws {
		
		// Encode everything as JSON.
		let vaultData = SecureAccessPointEncoding(vaultVersion: self.vaultVersion, name: self.name, password: self.password, note: self.note, tags: self.tags, lastModifiedTime: self.lastModifiedTime)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!
		
		// Encrypt and write the data.
		try super.write(locationOfVaultItems: locationOfVaultItems, masterKey: masterKey, contents: jsonStr, itemType: VaultItemType.accessPoint)
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
