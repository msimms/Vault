//
//  SecureLoginView.swift
//  Created by Michael Simms on 1/31/22.
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
#if os(iOS)
import UIKit
#else
import AppKit
#endif

/// Displays a login item from the vault.
struct SecureLoginView: View {
	@Environment(\.colorScheme) var colorScheme
	@ObservedObject var item: SecureLoginItem
	@State var isNewItem: Bool = true
	@State var isReadOnly: Bool = false
	@State var additionalUrl: String = ""
	@State private var isShowingPasswordGenerator: Bool = false
	@State private var showPassword: Bool = false
	@State private var cannotShowPasswordGenerator: Bool = false
		
	var body: some View {
		
		VStack(alignment: .leading) {
			ScrollView() {
				HStack() {
					Image(systemName: iconForVaultItem(item: self.item))
						.imageScale(.large)
					Text("Login")
						.fontWeight(.heavy)
						.font(.system(size: 32))
						.multilineTextAlignment(.center)
				}
				TextField("Title", text: self.$item.title)
					.fontWeight(.heavy)
					.font(.system(size: 24))
					.foregroundColor(colorScheme == .dark ? .white : .black)
					.multilineTextAlignment(.center)
					.disabled(self.isReadOnly)
				Divider()
				VStack(alignment: .leading) {
					Group() {
						Text("Website")
							.fontWeight(.heavy)
						ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
							TextField("Website", text: self.$item.website)
								.foregroundColor(colorScheme == .dark ? .white : .black)
								.disabled(self.isReadOnly)
								.padding(10)
							Button(action: {
								copyToPasteboard(value: self.item.website)
							}) {
								Image(systemName: "doc.on.doc")
									.foregroundColor(.secondary)
									.padding(10)
							}
							.help("Copy")
						})
						.border(Color.secondary, width: 1)
						Text("Additional URLs")
							.fontWeight(.heavy)
						VStack(alignment: .leading) {
							ForEach(self.$item.urls.indices, id: \.self) { index in
								if !self.item.urls[index].isEmpty {
									TextField("", text: self.$item.urls[index])
										.disabled(self.isReadOnly)
										.padding(10)
								}
							}
							TextField("", text: self.$additionalUrl, onCommit: {
								self.item.urls.append(self.additionalUrl)
								self.additionalUrl = ""
							})
							.disabled(self.isReadOnly)
						}
						.border(Color.secondary, width: 1)
						Text("Username")
							.fontWeight(.heavy)
						ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
							TextField("Username", text: self.$item.username)
								.disabled(self.isReadOnly)
								.padding(10)
							Button(action: {
								copyToPasteboard(value: self.item.username)
							}) {
								Image(systemName: "doc.on.doc")
									.foregroundColor(.secondary)
									.padding(10)
							}
							.help("Copy")
						})
						.border(Color.secondary, width: 1)
						Text("Email")
							.fontWeight(.heavy)
						ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
							TextField("Email", text: self.$item.email)
								.disabled(self.isReadOnly)
								.padding(10)
							Button(action: {
								copyToPasteboard(value: self.item.email)
							}) {
								Image(systemName: "doc.on.doc")
									.foregroundColor(.secondary)
									.padding(10)
							}
							.help("Copy")
						})
						.border(Color.secondary, width: 1)
					}
					Group() {
						Text("Password")
							.fontWeight(.heavy)
						ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
							if self.showPassword {
								TextField("Password", text: self.$item.password)
									.disabled(self.isReadOnly)
									.padding(10)
									.border(Color.secondary, width: 1)
							}
							else {
								SecureField("Password", text: self.$item.password)
									.disabled(self.isReadOnly)
									.padding(10)
									.border(Color.secondary, width: 1)
							}
							HStack() {
								if self.isReadOnly == false {
									ZStack() {
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
												.padding(10)
										}
										.alert("Cannot generate a new password because the item is read only!", isPresented: self.$cannotShowPasswordGenerator) {
											Button("OK", role: .cancel) { }
												.buttonStyle(PlainButtonStyle())
										}
										.navigationDestination(isPresented: self.$isShowingPasswordGenerator) {
											PasswordGeneratorView(existingPassword: self.$item.password, suggestedPassword: self.item.password)
										}
									}
									.border(Color.secondary, width: 1)
								}
								Button(action: {
									self.showPassword.toggle()
								}) {
									Image(systemName: "eye")
										.foregroundColor(.secondary)
										.padding(10)
								}
								.help("View")
								Button(action: {
									copyToPasteboard(value: self.item.password)
								}) {
									Image(systemName: "doc.on.doc")
										.foregroundColor(.secondary)
										.padding(10)
								}
								.help("Copy")
							}
						})
						Text("Notes")
							.fontWeight(.heavy)
						TextEditor(text: self.$item.note)
							.disabled(self.isReadOnly)
							.padding(10)
							.frame(height: 200)
							.border(Color.secondary, width: 1)
					}
					AttachFilesView(isReadOnly: self.$isReadOnly, item: self.item)
					TagsView(isReadOnly: self.$isReadOnly, tags: self.$item.tags)
					LastModifiedView(isNewItem: self.isNewItem, timestamp: self.item.lastModifiedTime)
				}
				Spacer()
				ItemButtonView(isReadOnly: self.$isReadOnly, item: self.item, isNewItem: self.isNewItem)
			}
			.padding(10)
		}
	}
}
