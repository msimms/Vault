//
//  Vault.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import Foundation

class Vault {
	@Published var vaultItems: [VaultItem] = []

	var vaultDirUrl: URL? // Complete path to the directory containing the vault
	var masterKey: String?

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
		let vaultFileUrl = self.vaultDirUrl?.appendingPathComponent("vault.json")

		// Does anything exist at the vault file's path?
		if !fileManager.fileExists(atPath: vaultFileUrl!.path) {
			do {
				try fileManager.createDirectory(atPath: self.vaultDirUrl!.path, withIntermediateDirectories: true, attributes: nil)

				// Create the vault's main file.
				if (fileManager.createFile(atPath: vaultFileUrl!.absoluteString, contents: nil, attributes: nil)) {
					
					// Bcrypt the key.
				}
			} catch {
				print(error.localizedDescription)
			}
		}
		return false
	}

	func open(location: String, key: String) -> Bool {
		return false
	}

	func readItems() -> Bool {
		let fileManager = FileManager.default
		let vaultFileUrl = self.vaultDirUrl?.appendingPathComponent("vault.json")

		// Does anything exist at the vault file's path?
		if fileManager.fileExists(atPath: vaultFileUrl!.path) {
		}
		return false
	}

	func close() -> Bool {
		self.vaultDirUrl = URL(string: "")
		self.masterKey = ""
		return true
	}
}
