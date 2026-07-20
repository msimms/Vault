//
//  SecurePassportView.swift
//  Created by Michael Simms on 7/19/26.
//


//	MIT License
//
//  Copyright (c) 2026 Michael J Simms. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import SwiftUI

/// Displays a login item from the vault.
struct SecurePassportView: View {
	@State var item: SecurePassportItem
	@State var isNewItem: Bool = true
	@State var isReadOnly: Bool = false

	var body: some View {

		VStack(alignment: .leading) {
			ScrollView() {
				HStack() {
					Image(systemName: iconForVaultItem(item: self.item))
						.imageScale(.large)
					Text("Passport")
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
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Name")
						.fontWeight(.heavy)
					TextField("Name", text: self.$item.name)
						.disabled(self.isReadOnly)
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Citizenship")
						.fontWeight(.heavy)
					TextField("Citizenship", text: self.$item.citizenship)
						.disabled(self.isReadOnly)
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Number")
						.fontWeight(.heavy)
					TextField("Number", text: self.$item.number)
						.disabled(self.isReadOnly)
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Date Of Birth")
						.fontWeight(.heavy)
					DatePicker("",
							selection: Binding<Date>(
								get: { self.item.dateOfBirth ?? Date() },
								set: { self.item.dateOfBirth = $0 }
							),
							displayedComponents: .date
						)
						.labelsHidden()
						.disabled(self.isReadOnly)
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Issued On")
						.fontWeight(.heavy)
					DatePicker("",
							selection: Binding<Date>(
								get: { self.item.issuedOn ?? Date() },
								set: { self.item.issuedOn = $0 }
							),
							displayedComponents: .date
						)
						.labelsHidden()
						.disabled(self.isReadOnly)
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Expiry Date")
						.fontWeight(.heavy)
					DatePicker("",
						selection: Binding<Date>(
								get: { self.item.expiryDate ?? Date() },
								set: { self.item.expiryDate = $0 }
							),
							displayedComponents: .date
						)
						.labelsHidden()
						.disabled(self.isReadOnly)
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Place Of Birth")
						.fontWeight(.heavy)
					TextField("Place Of Birth", text: self.$item.placeOfBirth)
						.disabled(self.isReadOnly)
						.padding(10)
						.border(Color.secondary, width: 1)
					Text("Notes")
						.fontWeight(.heavy)
					TextEditor(text: self.$item.note)
						.disabled(self.isReadOnly)
						.padding(10)
						.frame(height: 200)
						.border(Color.secondary, width: 1)
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
