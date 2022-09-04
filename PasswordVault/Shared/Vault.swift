//
//  Vault.swift
//  Created by Michael Simms on 12/12/21.
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

/// Encapsulates the data stored in the vault's master file
struct VaultIndex: Codable {
	// File version information
	var vaultVersion: UInt8
	// Master secret that is used encrypt the vault items, protected using the key provided by the user
	var encryptedMasterKey: String
	// HMAC signature of the encrypted master key
	var signature: String
}

class Vault : ObservableObject {
	public static let kCurrentVaultVersion: UInt8 = 0

	/// List of everything read from the vault.
	@Published var vaultItems: Array<SecureVaultItem> = []
	/// Complete path to the directory containing the vault.
	private var vaultDirUrl: URL?
	/// Complete path to the vault's master file..
	private var vaultMasterFileUrl: URL?
	/// Complete path to the directory containing the vault items. Each file in this directory represents a single vault item.
	private var vaultItemsDirUrl: URL?
	/// The key used for encrypting and decrypting vault items; this key is randomly generated and protected by the user's key/password.
	private var masterKey: Data?
	/// Semaphore that controls writes the vault item array.
	private let vaultItemsSemaphore = DispatchSemaphore(value: 1)

	private func insertVaultItem(item: SecureVaultItem) {

		// Wait for the semaphore.
		self.vaultItemsSemaphore.wait()
		
		// Insert sorted.
		let index = self.vaultItems.reduce(0) { $1 < item ? $0 + 1 : $0 }
		self.vaultItems.insert(item, at: index)

		// Release the semaphore.
		self.vaultItemsSemaphore.signal()
	}
	
	private func processVaultFile(fileURL: URL) throws {

		// Parse the file.
		let item = try createVaultItemFromFile(location: fileURL, masterKey: self.masterKey!)
		
		// Update the list.
		self.insertVaultItem(item: item)
	}

	private func downloadVaultMasterFile() throws {
		
		var query: NSMetadataQuery
		query = NSMetadataQuery.init()
		query.operationQueue = .main
		query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, "vault.json")
		query.searchScopes = [ NSMetadataQueryUbiquitousDocumentsScope ]
		
