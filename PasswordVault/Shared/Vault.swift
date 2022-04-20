//
//  Vault.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import Foundation
import CryptoKit

/// Encapsulates the data stored in the vault's master file
struct VaultIndex: Codable {
	var vaultVersion: UInt8
	var encryptedMasterKey: String
}

class Vault {
	@Published var vaultItems: [VaultItem] = []

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

	func readItems() -> Array<LoginItem> {
		let fileManager = FileManager.default

		do {
			let dirListing = try fileManager.contentsOfDirectory(at: self.vaultDirUrl!, includingPropertiesForKeys: nil)
			for listing in dirListing {
				print(listing)
			}
		}
		catch {
		}
		return []
	}

	/// Closes the vault by clearing any data we have that is associated with it.
	func close() -> Bool {
		self.vaultDirUrl = URL(string: "")
		self.masterKey = ""
		return true
	}
}
