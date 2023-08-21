//
//  ContentView.swift
//  Created by Michael Simms on 8/18/23.
//

import SwiftUI

struct ContentView: View {
	@State private var password: String = ""
	@State private var showingVaultOpenFailedAlert: Bool = false
	@State private var selectedVault: String? = Preferences.defaultVaultName()
	
	func vaultIsSelected() -> Bool {
		return self.selectedVault != nil && self.selectedVault!.count > 0
	}
	
	func openVault() {
		if AppState.shared.openVault(password: self.password) {
			self.showingVaultOpenFailedAlert = false
		}
		else {
			self.showingVaultOpenFailedAlert = true
		}
	}

	var body: some View {
		VStack {
			// Allow the user to toggle between multiple vaults
			Label("Vault Selection", systemImage: "lock.circle")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
