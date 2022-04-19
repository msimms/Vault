//
//  AppView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

enum VaultState {
	case VaultNotCreated
	case VaultClosed
	case VaultOpen
}

/// Used to indicate which state the vault should be displayed.
final class VaultDisplayState: ObservableObject {
	static let shared = VaultDisplayState()
	@Published var vaultState: VaultState = VaultState.VaultNotCreated

	func update(vaultState: VaultState) {
		self.vaultState = vaultState
	}

	func stateText() -> String {
		switch (self.vaultState) {
		case VaultState.VaultNotCreated:
			return "Create Vault"
		case VaultState.VaultClosed:
			return "Open Vault"
		case VaultState.VaultOpen:
			return "Close Vault"
		}
	}

	@ViewBuilder
	func stateView(isPushed: Binding<Bool>) -> some View {
		switch (self.vaultState) {
		case VaultState.VaultNotCreated:
			NewVaultView(isPushed: isPushed)
		case VaultState.VaultClosed:
			LockView(isPushed: isPushed)
		case VaultState.VaultOpen:
			VaultView(isPushed: isPushed)
		}
	}
}

/// This is the first view that is shown to the user.
struct AppView: View {
	@ObservedObject var appModel = AppState.shared
	@ObservedObject var viewModel = VaultDisplayState.shared
	@State var pushed : Bool = false

	var body: some View {
		NavigationView {

			// If we can't find a vault then ask the user to create one.
			// If one exists then prompt the user to open it.
			// If one exists and is open/unlocked then display it.

			VStack {
				NavigationLink(
					destination: viewModel.stateView(isPushed: self.$pushed),
					isActive: self.$pushed
				) {
					EmptyView()
				}
				.hidden()
				Button(viewModel.stateText()) {
					self.pushed = true
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

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
