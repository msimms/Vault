//
//  LockView.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

struct LockView: View {
    var body: some View {
		NavigationView {
			VStack {
				NavigationLink(destination: VaultView()) {
					Image(systemName: "lock.circle")
						.font(.title)
					Text("Login")
						.fontWeight(.semibold)
						.font(.title)
				}
				.padding()
				.foregroundColor(.white)
				.background(Color.blue)
				.cornerRadius(40)
			}
		}
	}
}

struct LockView_Previews: PreviewProvider {
    static var previews: some View {
        LockView()
    }
}
