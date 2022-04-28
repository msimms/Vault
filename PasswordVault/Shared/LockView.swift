//
//  LockView.swift
//  PasswordVault
//
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
	@State var pushed : Bool = false
	@State private var password: String = ""
	@State private var showingVaultOpenFailedAlert = false

	var body: some View {
		NavigationView {
			VStack {
				// Password
				Label("Password", systemImage: "lock.circle")
				SecureField("", text: $password)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()

				// Opens the vault
				Button {

					// Open the vault.
					if self.appModel.openVault(password: self.password) {

						// Show the vault by popping to the root view controller.
						self.isPushed = false
					}
					else {
						self.showingVaultOpenFailedAlert = true
					}
				} label: {
					Label("Open", systemImage: "lock")
				}
				.alert("Failed to open the vault!", isPresented: $showingVaultOpenFailedAlert) {
					Button("OK", role: .cancel) { }
				}
				.padding()
				.background(Color.blue)
				.foregroundColor(.white)
				.cornerRadius(40)
				.padding()
			}
		}
	}
}
