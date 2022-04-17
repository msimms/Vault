//
//  Login.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/13/21.
//

import Foundation

class VaultItem: Codable, Identifiable {
	enum CodingKeys: CodingKey {
		case id
		case note
		case vaultVersion
	}
	
	var id = UUID()
	var note: String
	var vaultVersion: UInt8

	/// Creates the file for the vault item.
	func create(location: String, key: String) -> Bool {

		var result = false

		// Sanity check the parameters.
		if key.count == 0 {
			return false
		}
		
		return result
	}
}
