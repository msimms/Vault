//
//  SecureLicenseView.swift
//  Created by Michael Simms on 9/14/23.
//

// MIT License
//
// Copyright (c) 2023 Mike Simms
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
struct SecureLicenseView: View {
	@State var item: SecureLicenseItem
	@State var isNewItem: Bool = true
	@State var isReadOnly: Bool = false

	var body: some View {
		
		VStack(alignment: .leading) {
			ScrollView() {
				HStack() {
					Image(systemName: icon(item: self.item))
						.imageScale(.large)
					Text("License")
						.fontWeight(.heavy)
						.font(.system(size: 32))
						.multilineTextAlignment(.center)
				}
				Divider()
				VStack(alignment: .leading) {
					Text("Title")
						.fontWeight(.heavy)
					TextField("Title", text: self.$item.title)
						.disabled(self.isReadOnly)
					TextField("License Holder", text: self.$item.licenseHolder)
						.disabled(self.isReadOnly)
					TextField("License Key", text: self.$item.licenseKey)
						.disabled(self.isReadOnly)
					Text("Notes")
						.fontWeight(.heavy)
					TextEditor(text: self.$item.note)
						.disabled(self.isReadOnly)
						.frame(height: 200)
					AttachFilesView(isReadOnly: self.$isReadOnly, item: self.item)
					TagsView(isReadOnly: self.$isReadOnly, tags: self.$item.tags)
					LastModifiedView(isNewItem: isNewItem, timestamp: self.item.lastModifiedTime)
				}				
				Spacer()
				ItemButtonView(isReadOnly: self.$isReadOnly, item: self.item, isNewItem: self.isNewItem)
			}
			.padding(10)
		}
	}
}
