//
//  SecureCardView.swift
//  Created by Michael Simms on 5/14/22.
//

//	MIT License
//
//  Copyright (c) 2022 Michael J Simms. All rights reserved.
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
struct SecureCardView: View {
	@State var item: SecureCardItem
	@State var isNewItem: Bool = true
	@State var isReadOnly: Bool = false
	@State private var showsDatePicker: Bool = false
	@State private var tempExpiryDate: String = ""

	let dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM"
		return df
	}()

	var body: some View {

		VStack(alignment: .leading) {
			ScrollView() {
				Group() {
					HStack() {
						Image(systemName: iconForVaultItem(item: self.item))
							.imageScale(.large)
						Text("Card")
							.fontWeight(.heavy)
							.font(.system(size: 32))
							.multilineTextAlignment(.center)
					}
					Divider()
					VStack(alignment: .leading) {
						Group() {
							Text("Title")
								.fontWeight(.heavy)
							TextField("Title", text: self.$item.name)
								.disabled(self.isReadOnly)
								.padding(10)
								.border(Color.secondary, width: 1)
						}
						Group() {
							Text("Card Holder")
								.fontWeight(.heavy)
							TextField("Card Holder", text: self.$item.cardHolder)
								.disabled(self.isReadOnly)
								.padding(10)
								.border(Color.secondary, width: 1)
							Text("Card Type")
								.fontWeight(.heavy)
							TextField("Card Type", text: self.$item.cardType)
								.disabled(self.isReadOnly)
								.padding(10)
								.border(Color.secondary, width: 1)
							Text("Number")
								.fontWeight(.heavy)
							ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
								TextField("Number", text: self.$item.number)
									.disabled(self.isReadOnly)
									.padding(10)
									.border(Color.secondary, width: 1)
								Button(action: {
									copyToPasteboard(value: self.item.number)
								}) {
									Image(systemName: "doc.on.doc")
										.foregroundColor(.secondary)
										.padding(10)
								}
								.help("Copy")
							})
							Text("Security Code")
								.fontWeight(.heavy)
							TextField("Security Code", value: self.$item.securityCode, formatter: NumberFormatter())
								.disabled(self.isReadOnly)
								.padding(10)
								.border(Color.secondary, width: 1)
							HStack {
								Text("Expiry Date")
									.fontWeight(.heavy)
								Spacer()
								Text("\(self.dateFormatter.string(from: self.item.expiry))")
									.onTapGesture {
										self.showsDatePicker.toggle()
									}
									.padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
									.disabled(self.isReadOnly)
									.padding(10)
							}
							if self.showsDatePicker {
								DatePicker("", selection: self.$item.expiry, displayedComponents: .date)
									.datePickerStyle(.graphical)
							}
						}
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
				}
				Spacer()
				ItemButtonView(isReadOnly: self.$isReadOnly, item: self.item, isNewItem: self.isNewItem)
			}
			.padding(10)
		}
	}
}
