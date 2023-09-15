//
//  AppView.swift
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

/// This is the first view that is shown to the user.
struct AppView: View {
	@ObservedObject var viewModel = VaultDisplayState.shared
	@State var pushed: Bool = true

	var body: some View {
		
		NavigationStack {
			
			// If we can't find a vault then ask the user to create one.
			// If one exists then prompt the user to open it.
			// If one exists and is open/unlocked then display it.
			
			VStack(alignment: .center) {
				Button {
					self.pushed = true
				} label: {
					Text(self.viewModel.createButtonText())
				}
				.padding()
				.background(Color.gray)
				.foregroundColor(.white)
				.cornerRadius(40)
				.frame(width: 160)
				.buttonStyle(PlainButtonStyle())
			}
			.navigationTitle("Navigation")
			.navigationDestination(isPresented: self.$pushed) {
				self.viewModel.createView(isPushed: self.$pushed)
			}
		}
		.onAppear() {
			AppState.shared.updateState()
		}
#if os(macOS)
		.background(
			Image("Background")
				.resizable()
				.edgesIgnoringSafeArea(.all)
				.aspectRatio(contentMode: .fill)
				.opacity(0.9)
		)
#endif
	}
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
