//
//  ContentView.swift
//  Shared
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

struct VaultView: View {
    var body: some View {
		List(0..<5) { item in
			Image(systemName: "note")
			VStack(alignment: .leading) {
				Text("Login")
				Text("Some Website")
					.font(.subheadline)
			}
		}
	}
}

struct VaultView_Previews: PreviewProvider {
    static var previews: some View {
		VaultView()
    }
}
