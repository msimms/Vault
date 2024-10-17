//
//  ContentView.swift
//  Created by Michael Simms on 8/18/23.
//

import SwiftUI

struct ContentView: View {
	@State private var password: String = ""
	@State private var showingVaultOpenFailedAlert: Bool = false
	@State private var showPassword: Bool = false
	@State private var selectedVault: String? = Preferences.defaultVaultName()
	@State private var showingHealthStatusView: Bool = false

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
		NavigationStack() {
			VStack {
				let vaultNames = AppState.shared.listVaults()
				if vaultNames.count > 0 {
					
					// Allow the user to toggle between multiple vaults
					Label("Vault Selection", systemImage: "lock.circle")
					ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
						ForEach(vaultNames, id: \.self) { name in
							Button(action: {
								self.selectedVault = name
								Preferences.setDefaultVaultName(name: name)
							}) {
								Label(name, systemImage: "lock")
									.labelStyle(.titleAndIcon)
							}
						}
					})
					
					// Password
					Label("Password", systemImage: "lock.circle")
					ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
						if self.showPassword {
							TextField("Password", text: self.$password)
								.padding()
								.onSubmit {
									self.openVault()
								}
						}
						else {
							SecureField("Password", text: self.$password)
								.padding()
								.onSubmit {
									self.openVault()
								}
						}
						Button(action: { self.showPassword.toggle() }) {
							Image(systemName: "eye")
								.foregroundColor(.secondary)
						}
						.padding()
					})
					
					// Opens the vault
					Button {
						if self.vaultIsSelected() {
							self.openVault()
						}
					} label: {
						Label("Open", systemImage: "lock")
							.padding()
					}
					.alert("Failed to open the vault!", isPresented: self.$showingVaultOpenFailedAlert) {
						Button("OK", role: .cancel) { }
					}
					.foregroundColor(.white)
					.background(Color.blue)
					.cornerRadius(40)
					.padding()
				}
				else {
					Text("No vaults found.")
				}

				// Vault owner's health metrics
				Group() {
					Button(action: {
						self.showingHealthStatusView = true
					}) {
						Image(systemName: "heart")
							.resizable()
					}
					.navigationDestination(isPresented: self.$showingHealthStatusView) {
						HealthStatusView()
					}
					.frame(width: 32.0, height: 32.0)
					.buttonStyle(PlainButtonStyle())
					.padding(10)
				}
			}
			.padding()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
