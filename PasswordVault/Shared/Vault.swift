//
//  Vault.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import Foundation

class VaultIndex: Codable, Identifiable {
	enum CodingKeys: CodingKey {
		case encocdedMaster
		case vaultVersion
	}
	
	var id = UUID()
	var encocdedMaster: String
	var vaultVersion: UInt8
}

class Vault {
	@Published var vaultItems: [VaultItem] = []

	let vaultFileName = "vault.json"
	var vaultDirUrl: URL? // Complete path to the directory containing the vault
	var masterKey: String?
	var index: VaultIndex?

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

	func encodeBytes(inData: Data) -> String? {
		return inData.base64EncodedString()
	}

	/// Creates the vault. If the location is not provided then the vault is created on the user's iCloud drive.
	func create(location: String, key: String) -> Bool {

		var result = false

		// Sanity check the parameters.
		if key.count == 0 {
			return false
		}

		// Make sure any existing vaults are closed.
		if !self.close() {
			return false
		}

		do {
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
			let vaultMasterFileUrl = self.vaultDirUrl?.appendingPathComponent(vaultFileName)

			// Does anything exist at the vault master file's path?
			if !FileManager.default.fileExists(atPath: vaultMasterFileUrl!.path) {

				// Create the parent directory.
				let path = self.vaultDirUrl!.path
				try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)

				// Create the vault's master file.
				let masterFilePath = vaultMasterFileUrl!.absoluteString
				if (FileManager.default.createFile(atPath: masterFilePath, contents: nil, attributes: nil)) {

					// Generate a random master key.
					let masterKey = self.generateMasterKey()
					guard let unwrappedMasterKey = masterKey else { return result }

					// Encrypt the master key with the user key.
					let encryptedMasterKey = try aesCBCEncrypt(data: unwrappedMasterKey, keyData: Data(key.utf8))

					// Base 64 encode the master key for writing.

					// Encode everything as JSON.
					let encoder = JSONEncoder()

					// Write it out.

					result = true
				}
				else {
					print("Failed to create the vault's master file.")
				}
			}
		} catch let error as NSError {
			print("Error: Failed to write: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return result
	}

	/// Opens the vault by opening the master vault file and decoding it.
	func open(location: String, key: String) -> Bool {
		let fileManager = FileManager.default
		let vaultFileUrl = self.vaultDirUrl?.appendingPathComponent(vaultFileName)

		// Does anything exist at the vault master file's path?
		if fileManager.fileExists(atPath: vaultFileUrl!.path) {
			
			// Read the master file.
			let data = try? Data(contentsOf: vaultFileUrl!)
			let index = try? JSONDecoder().decode(VaultIndex.self, from: data!)
			self.index = index!

			// Validate the provided key.

			// Decrypt the master key.
			
			return true
		}
		return false
	}

	func readItems() -> Bool {
		let fileManager = FileManager.default

		do {
			_ = try fileManager.contentsOfDirectory(at: self.vaultDirUrl!, includingPropertiesForKeys: nil)
		}
		catch {
		}
		return false
	}

	/// Closes the vault by clearing any data we have that is associated with it.
	func close() -> Bool {
		self.vaultDirUrl = URL(string: "")
		self.masterKey = ""
		return true
	}
}
