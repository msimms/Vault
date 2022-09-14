//
//  LockView.swift
//  Created by Michael Simms on 12/12/21.
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

/// Prompts the user for the credentials to open the vault.
struct LockView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State private var password: String = ""
	@State private var showingVaultOpenFailedAlert = false
	@State private var showingNoVaultSelectedAlert = false
	@State private var showPassword = false
	@State private var isBusy = false
	@State private var selectedVault: String? = Preferences.defaultVaultName()

	func vaultIsSelected() -> Bool {
		return self.selectedVault != nil && self.selectedVault!.count > 0
	}

	func openVault() {
		if self.appModel.openVault(password: password) {
			self.isPushed = true
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
			ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
				Menu {
					let vaultNames = self.appModel.listVaults()
					ForEach(vaultNames, id: \.self) { name in
						Button(action: {
							selectedVault = name
							Preferences.setDefaultVaultName(name: name)
						}) {
							Label(name, systemImage: "lock")
								.labelStyle(.titleAndIcon)
						}
					}
				} label: {
					if vaultIsSelected() {
						Text("\(selectedVault!)")
					}
					else {
						Text("Choose Vault")
					}
				}
				.padding()
			})

			// Password
			Label("Password", systemImage: "lock.circle")
			ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
				if showPassword {
					TextField("Password", text: $password)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding()
						.onSubmit {
							self.openVault()
						}
				}
				else {
					SecureField("Password", text: $password)
						.textFieldStyle(RoundedBorderTextFieldStyle())
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
				if vaultIsSelected() {
					self.isBusy = true
					openVault()
					self.isBusy = false
				}
				else {
					self.showingNoVaultSelectedAlert = true
				}
			} label: {
				Label("Open", systemImage: "lock")
					.padding()
			}
			.alert("A vault was not specified!", isPresented: $showingNoVaultSelectedAlert) {
				Button("OK", role: .cancel) { }
			}
			.alert("Failed to open the vault!", isPresented: $showingVaultOpenFailedAlert) {
				Button("OK", role: .cancel) { }
			}
			.padding()
			.foregroundColor(.white)
			.background(Color.blue)
			.cornerRadius(40)
			.padding()
#if !os(macOS)
			.navigationBarBackButtonHidden(true)
#endif
			.sheet(isPresented: $isBusy) {
				ProgressView("Loading...")
			}
		}
	}
}
