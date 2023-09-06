//
//  SecureVaultItem.swift
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
import CryptoKit

/// Enumerates the possible vault item types. Each one will have a corresponding class that inherits from SecureVaultItem.
enum VaultItemType: UInt8, Codable {
	case login
	case note
	case card
	case accessPoint
}

/// Encapsulates the data stored in an encrypted vault item file.
struct VaultItemEncoding: Codable {
	// File version information
	var vaultVersion: UInt8
	// Unique identifier
	var id: UUID
	// Item type enumeration
	var itemType: VaultItemType
	// Master secret that is used encrypt the vault items, protected using the master key from the vault index
	// Once decrypted this should contain another JSON string, specific to the type of data being stored.
	var encryptedContents: String
	// HMAC signature of the encrypted contents
	var signature: String
}

class SecureVaultItem: Codable, Identifiable, Comparable, Hashable {
	enum CodingKeys: CodingKey {
		case id
		case vaultVersion
	}
	
	var id = UUID()
	var vaultVersion: UInt8 = Vault.kCurrentVaultVersion
	var attachments: Array<Data> = []
	
	/// Constructor
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.vaultVersion = try container.decode(UInt8.self, forKey: .vaultVersion)
	}
	init() {
	}
	init(json: Decodable) {
	}

	/// Encode overrides
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(vaultVersion, forKey: .vaultVersion)
	}

	/// Hashable overrides
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
	/// Creates the file for the vault item. The 'content' will be encrypted with the master key, base 64 encoded, and stored as a JSON string.
	func write(locationOfVaultItems: URL, masterKey: Data, contents: String, itemType: VaultItemType) throws {
		
		// Sanity check the parameters.
		if masterKey.count == 0 {
			throw VaultException.runtimeError("Error when saving a vault item.")
		}
		
		// Encrypt the contents.
		let masterKeyObj = SymmetricKey(data: masterKey)
		let encryptedContents = try! AES.GCM.seal(Data(contents.utf8), using: masterKeyObj).combined
		guard let unwrappedEncryptedContents = encryptedContents else {
			throw VaultException.runtimeError("Error when saving a vault item.")
		}
		
		// Compute the signature of the encrypted contents.
		let signature = HMAC<SHA256>.authenticationCode(for: unwrappedEncryptedContents, using: masterKeyObj)
		
		// Base64 encode all the things.
		let base64Contents = unwrappedEncryptedContents.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
		let base64Signature = Data(signature).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
		
		// Wrap the encoded contents into another JSON object, which will be written to the file.
		let vaultData = VaultItemEncoding(vaultVersion: self.vaultVersion, id: self.id, itemType: itemType, encryptedContents: base64Contents, signature: base64Signature)
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(vaultData)
		let jsonStr = String(data: jsonData, encoding: .utf8)!
		
		// The file name is just the UUID of the item.
		let fileLocation = locationOfVaultItems.appendingPathComponent(id.uuidString)
		
		// Write it out.
		try jsonStr.write(to: fileLocation, atomically: true, encoding: String.Encoding.utf8)
	}
	
	/// Creates the file for the vault item.
	func write(locationOfVaultItems: URL, masterKey: Data) throws {
	}
	
	/// Returns the string to use as the title when viewing this item.
	func displayTitle() -> String {
		return ""
	}
	
	/// Returns the string to use as the subtitle when viewing this item.
	func displaySubtitle() -> String {
		return ""
	}
	
	/// If the child class tracks the last modified time then this will trigger an update.
	func updateLastModifiedTime() {
	}
	
	func attachFile(url: URL) {
		do {
			// Read the file
			let data = try Data(contentsOf: url)
			
			// Compress the file.
			let compressedData = try (data as NSData).compressed(using: .lzfse)
			self.attachments.append(Data(compressedData))
		}
		catch {
		}
	}
}

func < (lhs: SecureVaultItem, rhs: SecureVaultItem) -> Bool {
	return lhs.displayTitle() < rhs.displayTitle()
}

func == (lhs: SecureVaultItem, rhs: SecureVaultItem) -> Bool {
	return lhs.displayTitle() == rhs.displayTitle()
}