		var downloaded = false
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: query.operationQueue) { (notification) in
			downloaded = true
			query.stop()
			NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidUpdate, object: query)
		}
		
		// Start monitoring.
		query.start()
		
		// Start downloading.
		try FileManager.default.startDownloadingUbiquitousItem(at: self.vaultMasterFileUrl!)

		// Filty hack, but there really isn't anything we can do until we download the master file.
		sleep(5);
	}

	private func downloadVaultFile(fileToDownload: URL) throws {

		var downloadedFileName = fileToDownload.deletingPathExtension().lastPathComponent
		downloadedFileName.removeFirst()

		var query: NSMetadataQuery
		query = NSMetadataQuery.init()
		query.operationQueue = .main
		query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, downloadedFileName)
		query.searchScopes = [ NSMetadataQueryUbiquitousDocumentsScope ]
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: query.operationQueue) { (notification) in

			for item in query.results {
				guard let item = item as? NSMetadataItem else { continue }
				guard let fileURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { continue }

				do {
					try self.processVaultFile(fileURL: fileURL)

					query.stop()
					NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidUpdate, object: query)
				} catch {
					print(error.localizedDescription)
				}
			}
		}
		
		// Start monitoring.
		query.start()

		// Start downloading.
		try FileManager.default.startDownloadingUbiquitousItem(at: fileToDownload)
	}

	/// Utility function for creating the master key.
	private func generateRandomBytes() -> Data? {

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
	private func buildVaultUrls(location: String) throws {

		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		if location.count == 0 {
			self.vaultDirUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
			if self.vaultDirUrl == nil {
				throw VaultException.runtimeError("iCloud storage is disabled.")
			}
			self.vaultDirUrl = self.vaultDirUrl?.appendingPathComponent("Documents")
		}
		else {
			self.vaultDirUrl = URL(string: location)
		}

		// URL for the vault items.
		self.vaultItemsDirUrl = self.vaultDirUrl?.appendingPathComponent("items")

		// Build the URL for the vault's master file.
		self.vaultMasterFileUrl = self.vaultDirUrl?.appendingPathComponent("vault.json", isDirectory: false)
	}
	
	private func buildICloudVaultMasterFileUrl() -> URL {
		return self.vaultDirUrl!.appendingPathComponent(".vault.json.icloud", isDirectory: false)
	}

	/// Returns true if a vault exists (spexcifically the vault index file) at the location stored in the user preferences.
	func exists(location: String) throws -> Bool {
		try self.buildVaultUrls(location: location)

		if !FileManager.default.fileExists(atPath: self.vaultMasterFileUrl!.path) {
			return FileManager.default.fileExists(atPath: self.buildICloudVaultMasterFileUrl().path)
		}
		return true
	}

	/// Returns true if a vault is open, i.e. unlocked.
	func isOpen() -> Bool {
		guard let unwrappedMasterKey = self.masterKey else { return false }
		return !unwrappedMasterKey.isEmpty;
	}

	/// Creates the vault. If the location is not provided then the vault is created on the user's iCloud drive.
	func create(location: String, key: String) throws {

		// Sanity check the parameters.
		if key.count == 0 {
			throw VaultException.runtimeError("A key was not provided.")
		}

		// Make sure any existing vaults are closed.
		self.close()

		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		try self.buildVaultUrls(location: location)

		// Does anything exist at the vault master file's path?
		if !FileManager.default.fileExists(atPath: self.vaultMasterFileUrl!.path) {

			// Create the parent directory.
			try FileManager.default.createDirectory(at: self.vaultDirUrl!, withIntermediateDirectories: true, attributes: nil)

			// Generate a random master key. This is the key we will use to encrypt vault items.
			self.masterKey = self.generateRandomBytes()
			guard let unwrappedMasterKey = self.masterKey else {
				throw VaultException.runtimeError("Error generating master key.")
			}

			// Use a key derivation function to compute the AES key from the key provided by the user.
			// For a salt, we'll hash the key provided by the user.
			let userProvidedKey = SymmetricKey(data: Data(key.utf8))
			let salt = Data(SHA256.hash(data: Data(key.utf8)))
			let derivedUserKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: userProvidedKey, salt: salt, outputByteCount: 32)

			// Encrypt the randomly generated master key with the AES key we derived from the user key.
			let encryptedMasterKey = try! AES.GCM.seal(unwrappedMasterKey, using: derivedUserKey).combined

			// Compute the HMAC of the encrypted master key.
			let signature = HMAC<SHA256>.authenticationCode(for: encryptedMasterKey!, using: userProvidedKey)
			let base64Signature = Data(signature).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

			// Base64 encode the binary things so they can be written as JSON.
			let base64MasterKey = encryptedMasterKey?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

			// Encode everything as JSON.
			let vaultData = VaultIndex(vaultVersion: Vault.kCurrentVaultVersion, encryptedMasterKey: base64MasterKey!, signature: base64Signature)
			let encoder = JSONEncoder()
			let jsonData = try encoder.encode(vaultData)
			let jsonStr = String(data: jsonData, encoding: .utf8)!

			// Write it out.
			try jsonStr.write(to: self.vaultMasterFileUrl!, atomically: true, encoding: String.Encoding.utf8)
		}
		else {
			throw VaultException.runtimeError("A vault already exists at that location.")
		}
	}

	/// Opens the vault by opening the master vault file and decoding it.
	func open(vaultLocation: String, key: String) throws {

		// Sanity check the parameters.
		if key.count == 0 {
			throw VaultException.runtimeError("A key was not provided.")
		}

		// Make sure any existing vaults are closed.
		self.close()

		// Build the URL for the vault's directory. If a location was provided then
		// use it, otherwise assume the user's iCloud directory.
		try self.buildVaultUrls(location: vaultLocation)

		// Does the file need to be downloaded from iCloud?
		let iCloudVaultMasterFileUrl = self.buildICloudVaultMasterFileUrl()
		if FileManager.default.fileExists(atPath: iCloudVaultMasterFileUrl.path) {
			try self.downloadVaultMasterFile()
		}

		// Does anything exist at the vault master file's path?
		if FileManager.default.fileExists(atPath: self.vaultMasterFileUrl!.path) {

			// Read the master file.
			let data = try? Data(contentsOf: self.vaultMasterFileUrl!)

			// Parse the JSON string.
			let jsonString = try? JSONDecoder().decode(VaultIndex.self, from: data!)
			guard let unwrappedJsonString = jsonString else {
				throw VaultException.runtimeError("Error reading the vault file.")
			}

			// Base64 decode the encrypted master key as read from the file.
			let decodedMasterKey = Data(base64Encoded: unwrappedJsonString.encryptedMasterKey)
			guard let unwrappedDecodedMasterKey = decodedMasterKey else {
				throw VaultException.runtimeError("Error reading the vault file.")
			}

			// Compute the salt from the key provided by the user.
			let salt = Data(SHA256.hash(data: Data(key.utf8)))

			// Base64 decode the signature from the file. This signature is used to validate the master key.
			let decodedSignature = Data(base64Encoded: unwrappedJsonString.signature)
			guard let unwrappedDecodedSignature = decodedSignature else {
				throw VaultException.runtimeError("Error reading the vault file.")
			}

			// Compute the AES key from the key provided by the user.
			let userProvidedKey = SymmetricKey(data: Data(key.utf8))
			let derivedUserKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: userProvidedKey, salt: salt, outputByteCount: 32)

			// Compute the HMAC of the encrypted master key.
			let signature = HMAC<SHA256>.authenticationCode(for: unwrappedDecodedMasterKey, using: userProvidedKey)
			let computedSigBytes = Data(signature)
			if computedSigBytes != unwrappedDecodedSignature {
				throw VaultException.runtimeError("Error reading the vault file.")
			}

			// Decrypt the master key.
			self.masterKey = try! AES.GCM.open(AES.GCM.SealedBox(combined: unwrappedDecodedMasterKey), using: derivedUserKey)
		}
		else {
			throw VaultException.runtimeError("Cannot find the vault.")
		}
	}

	/// Completely deletes the vault and all it's items.
	func delete() throws {

		// Sanity check.
		if !isOpen() {
			throw VaultException.runtimeError("The vault is not open.")
		}

		// Does anything exist at the vault master file's path?
		if FileManager.default.fileExists(atPath: self.vaultMasterFileUrl!.path) {
			
			// List all the items in the vault items directory.
			let dirListing = try FileManager.default.contentsOfDirectory(at: self.vaultItemsDirUrl!, includingPropertiesForKeys: nil)
			for listing in dirListing {

				// Delete the vault item file.
				try FileManager.default.removeItem(at: listing)
			}
			
			// Delete the master vault file.
			try FileManager.default.removeItem(at: self.vaultMasterFileUrl!)
		}

		self.close()
	}

	/// Returns all the items in the vault.
	func readItems() throws {

		// Sanity check.
		if !isOpen() {
			throw VaultException.runtimeError("The vault is not open.")
		}

		// Clear any existing contents from the list.
		self.vaultItems = []

		// List all the items in the vault items directory.
		let dirListing = try FileManager.default.contentsOfDirectory(at: self.vaultItemsDirUrl!, includingPropertiesForKeys: nil)
		for listing in dirListing {

			do {
				// Does the file need to be downloaded from iCloud?
				if listing.lastPathComponent.contains(".icloud") {
					try self.downloadVaultFile(fileToDownload: listing)
				}

				// If the file name is not a UUID then skip it as all valid files in this directory will have UUIDs for file names.
				else if UUID(uuidString: listing.lastPathComponent) != nil {
					try self.processVaultFile(fileURL: listing)
				}
			} catch let error as NSError {
				print("Error: Failed to read: \n\(error)")
			} catch {
				print(error.localizedDescription)
			}
		}
	}

	/// Adds a new item to the vault.
	func addItem(item: SecureVaultItem) throws {

		// Sanity check.
		if !isOpen() {
			throw VaultException.runtimeError("The vault is not open.")
		}

		// Does the vault's item directory actually exist? If not, create it.
		if !FileManager.default.fileExists(atPath: self.vaultItemsDirUrl!.path) {
			try FileManager.default.createDirectory(at: self.vaultItemsDirUrl!, withIntermediateDirectories: true, attributes: nil)
		}

		// Unwrap the master key.
		guard let unwrappedMasterKey = self.masterKey else {
			throw VaultException.runtimeError("Error retrieving the master key.")
		}

		// Write it out.
		try item.write(locationOfVaultItems: self.vaultItemsDirUrl!, masterKey: unwrappedMasterKey)
	}

	/// Removes an item from the vault.
	func deleteItem(item: SecureVaultItem) throws {
		
		// Sanity check.
		if !isOpen() {
			throw VaultException.runtimeError("The vault is not open.")
		}
		
		// Remove it from disk.
		// The file name is just the UUID of the item.
		let fileLocation = self.vaultItemsDirUrl!.appendingPathComponent(item.id.uuidString, isDirectory: false)
		try FileManager.default.removeItem(at: fileLocation)
	}

	/// Updates an existing item in the vault.
	func updateItem(item: SecureVaultItem) throws {

		// Delete the existing item.
		try self.deleteItem(item: item)

		// Write out the updated version.
		try self.addItem(item: item)
	}

	/// Closes the vault by clearing any data we have that is associated with it.
	func close() {
		self.vaultItems = []
		self.vaultDirUrl = URL(string: "")
		self.vaultMasterFileUrl = URL(string: "")
		self.vaultItemsDirUrl = URL(string: "")
		self.masterKey = nil
	}
}
