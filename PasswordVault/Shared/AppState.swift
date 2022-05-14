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
import Foundation

class AppState : ObservableObject {
	static let shared = AppState()

	private var vault: Vault = Vault()
	@ObservedObject var viewModel = VaultDisplayState.shared
	@Published var vaultItems: Array<SecureVaultItem> = []

	init() {
		self.updateState()
	}

	/// Returns true if a vault exists (specifically the vault index file) at the location stored in the user preferences.
	func vaultExists() -> Bool {
		let vaultLocation = Preferences.vaultLocation()
		guard let unwrappedLocation = vaultLocation else { return false }
		return vault.exists(location: unwrappedLocation);
	}

	/// Returns true if a vault is open, i.e. unlocked.
	func vaultIsOpen() -> Bool {
		return vault.isOpen();
	}

	/// Creates a vault at the specified location.
	func createVault(vaultLocation: String, password: String) -> Bool {
		do {
			try vault.create(location: vaultLocation, key: password)
			Preferences.setVaultLocation(location: vaultLocation)
			self.updateState()
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
			try self.vaultItems = vault.readItems(location: unwrappedLocation)
			self.updateState()
			return true
		} catch let error as NSError {
			print("Error: Failed to read: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return false
	}

	/// Adds a new item to the vault.
	func addItemToVault(item: SecureVaultItem) -> Bool {
		do {
			let vaultLocation = Preferences.vaultLocation()
			guard let unwrappedLocation = vaultLocation else { return false }
			try vault.addItem(location: unwrappedLocation, item: item)
			try self.vaultItems = vault.readItems(location: unwrappedLocation)
		} catch let error as NSError {
			print("Error: Failed to write: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return true
	}

	/// Adds a new item to the vault.
	func updateVaultItem(item: SecureVaultItem) -> Bool {
		do {
			let vaultLocation = Preferences.vaultLocation()
			guard let unwrappedLocation = vaultLocation else { return false }
			try vault.updateItem(location: unwrappedLocation, item: item)
			try self.vaultItems = vault.readItems(location: unwrappedLocation)
		} catch let error as NSError {
			print("Error: Failed to update: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return true
	}

	/// Removes an item from the vault.
	func deleteItemFromVault(item: SecureVaultItem) -> Bool {
		do {
			let vaultLocation = Preferences.vaultLocation()
			guard let unwrappedLocation = vaultLocation else { return false }
			try vault.deleteItem(location: unwrappedLocation, item: item)
			try self.vaultItems = vault.readItems(location: unwrappedLocation)
		} catch let error as NSError {
			print("Error: Failed to delete: \n\(error)")
		} catch {
			print(error.localizedDescription)
		}
		return true
	}

	/// Securely closes the vault.
	func closeVault() -> Bool {
		return vault.close()
	}

	/// Returns true if we should open the vault, based on the supplied credentials; false otherwise.
	func validLogin(password: String) -> Bool {
		return false
	}
	
	func updateState() {
		if self.vaultExists() {
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
	}
}
