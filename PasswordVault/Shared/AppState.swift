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

class AppState : ObservableObject {

	/// Singleton instance
	static let shared = AppState()

	var vault: Vault = Vault()
	@ObservedObject var viewModel = VaultDisplayState.shared

	/// Constructor
	private init() {
		self.updateState()
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

	/// Opens the vault by opening the master vault file and decoding it.
	func openVault(password: String) -> Bool {
		do {
			let baseLocation = Preferences.baseVaultsLocation()
			let defaultVaultName = Preferences.defaultVaultName()

			guard let unwrappedLocation = baseLocation else { return false }
			guard let unwrappedDefaultVaultName = defaultVaultName else { return false }

			try self.vault.open(vaultLocation: unwrappedLocation, name: unwrappedDefaultVaultName, key: password)
			try self.vault.readItems()

			self.updateState()
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
				self.viewModel.update(vaultState: VaultState.VaultNotCreated)
			}
		} catch let error as NSError {
			print("Error: Failed to update state: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
	}
}
