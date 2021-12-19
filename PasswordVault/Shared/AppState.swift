//
//  AppState.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/17/21.
//

import Foundation

class AppState : ObservableObject {
	static let shared = AppState()

	var vault: Vault = Vault()

	func vaultExists() -> Bool {
		return false
	}
}
