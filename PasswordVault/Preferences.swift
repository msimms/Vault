//
//  Preferences.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import Foundation

class Preferences {
	func vaultLocation() -> String {
		return "";
	}

	func setVaultLocation(location: String) {
		let mydefaults: UserDefaults = UserDefaults.standard
		mydefaults.set(location, forKey: "Vault Location")
	}
}
