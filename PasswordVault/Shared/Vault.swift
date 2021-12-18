//
//  Vault.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import Foundation

class Vault {
	@Published var vaultItems: [VaultItem] = []

	var vaultLocation: String?
	var masterKey: String?

	func create(location: String, key: String) -> Bool {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let documentsDirectory = paths[0]
		let docURL = URL(string: documentsDirectory)!
		let vaultPath = docURL.appendingPathComponent(location)
		let vaultFile = vaultPath.appendingPathComponent("vault.json")

		if !FileManager.default.fileExists(atPath: vaultPath.path) {
			do {
				try FileManager.default.createDirectory(atPath: vaultPath.path, withIntermediateDirectories: true, attributes: nil)

				if (FileManager.default.createFile(atPath: vaultFile.absoluteString, contents: nil, attributes: nil)) {
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
		let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

		do {
			let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
		} catch {
		}
		return false
	}

	func close() -> Bool {
		self.vaultLocation = ""
		self.masterKey = ""
		return false
	}
}
