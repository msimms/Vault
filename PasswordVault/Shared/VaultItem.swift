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
}
