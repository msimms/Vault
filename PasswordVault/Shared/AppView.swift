//
//  AppView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/18/21.
//

import SwiftUI

struct AppView: View {
	@ObservedObject var appModel = AppState.shared

	var body: some View {
		if appModel.vaultExists() {
			LockView()
		}
		else {
			NewVaultView()
		}
	}
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
