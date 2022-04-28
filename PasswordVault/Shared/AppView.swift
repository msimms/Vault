//
//  AppView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
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

/// Used to indicate the state of the vault (open, closed, etc.) so the view can be rendered correctly..
enum VaultState {
	case VaultNotCreated
	case VaultClosed
	case VaultOpen
}
final class VaultDisplayState: ObservableObject {
	static let shared = VaultDisplayState()
	@Published var vaultState: VaultState = VaultState.VaultNotCreated

	func update(vaultState: VaultState) {
		self.vaultState = vaultState
	}

	func createButtonText() -> String {
		switch (self.vaultState) {
		case VaultState.VaultNotCreated: return "Create Vault"
		case VaultState.VaultClosed: return "Open Vault"
		case VaultState.VaultOpen: return "View Vault"
		}
	}

	@ViewBuilder
	func createView(isPushed: Binding<Bool>) -> some View {
		switch (self.vaultState) {
		case VaultState.VaultNotCreated: NewVaultView(isPushed: isPushed)
		case VaultState.VaultClosed: LockView(isPushed: isPushed)
		case VaultState.VaultOpen: OpenVaultView(isPushed: isPushed)
		}
	}
}

/// This is the first view that is shown to the user.
struct AppView: View {
	@ObservedObject var appModel = AppState.shared
	@ObservedObject var viewModel = VaultDisplayState.shared
	@State var pushed : Bool = true

	var body: some View {
		NavigationView {

			// If we can't find a vault then ask the user to create one.
			// If one exists then prompt the user to open it.
			// If one exists and is open/unlocked then display it.

			VStack {
				NavigationLink(
					destination: viewModel.createView(isPushed: self.$pushed),
					isActive: self.$pushed
				) {
					EmptyView()
				}
				.hidden()
				Button(viewModel.createButtonText()) {
					self.pushed = true
				}
				.padding()
				.background(Color.blue)
				.foregroundColor(.white)
				.cornerRadius(40)
				.padding()
				.frame(width: 160)
			}
		}
	}
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
