//
//  AppView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

/// This is the first view that is shown to the user.
struct AppView: View {
	@ObservedObject var appModel = AppState.shared
	@State var pushed : Bool = false

	var body: some View {
		NavigationView {
			
			// If we can't find a vault then ask the user to create one.
			// If one exists then prompt the user to open it.
			// If one exists and is open/unlocked then display it.
			if appModel.vaultExists() {
				if appModel.vaultIsOpen() {
					VStack {
						VaultView(isPushed: self.$pushed)
					}
				}
				else {
					VStack {
						NavigationLink(
							destination: LockView(isPushed: self.$pushed),
							isActive: self.$pushed
						) {
							EmptyView()
						}
						.hidden()
						Button("Open Vault") {
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
			else {
				VStack {
					NavigationLink(
						destination: NewVaultView(isPushed: self.$pushed),
						isActive: self.$pushed
					) { EmptyView() }
					.hidden()
					Button("Create Vault") {
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
		.onAppear {
		}
	}
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
