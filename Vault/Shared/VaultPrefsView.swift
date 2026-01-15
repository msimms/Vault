//
//  VaultPrefsView.swift
//  Created by Michael Simms on 2/27/24.
//

//	MIT License
//
//  Copyright (c) 2023 Michael J Simms. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import SwiftUI

struct VaultPrefsView: View {
	@Environment(\.dismiss) var dismiss
	@State private var biometricAuthEnabled: Bool = AppState.shared.isBiometricIdEnabledForCurrentVault()
	@State private var changePassword1: String = ""
	@State private var changePassword2: String = ""
	@State private var recoveryPassword1: String = ""
	@State private var recoveryPassword2: String = ""
	@State private var isShowingPasswordsDoNotMatch: Bool = false
	@State private var isShowingBiometricToggleError: Bool = false

	var body: some View {
		VStack(alignment: .center) {

			Group() {
				Text("Change the Vault Password")
					.font(.system(size: 24))
					.bold()
					.padding(10)
				
				// Password
				Label("Password", systemImage: "lock.circle")
				PasswordView(password: self.$changePassword1)
				
				// Password Confirmation
				Label("Confirm Password", systemImage: "lock.circle")
				PasswordView(password: self.$changePassword2)

				Button("Change") {
					if self.changePassword1 == self.changePassword2 {
						AppState.shared.changeCurrentVaultPassword(newPassword: self.changePassword1)
					}
					else {
						self.isShowingPasswordsDoNotMatch = true
					}
				}
			}

			if AppState.shared.isBiometricIdAvailable() {
				HStack(alignment: .top) {
					Toggle(isOn: self.$biometricAuthEnabled) {
						Text("Enable Biometric Authorization")
							.font(.system(size: 24))
							.bold()
					}
					.tint(.blue)
					.onChange(of: self.biometricAuthEnabled) {
						if self.biometricAuthEnabled {
							self.isShowingBiometricToggleError = AppState.shared.isBiometricIdEnabledForCurrentVault()
						}
						self.isShowingBiometricToggleError = AppState.shared.disableBiometricAuthenticationForCurrentVault()
					}
					.padding()
				}
			}
		}
	}
}
