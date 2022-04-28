//
//  VaultItemFactory.swift
//  PasswordVault
//
//  Created by Michael Simms on 4/28/22.
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
import CryptoKit

enum VaultItemType: UInt8, Codable {
	case login
	case note
}

/// Encapsulates the data stored in an encrypted vault item file.
struct VaultItemEncoding: Codable {
	// File version information
	var vaultVersion: UInt8
	// Item type enumeration
	var itemType: VaultItemType
	// Master secret that is used encrypt the vault items, protected using the master key from the vault index
	// Once decrypted this should contain another JSON string, specific to the type of data being stored.
	var encryptedContents: String
	// HMAC signature of the encrypted contents
	var signature: String
}

struct LoginItemEncoding: Codable {
	var note: String
	var website: String
	var username: String
	var email: String
}

struct NoteItemEncoding: Codable {
	var note: String
}

func createVaultItemFromFile(location: URL, key: Data) throws -> SecureVaultItem? {

	// Read the file.
	let data = try Data(contentsOf: location)

	// Parse the JSON string.
	let tempItem = try JSONDecoder().decode(VaultItemEncoding.self, from: data)
	
	// Decrypt the subitem.
	let key2 = SymmetricKey(data: key)
	let decodedContents = Data(base64Encoded: tempItem.encryptedContents)
	guard let unwrappedDecodedContents = decodedContents else {
		throw VaultException.runtimeError("Error reading the vault item file.")
	}
	let decryptedDecodedContents = try! AES.GCM.open(AES.GCM.SealedBox(combined: unwrappedDecodedContents), using: key2)

	// Now we know the type of the underlying data so we can create an object of the correct type.
	switch tempItem.itemType {
	case VaultItemType.login:
		let subItem = try JSONDecoder().decode(LoginItemEncoding.self, from: decryptedDecodedContents)
		let item = SecureLoginItem()
		item.note = subItem.note
		item.website = subItem.website
		item.username = subItem.username
		item.email = subItem.email
		return item
	case VaultItemType.note:
		let subItem = try JSONDecoder().decode(NoteItemEncoding.self, from: decryptedDecodedContents)
		let item = SecureNoteItem()
		item.note = subItem.note
		return item
	}
}
