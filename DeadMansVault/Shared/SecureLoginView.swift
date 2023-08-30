//
//  SecureLoginView.swift
//  Created by Michael Simms on 1/31/22.
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
struct SecureLoginView: View {
	@Binding var isPushed: Bool
	@State var item: SecureLoginItem
	@State var isNewItem: Bool = true
	@State var isReadOnly: Bool = false
	@State private var isShowingPasswordGenerator: Bool = false
	@State private var showPassword: Bool = false
	@State private var cannotShowPasswordGenerator: Bool = false

	var body: some View {

		VStack(alignment: .leading) {

			Group() {
				HStack() {
					Image(systemName: icon(item: self.item))
						.imageScale(.large)
					Text("Login")
						.fontWeight(.heavy)
						.font(.system(size: 32))
						.multilineTextAlignment(.center)
				}
				Divider()
				VStack(alignment: .leading) {
					Group() {
						Text("Website")
							.fontWeight(.heavy)
						TextField("Website", text: self.$item.website)
							.disabled(self.isReadOnly)
						Text("Username")
							.fontWeight(.heavy)
						TextField("Username", text: self.$item.username)
							.disabled(self.isReadOnly)
						Text("Email")
							.fontWeight(.heavy)
						TextField("Email", text: self.$item.email)
							.disabled(self.isReadOnly)
						Text("Password")
							.fontWeight(.heavy)
					}
					Group() {
						ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
							Group() {
								if self.showPassword {
									TextField("Password", text: self.$item.password)
										.disabled(self.isReadOnly)
								}
								else {
									SecureField("Password", text: self.$item.password)
										.disabled(self.isReadOnly)
								}
								HStack() {
									Button(action: {
										self.showPassword.toggle()
									}) {
										Image(systemName: "eye")
											.foregroundColor(.secondary)
									}
									.padding(10)
									if self.isReadOnly == false {
										ZStack() {
											NavigationLink(destination: PasswordGeneratorView(existingPassword: self.$item.password, suggestedPassword: self.item.password), isActive: self.$isShowingPasswordGenerator) {
											}
											Button(action: {
												if self.isReadOnly {
													self.cannotShowPasswordGenerator = true
												}
												else {
													self.isShowingPasswordGenerator = true
												}
											}) {
												Image(systemName: "arrow.clockwise")
													.foregroundColor(.secondary)
											}
											.alert("Cannot generate a new password because the item is read only!", isPresented: self.$cannotShowPasswordGenerator) {
												Button("OK", role: .cancel) { }
													.buttonStyle(PlainButtonStyle())
											}
										}
									}
								}
							}
						})
						Text("Notes")
							.fontWeight(.heavy)
						TextEditor(text: self.$item.note)
							.disabled(self.isReadOnly)
							.scrollContentBackground(.hidden)
							.background(.gray)
					}
					TagsView(isReadOnly: self.$isReadOnly, tags: self.$item.tags)
					LastModifiedView(isNewItem: self.isNewItem, timestamp: self.item.lastModifiedTime)
				}
			}

			Spacer()
			ItemButtonView(isReadOnly: self.$isReadOnly, item: self.item, isNewItem: self.isNewItem)
		}
		.padding(10)
    }
}
