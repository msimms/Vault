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
		let vaultLocation = Preferences.vaultLocation()
		guard let unwrappedLocation = vaultLocation else { return false }
		return vault.vaultExists(location: unwrappedLocation);
	}

	/// Creates a vault at the specified location.
	func createVault(vaultLocation: String, password: String) -> Bool {
		do {
			try vault.create(location: vaultLocation, key: password)
			Preferences.setVaultLocation(location: vaultLocation)
			return true
		} catch let error as NSError {
			print("Error: Failed to write: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Opens the vault by opening the master vault file and decoding it.
	func openVault(password: String) -> Bool {
		do {
			let vaultLocation = Preferences.vaultLocation()
			guard let unwrappedLocation = vaultLocation else { return false }
			try vault.open(location: unwrappedLocation, key: password)
			return true
		} catch let error as NSError {
			print("Error: Failed to write: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Returns true if we should open the vault, based on the supplied credentials; false otherwise.
	func validLogin(password: String) -> Bool {
		return false
	}
}
