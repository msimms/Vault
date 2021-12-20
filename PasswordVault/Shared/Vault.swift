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

	func create(location: String, key: String) -> Bool {

		// Sanity check the parameters.
		if location.count == 0 {
			return false
		}
		if key.count == 0 {
			return false
		}

		// Make sure any existing vaults are closed.
		if !self.close() {
			return false
		}

		let fileManager = FileManager.default
		self.vaultDirUrl = URL(string: location)!
		let vaultFileUrl = self.vaultDirUrl?.appendingPathComponent(vaultFileName)

		// Does anything exist at the vault file's path?
		if !fileManager.fileExists(atPath: vaultFileUrl!.path) {
			do {
				try fileManager.createDirectory(atPath: self.vaultDirUrl!.path, withIntermediateDirectories: true, attributes: nil)

				// Create the vault's main file.
				if (fileManager.createFile(atPath: vaultFileUrl!.absoluteString, contents: nil, attributes: nil)) {

					// Bcrypt the user key.

					// Generate a random master key.

					// Encrypt the master key with the user key.
				}
			} catch {
				print(error.localizedDescription)
			}
		}
		return false
	}

	func open(location: String, key: String) -> Bool {
		let fileManager = FileManager.default
		let vaultFileUrl = self.vaultDirUrl?.appendingPathComponent(vaultFileName)

		// Does anything exist at the vault file's path?
		if fileManager.fileExists(atPath: vaultFileUrl!.path) {
			
			// Read the index file.
			let data = try? Data(contentsOf: vaultFileUrl!)
			let index = try? JSONDecoder().decode(VaultIndex.self, from: data!)
			self.index = index!

			// Validate the provided key.

			// Decrypt the master key.
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

	func close() -> Bool {
		self.vaultDirUrl = URL(string: "")
		self.masterKey = ""
		return true
	}
}
