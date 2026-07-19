//
//  VaultItemFactory.swift
//  Created by Michael Simms on 4/28/22.
//

//	MIT License
//
//  Copyright (c) 2022 Michael J Simms. All rights reserved.
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
		let json = try JSONDecoder().decode(SecureAccessPointItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureAccessPointItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.license:
		let json = try JSONDecoder().decode(SecureLicenseItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureLicenseItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.server:
		let json = try JSONDecoder().decode(SecureServerItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureServerItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.membership:
		let json = try JSONDecoder().decode(SecureMembershipItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecureMembershipItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	case VaultItemType.passport:
		let json = try JSONDecoder().decode(SecurePassportItemEncoding.self, from: decryptedDecodedContents)
		let newItem = SecurePassportItem(json: json)
		newItem.id = outerVaultItem.id
		return newItem
	}
}

func createLoginVaultItemFrom1Pif(contents: PifEncoding, note: String, tags: Array<String>, lastModifiedTime: Date) -> SecureLoginItem {
	let secureContents = contents.secureContents
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
			var fieldType = field.type ?? ""
			var fieldDesignation = field.designation ?? ""

			if fieldType.isEmpty {
				continue
			}

			fieldType = fieldType.lowercased()
			fieldDesignation = fieldDesignation.lowercased()

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
	
	let vaultData = SecureLoginItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, title: title, website: contents.location ?? "", username: username, email: email, password: password, note: note, tags: tags, urls: urls, lastModifiedTime: lastModifiedTime)
	return SecureLoginItem(json: vaultData)
}

func createCardVaultItemFrom1Pif(contents: PifEncoding, note: String, tags: Array<String>, lastModifiedTime: Date) throws -> SecureCardItem {
	let secureContents = contents.secureContents
	let cardType = secureContents.type ?? ""
	var cardHolder = ""
	var cardNum = ""
	var securityCode: Int = 0
	var expiryComponents = DateComponents()
	var validFromComponents = DateComponents()
	
	expiryComponents.month = Int(secureContents.expiry_mm ?? "1") ?? 0
	expiryComponents.year = Int(secureContents.expiry_yy ?? "2000") ?? 0
	let expiry = Calendar.current.date(from: expiryComponents) ?? Date()
	
	validFromComponents.month = Int(secureContents.validFrom_mm ?? "1") ?? 0
	validFromComponents.year = Int(secureContents.validFrom_yy ?? "2000") ?? 0
	let validFrom = Calendar.current.date(from: validFromComponents) ?? Date()
	
	if secureContents.sections != nil {
		for section in secureContents.sections! {
			if section.fields != nil {
				for field in section.fields! {
					let fieldName = field.n.lowercased()
					if field.v != nil {
						if fieldName == "cardholder" {
							cardHolder = try field.v!.decodeToString()
						}
						else if fieldName == "ccnum" && field.v != nil {
							cardNum = try field.v!.decodeToString()
						}
						else if fieldName == "cvv" && field.v != nil {
							securityCode = try field.v!.decodeToInt()
						}
					}
				}
			}
		}
	}
	
	let vaultData = SecureCardItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, name: contents.title, cardType: cardType, cardHolder: cardHolder, number: cardNum, securityCode: securityCode, expiry: expiry, validFrom: validFrom, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	return SecureCardItem(json: vaultData)
}

func createLicenseVaultItemFrom1Pif(contents: PifEncoding, note: String, tags: Array<String>, lastModifiedTime: Date) throws -> SecureLicenseItem {
	let secureContents = contents.secureContents
	let licenseHolder = secureContents.reg_name ?? ""
	let licenseKey = secureContents.reg_code ?? ""
	let licenseEmail = secureContents.reg_email ?? ""

	let vaultData = SecureLicenseItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, title: contents.title, licenseHolder: licenseHolder, licenseKey: licenseKey, licenseEmail: licenseEmail, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	return SecureLicenseItem(json: vaultData)
}

func createServerItemFromPif(contents: PifEncoding, note: String, tags: Array<String>, lastModifiedTime: Date) throws -> SecureServerItem {
	let vaultData = SecureServerItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, title: contents.title, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	return SecureServerItem(json: vaultData)
}

func createPassportVaultItemFrom1Pif(contents: PifEncoding, note: String, tags: Array<String>, lastModifiedTime: Date) {
}

func createMembershipVaultItemFrom1Pif(contents: PifEncoding, note: String, tags: Array<String>, lastModifiedTime: Date) throws -> SecureMembershipItem {
	let secureContents = contents.secureContents
	let membership_no = secureContents.membership_no ?? ""
	let member_since_yy = secureContents.member_since_yy ?? ""
	let member_since_mm = secureContents.member_since_mm ?? ""

	let vaultData = SecureMembershipItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, title: contents.title, membershipNumber: membership_no, memberSinceYY: member_since_yy, memberSinceMM: member_since_mm, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	return SecureMembershipItem(json: vaultData)
}

func createVaultItemFrom1Pif(contents: PifEncoding) throws -> SecureVaultItem {
	let secureContents = contents.secureContents
	let note = secureContents.notesPlain ?? ""
	var tags: Array<String> = []
	let lastModifiedTime = Date(timeIntervalSince1970: TimeInterval(contents.updatedAt))

	if contents.openContents != nil {
		tags = contents.openContents?.tags ?? []
	}

	// Simple password or login
	if contents.typeName == "passwords.Password" || contents.typeName == "webforms.WebForm" {
		return createLoginVaultItemFrom1Pif(contents: contents, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	}

	// Note
	else if contents.typeName == "securenotes.SecureNote" {
		let note = secureContents.notesPlain ?? ""
		let vaultData = SecureNoteItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, heading: contents.title, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
		return SecureNoteItem(json: vaultData)
	}

	// Credit Card
	else if contents.typeName == "wallet.financial.CreditCard" {
		return try createCardVaultItemFrom1Pif(contents: contents, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	}

	// Wifi
	else if contents.typeName == "wallet.computer.Router" {
		let networkName = secureContents.name ?? ""
		let password = secureContents.password ?? ""

		let vaultData = SecureAccessPointItemEncoding(vaultVersion: Vault.kCurrentVaultVersion, name: networkName, password: password, note: note, tags: tags)
		return SecureAccessPointItem(json: vaultData)
	}

	// Software license
	else if contents.typeName == "wallet.computer.License" {
		return try createLicenseVaultItemFrom1Pif(contents: contents, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	}

	// Server credentials
	else if contents.typeName == "wallet.computer.UnixServer" {
		return try createServerItemFromPif(contents: contents, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	}

	// Passport
	else if contents.typeName == "wallet.government.Passport" {
		//return try createPassportVaultItemFrom1Pif(contents: contents, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	}

	// Club membership
	else if contents.typeName == "wallet.membership.Membership" {
		return try createMembershipVaultItemFrom1Pif(contents: contents, note: note, tags: tags, lastModifiedTime: lastModifiedTime)
	}

	throw VaultException.runtimeError("Unknown import type.")
}
