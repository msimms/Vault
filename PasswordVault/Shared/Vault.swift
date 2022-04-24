//
//  Vault.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

// -*- coding: utf-8 -*-
//
// # MIT License
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

/// Encapsulates the data stored in the vault's master file
struct VaultIndex: Codable {
	var vaultVersion: UInt8
	var encryptedMasterKey: String
}

class Vault {
	public static let kCurrentVaultVersion: UInt8 = 0
	var vaultItems: [SecureVaultItem] = []

	let vaultFileName = "vault.json"
	var vaultDirUrl: URL? // Complete path to the directory containing the vault
	var masterKey: String?

	/// Utility function for creating the master key.
	func generateMasterKey() -> Data? {

		var keyData = Data(count: 32)
		let result = keyData.withUnsafeMutableBytes {
			SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
		}
		if result == errSecSuccess {
			return keyData
		}
		return nil
	}

	/// Utility function for building the URL to the vault's master file.
	func buildVaultMasterFileUrl(location: String) -> URL? {

		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		if location.count == 0 {
			self.vaultDirUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
		}
		else {
			self.vaultDirUrl = URL(string: location)
		}
		self.vaultDirUrl = self.vaultDirUrl?.appendingPathComponent("PasswordVault")

		// Build the URL for the vault's master file.
		return self.vaultDirUrl?.appendingPathComponent(self.vaultFileName)
	}

	/// Returns true if a vault exists (spexcifically the vault index file) at the location stored in the user preferences.
	func exists(location: String) -> Bool {
		let vaultMasterFileUrl = self.buildVaultMasterFileUrl(location: location)
		return FileManager.default.fileExists(atPath: vaultMasterFileUrl!.path)
	}

	/// Returns true if a vault is open, i.e. unlocked.
	func isOpen() -> Bool {
		guard let unwrappedMasterKey = masterKey else { return false }
		return unwrappedMasterKey.isEmpty;
	}

	/// Creates the vault. If the location is not provided then the vault is created on the user's iCloud drive.
	func create(location: String, key: String) throws {

		// Sanity check the parameters.
		if key.count == 0 {
			throw VaultException.runtimeError("A key was not provided.")
		}

		// Make sure any existing vaults are closed.
		if !self.close() {
			throw VaultException.runtimeError("The vault is already open.")
		}

		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		let vaultMasterFileUrl = self.buildVaultMasterFileUrl(location: location)

		// Does anything exist at the vault master file's path?
		if !FileManager.default.fileExists(atPath: vaultMasterFileUrl!.path) {

			// Create the parent directory.
			try FileManager.default.createDirectory(at: self.vaultDirUrl!, withIntermediateDirectories: true, attributes: nil)

			// Create the vault's master file.
			if (FileManager.default.createFile(atPath: vaultMasterFileUrl!.path, contents: nil, attributes: nil)) {

				// Generate a random master key.
				let masterKey = self.generateMasterKey()
				guard let unwrappedMasterKey = masterKey else {
					throw VaultException.runtimeError("Error generating master key.")
				}

				// Hash the user key. This gives us something that is apparently random that is also 256-bits in length.
				let userKeyDigest = SHA256.hash(data: Data(key.utf8))

				// Compute the HMAC.
				
				// Encrypt the master key with the user key.
				let encryptedMasterKey = try aesCBCEncrypt(data: unwrappedMasterKey, keyData: Data(userKeyDigest))

				// Base64 encode the master key for writing.
				let base64MasterKey = encryptedMasterKey.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

				// Encode everything as JSON.
				let vaultData = VaultIndex(vaultVersion: 0, encryptedMasterKey: base64MasterKey)
				let encoder = JSONEncoder()
				let jsonString = try encoder.encode(vaultData)

				// Write it out.
				try jsonString.write(to: vaultMasterFileUrl!)
			}
			else {
				throw VaultException.runtimeError("Failed to create the vault's master file.")
			}
		}
		else {
			throw VaultException.runtimeError("A vault already exists at that location.")
		}
	}

	/// Opens the vault by opening the master vault file and decoding it.
	func open(location: String, key: String) throws {

		// Sanity check the parameters.
		if key.count == 0 {
			throw VaultException.runtimeError("A key was not provided.")
		}

		// Make sure any existing vaults are closed.
		if !self.close() {
			throw VaultException.runtimeError("The vault is already open.")
		}

		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		let vaultMasterFileUrl = self.buildVaultMasterFileUrl(location: location)

		// Does anything exist at the vault master file's path?
		if FileManager.default.fileExists(atPath: vaultMasterFileUrl!.path) {

			// Read the master file.
			let data = try? Data(contentsOf: vaultMasterFileUrl!)

			// Parse the JSON string.
			let jsonString = try? JSONDecoder().decode(VaultIndex.self, from: data!)

			// Hash the user key to get the 256-bit key that we will use to decrypt the master key.
			let userKeyDigest = SHA256.hash(data: Data(key.utf8))

			// Validate the provided key.

			// Decrypt the master key.
		}
		else {
			throw VaultException.runtimeError("Cannot find the vault.")
		}
	}

	/// Completely deletes the vault and all it's items.
	func delete(location: String, key: String) throws {

		// Sanity check the parameters.
		if key.count == 0 {
			throw VaultException.runtimeError("A key was not provided.")
		}
	}

	/// Returns all the items in the vault.
	func readItems() -> Array<SecureVaultItem> {
		let fileManager = FileManager.default

		do {
			let dirListing = try fileManager.contentsOfDirectory(at: self.vaultDirUrl!, includingPropertiesForKeys: nil)
			for listing in dirListing {
				print(listing)
			}
			
			// test data
			let testItem1 = SecureLoginItem()
			testItem1.email = "foo@bar.com"
			testItem1.username = "foo@bar.com"
			testItem1.website = "example.com"
			vaultItems.append(testItem1)

			let testItem2 = SecureLoginItem()
			testItem2.email = "bar@bar.com"
			testItem2.username = "bar@bar.com"
			testItem2.website = "example.com"
			vaultItems.append(testItem2)

			let testItem3 = SecureNoteItem()
			testItem3.title = "Secret Note"
			testItem3.blob = "hello world"
			vaultItems.append(testItem3)
		}
		catch {
		}
		return vaultItems
	}

	/// Adds a new item to the vault.
	func addItem(item: SecureVaultItem) throws {

		// Sanity check.
		if !isOpen() {
			throw VaultException.runtimeError("The vault is not open.")
		}
		
		// Make sure the item does not already exist in the vault.

		// Build the JSON representation.
		
		// Encrypt with the master key.
		
		// Append the HMAC.
		
		// Write it out.
	}

	/// Updates an existing item in the vault.
	func updateItem(item: SecureVaultItem) throws {

		// Sanity check.
		if !isOpen() {
			throw VaultException.runtimeError("The vault is not open.")
		}
		
		// Find the item in the vault.
	}

	/// Removes an item from the vault.
	func deleteItem(item: SecureVaultItem) throws {

		// Sanity check.
		if !isOpen() {
			throw VaultException.runtimeError("The vault is not open.")
		}

		// Find the item in the vault.
		
		// Remove it from memory.
		
		// Remove it from disk.
	}

	/// Closes the vault by clearing any data we have that is associated with it.
	func close() -> Bool {
		self.vaultDirUrl = URL(string: "")
		self.masterKey = ""
		return true
	}
}
