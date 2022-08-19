//
//  VaultItemFactory.swift
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

func createVaultItemFromFile(location: URL, masterKey: Data) throws -> SecureVaultItem {

	// Read the file.
	let data = try Data(contentsOf: location)

	// The key needs to be stored as a SymmetricKey object so we can use it in future calls.
	let keyObj = SymmetricKey(data: masterKey)

	// Parse the JSON string.
	let outerVaultItem = try JSONDecoder().decode(VaultItemEncoding.self, from: data)

	// Base64 decode the signature from the file. This signature is used to validate the encrypted contents.
	let decodedSignature = Data(base64Encoded: outerVaultItem.signature)
	guard let unwrappedDecodedSignature = decodedSignature else {
		throw VaultException.runtimeError("Error reading the vault item file: " + location.absoluteString + ".")
	}
	
	// Base64 decode the encrypted signature.
	let decodedContents = Data(base64Encoded: outerVaultItem.encryptedContents)
	guard let unwrappedDecodedContents = decodedContents else {
		throw VaultException.runtimeError("Error reading the vault item file: " + location.absoluteString + ".")
	}

	// Validate the signature.
	let signature = HMAC<SHA256>.authenticationCode(for: unwrappedDecodedContents, using: keyObj)
	let computedSigBytes = Data(signature)
	if computedSigBytes != unwrappedDecodedSignature {
		throw VaultException.runtimeError("Error reading the vault item file (invalid signature): " + location.absoluteString + ".")
	}

	// Decrypt the inner JSON string.
	let decryptedDecodedContents = try AES.GCM.open(AES.GCM.SealedBox(combined: unwrappedDecodedContents), using: keyObj)

	// Now we know the type of the underlying data so we can create an object of the correct type.
	switch outerVaultItem.itemType {
	case VaultItemType.login:
		let json = try JSONDecoder().decode(LoginItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureLoginItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.note:
		let json = try JSONDecoder().decode(NoteItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureNoteItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.card:
		let json = try JSONDecoder().decode(CardItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureCardItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	}
}
