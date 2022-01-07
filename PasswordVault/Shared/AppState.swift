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

	func vaultExists() -> Bool {
		let location = Preferences.vaultLocation()
		if location != nil {
			let fileManager = FileManager.default
			return fileManager.fileExists(atPath: location!)
		}
		return false
	}

	func createVault(vaultLocation: String, password: String) -> Bool {
		return vault.create(location: vaultLocation, key: password)
	}
}
