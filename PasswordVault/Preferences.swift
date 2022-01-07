//
//  Preferences.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import Foundation

class Preferences {
	static func vaultLocation() -> String? {
		let mydefaults: UserDefaults = UserDefaults.standard
		return mydefaults.string(forKey: "Vault Location")
	}

	static func setVaultLocation(location: String) {
		let mydefaults: UserDefaults = UserDefaults.standard
		mydefaults.set(location, forKey: "Vault Location")
	}
}
