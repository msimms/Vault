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
		let json = try JSONDecoder().decode(SecureLoginItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureLoginItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.note:
		let json = try JSONDecoder().decode(SecureNoteItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureNoteItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.card:
		let json = try JSONDecoder().decode(SecureCardItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureCardItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.accessPoint:
		let json = try JSONDecoder().decode(SecureAccessPointEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureAccessPointItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	}
}

func createVaultItemFrom1Pif(contents: PifEncoding) throws -> SecureVaultItem {
	let secureContents = contents.secureContents
	let note = secureContents.notesPlain
	var tags: Array<String> = []

	if contents.openContents != nil {
		tags = contents.openContents?.tags ?? []
	}

	if contents.typeName == "passwords.Password" || contents.typeName == "webforms.WebForm" {
		var username = ""
		var email = ""
		let title = contents.title
		var password = secureContents.password
		var urls: Array<String> = []

		if secureContents.urls != nil {
			for url in secureContents.urls! {
				urls.append(url.url)
			}
		}
		if secureContents.sections != nil {
			for section in secureContents.sections! {
				if section.fields != nil {
					for _ in section.fields! {
					}
				}
			}
		}
		if secureContents.fields != nil {
			for field in secureContents.fields! {
				let fieldType = field.type.lowercased()
				let fieldDesignation = field.designation.lowercased()

				if fieldType == "k" {
				}
				else if fieldType == "n" {
				}
				else if fieldType == "p" && fieldDesignation == "password" {
					password = field.value
				}
				else if fieldType == "v" {
				}
				else if fieldType == "t" {
					if fieldDesignation == "username" {
						username = field.value
					}
					if field.value.contains("@") {
						email = field.value
					}
				}
			}
		}

		let vaultData = SecureLoginItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, title: title, website: contents.location!, username: username, email: email, password: password, note: note, tags: tags, urls: urls, lastModifiedTime: Date(timeIntervalSince1970: TimeInterval(contents.updatedAt)))
		return SecureLoginItem(json: vaultData)
	}
	else if contents.typeName == "securenotes.SecureNote" {
		let vaultData = SecureNoteItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, heading: contents.title, note: secureContents.notesPlain!, tags: tags, lastModifiedTime: Date(timeIntervalSince1970: TimeInterval(contents.updatedAt)))
		return SecureNoteItem(json: vaultData)
	}
	else if contents.typeName == "wallet.financial.CreditCard" {
		var cardHolder = ""
		var cardNum = ""
		var securityCode: Int = 0
		let expiry: Date = Date()

		if secureContents.sections != nil {
			for section in secureContents.sections! {
				if section.fields != nil {
					for field in section.fields! {
						if field.n.lowercased() == "cardholder" {
							cardHolder = try field.v!.decodeToString()
						}
						else if field.n.lowercased() == "ccnum" && field.v != nil {
							cardNum = try field.v!.decodeToString()
						}
						else if field.n.lowercased() == "cvv" && field.v != nil {
							securityCode = try field.v!.decodeToInt()
						}
					}
				}
			}
		}

		let vaultData = SecureCardItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, name: contents.title, cardType: secureContents.type ?? "", cardHolder: cardHolder, number: cardNum, securityCode: securityCode, expiry: expiry)
		return SecureCardItem(json: vaultData)
	}
	else if contents.typeName == "wallet.computer.Router" {
		let vaultData = SecureAccessPointEncoding(vaultVersion: Vault.kCurrentVaultVersion, name: secureContents.name ?? "", password: secureContents.password ?? "", note: note, tags: tags)
		return SecureAccessPointItem(json: vaultData)
	}
	throw VaultException.runtimeError("Unknown import type.")
}
