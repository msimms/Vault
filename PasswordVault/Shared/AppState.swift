//
//  AppState.swift
//  Created by Michael Simms on 12/17/21.
//

// MIT License
//
// Copyright (c) 2022 Mike Simms
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI
import LocalAuthentication

class AppState {

	/// Singleton instance
	static let shared = AppState()

	@ObservedObject var vault: Vault = Vault()
	var viewModel = VaultDisplayState.shared
	var hasOpenedAVault: Bool = false // This breaks the potentially infinite loop of automatically re-opening a vault right after it was closed
	var setupBiometricAuth: Bool = false
	let laContext = LAContext()

	/// Constructor
	private init() {
		self.updateState()
	}

	/// Returns True if biometric authentication is available on this device.
	func isBiometricIdAvailable() -> Bool {
		var error: NSError?

		guard self.laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
			return false
		}
		return true
	}

	/// Returns True if biometric authentication is a enabled for a particular vault.
	func isBiometricIdEnabledForVault(vaultName: String) -> Bool {
		let keyName = self.keychainKeyForVaultName(vaultName: vaultName)
		let keychain = Keychain()
		let password = keychain.load(keyName: keyName)

		guard password != nil else {
			return false
		}
		return password!.count > 0
	}

	/// Returns the type of biometric authentication that is used on this device (touch, face, etc.)
	func biometricAuthType() -> LABiometryType {
		return self.laContext.biometryType
	}

	/// This method marks the vault for biometric setup.
	func flagVaultForBiometricAuthSetup(vaultName: String) {
		self.setupBiometricAuth = true
	}
	
	/// This method checks to see if the vault is marked for biometric auth setup.
	/// If it is, the password will be saved to the keychain when the vault is opened.
	func isVaultFlaggedForBiometricAuthSetup(vaultName: String) -> Bool {
		return self.setupBiometricAuth
	}
	
	func keychainKeyForVaultName(vaultName: String) -> String {
		return "Vault_" + vaultName
	}
	
	func configureBiometricAuthForVault(vaultName: String, password: String) throws {
		// Is biometric auth already setup?
		if self.isBiometricIdEnabledForVault(vaultName: vaultName) {
			return
		}
		
		// Encode the password as a data object so we can store it in the keychain.
		let keychain = Keychain()
		let passwordData = password.data(using: .utf8)
		guard passwordData != nil else {
			throw VaultException.runtimeError("Password must be UTF8. Unable to setup biometric authentication.")
		}

		// Store the password in the keychain.
		let keyName = self.keychainKeyForVaultName(vaultName: vaultName)
		if keychain.save(keyName: keyName, data: passwordData!) == false {
			throw VaultException.runtimeError("Keychain error. Unable to setup biometric authentication.")
		}
	}

	func performBiometricAuthForVault(baseLocation: String, vaultName: String) {
		var error: NSError?

		// Make sure biometric auth is available.
		guard self.laContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
			return
		}
		
		Task {
			do {
				// This does whatever the biometric authentication is (fingerprint scan, face scan, etc.).
				// Throws upon failure.
				try await self.laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Open the Vault")

				// Get the password from the keychain.
				let keyName = self.keychainKeyForVaultName(vaultName: vaultName)
				let keychain = Keychain()
				let passwordData = keychain.load(keyName: keyName)
				guard passwordData != nil else {
					return
				}

				// Open the vault.
				let password = String(decoding: passwordData!, as: UTF8.self)
				try self.openVaultInner(baseLocation: baseLocation, vaultName: vaultName, password: password)
			} catch let error {
				print(error.localizedDescription)
			}
		}
	}
	
	/// Returns true if a vault exists (specifically the vault index file) at the location stored in the user preferences.
	func defaultVaultExists() throws -> Bool {
		let baseLocation = Preferences.baseVaultsLocation()
		let defaultVaultName = Preferences.defaultVaultName()

		guard let unwrappedLocation = baseLocation else { return false }
		guard let unwrappedDefaultVaultName = defaultVaultName else { return false }

		return try self.vault.exists(location: unwrappedLocation, name: unwrappedDefaultVaultName);
	}

	/// Returns the names of all vaults found at the base vaults location.
	func listVaults() -> Array<String> {

		do {
			let baseLocation = Preferences.baseVaultsLocation()

			if baseLocation != nil {
				let baseUrl = try self.vault.convertVaultLocationToUrl(location: baseLocation!)
				let dirListing = try FileManager.default.contentsOfDirectory(at: baseUrl, includingPropertiesForKeys: nil)
				var vaults: Array<String> = []
				
				for listing in dirListing {
					let vaultName = listing.lastPathComponent
					if !vaultName.starts(with: ".") {
						vaults.append(vaultName)
					}
				}
				return vaults
			}
		} catch let error as NSError {
			print("Error: Failed to create the vault: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return []
	}

	/// Returns true if a vault is open, i.e. unlocked.
	func vaultIsOpen() -> Bool {
		return self.vault.isOpen();
	}

	/// Creates a vault at the specified location.
	func createVault(vaultLocation: String, name: String, password: String) -> Bool {
		do {
			try self.vault.create(location: vaultLocation, name: name, key: password)

			Preferences.setBaseVaultsLocation(location: vaultLocation)
			Preferences.setDefaultVaultName(name: name)

			self.updateState()
			return true
		} catch let error as NSError {
			print("Error: Failed to create the vault: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	func openVaultInner(baseLocation: String, vaultName: String, password: String) throws {
		// Open and read the vault.
		try self.vault.open(vaultLocation: baseLocation, name: vaultName, key: password)
		try self.vault.readItems()
		self.hasOpenedAVault = true
		
		// Vault is open, we can now save the password to the keychain if the user wants to setup biometric authentication.
		if self.isVaultFlaggedForBiometricAuthSetup(vaultName: vaultName) {
			try self.configureBiometricAuthForVault(vaultName: vaultName, password: password)
		}
		self.updateState()
	}

	/// Opens the vault by opening the master vault file and decoding it.
	func openVault(password: String) -> Bool {
		do {
			let baseLocation = Preferences.baseVaultsLocation()
			let defaultVaultName = Preferences.defaultVaultName()

			guard let unwrappedLocation = baseLocation else { return false }
			guard let unwrappedDefaultVaultName = defaultVaultName else { return false }

			// If this vault is configured for biometric authentication then do that.
			if self.isBiometricIdEnabledForVault(vaultName: unwrappedDefaultVaultName) {
				self.performBiometricAuthForVault(baseLocation: unwrappedLocation, vaultName: unwrappedDefaultVaultName)
			}
			else {
				try self.openVaultInner(baseLocation: unwrappedLocation, vaultName: unwrappedDefaultVaultName, password: password)
			}
			return true
		} catch let error as NSError {
			print("Error: Failed to open the vault: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Adds a new item to the vault.
	func addItemToVault(item: SecureVaultItem) -> Bool {
		do {
			item.updateLastModifiedTime()
			try self.vault.addItem(item: item)
			try self.vault.readItems()
			return true
		} catch let error as NSError {
			print("Error: Failed to add an item to the vault: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Adds a new item to the vault.
	func updateVaultItem(item: SecureVaultItem) -> Bool {
		do {
			item.updateLastModifiedTime()
			try self.vault.updateItem(item: item)
			try self.vault.readItems()
			return true
		} catch let error as NSError {
			print("Error: Failed to update the vault: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Removes an item from the vault.
	func deleteItemFromVault(item: SecureVaultItem) -> Bool {
		do {
			try self.vault.deleteItem(item: item)
			try self.vault.readItems()
			return true
		} catch let error as NSError {
			print("Error: Failed to delete a vault item: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Securely closes the vault.
	func closeVault() {
		self.vault.close()
		self.updateState()
	}

	/// Removes the entire vault.
	func deleteVault() -> Bool {
		do {
			try self.vault.delete()
			return true
		} catch let error as NSError {
			print("Error: Failed to delete the vault: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Given a URL, parses the file and attempts to import it, appending the data to the current vault.
	func importVaultFromUrl(from: URL) -> Bool {
		do {
			let importer = Importer()
			try importer.importFrom(location: from, vault: self.vault)
			try self.vault.readItems()
			return true
		} catch {
			print(error.localizedDescription)
		}
		
		// If we throw, we should still re-read the vault items - because we
		// may have been able to read some itms
		do {
			try self.vault.readItems()
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Exports the current vault to an (unencrypted) file.
	func exportVaultFromUrl(to: URL) -> Bool {
		let exporter = Exporter()
		exporter.exportToUrl(location: to, vault: self.vault)
		return false
	}

	func updateState() {
		do {
			if try self.defaultVaultExists() || self.listVaults().count > 0 {
				if self.vaultIsOpen() {
					self.viewModel.update(vaultState: VaultState.VaultOpen)
				}
				else {
					self.viewModel.update(vaultState: VaultState.VaultClosed)
				}
			}
			else {
				self.viewModel.update(vaultState: VaultState.CreateNewVault)
			}
		} catch let error as NSError {
			print("Error: Failed to update state: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
	}
}
