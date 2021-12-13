//
//  ContentView.swift
//  Shared
//
//  Created by Michael Simms on 12/12/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		HSplitView {
			VStack {
				List {
					Text("Hello, world!")
						.padding()
					Text("Hello, world!")
						.padding()
				}
			}
			VStack {
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
