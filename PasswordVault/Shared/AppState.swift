//
//  AppState.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/17/21.
//

import Foundation

class AppState : ObservableObject {
	static let shared = AppState()

	private var vault: Vault = Vault()

	/// Returns true if a vault exists (spexcifically the vault index file) at the location stored in the user preferences.
	func vaultExists() -> Bool {
		let location = Preferences.vaultLocation()
		if location != nil {
			let fileManager = FileManager.default
			return fileManager.fileExists(atPath: location!)
		}
		return false
	}

	/// Creates a vault at the specified location.
	func createVault(vaultLocation: String, password: String) -> Bool {
		return vault.create(location: vaultLocation, key: password)
	}
	
	/// Returns true if we should open the vault, based on the supplied credentials; false otherwise.
	func validLogin(password: String) -> Bool {
		return false
	}
}
