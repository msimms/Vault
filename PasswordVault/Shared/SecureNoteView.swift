//
//  SecureNoteView.swift
//  Created by Michael Simms on 4/22/22.
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

/// Displays a login item from the vault.
struct SecureNoteView: View {
	@ObservedObject var appModel = AppState.shared
	@Binding var isPushed : Bool
	@State var item : SecureNoteItem
	@State var isNewItem = true

	var body: some View {

		VStack(alignment: .leading) {

			Group() {
				Text("Note")
					.fontWeight(.heavy)
					.font(.system(size: 32))
					.multilineTextAlignment(.center)
				Divider()
				Text("Title")
					.fontWeight(.heavy)
				TextField("Title", text: $item.heading)
				VStack(alignment: .leading) {
					TextEditor(text: $item.note)
				}
				//TagsView(isPushed: $isPushed, tags: item.tags)
				LastModifiedView(isNewItem: isNewItem, timestamp: item.lastModifiedTime)
			}

			Spacer()
			ItemButtonView(isPushed: self.$isPushed, item: self.item, isNewItem: self.isNewItem)
		}
		.padding(10)
	}

	func title() -> String {
		return item.title()
	}
	func subtitle() -> String {
		return ""
	}
}
