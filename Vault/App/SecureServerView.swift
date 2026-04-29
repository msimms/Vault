//
//  SecureServerView.swift
//  Created by Michael Simms on 4/28/26.
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
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct SecureServerLoginView: View {
	@State var isReadOnly: Bool = false
	@State var username: String = ""
	@State var password: String = ""

	var body: some View {

		VStack(alignment: .leading) {
			HStack() {
				Text("Username")
					.fontWeight(.heavy)
				TextField("Username", text: self.$username, onCommit: {
				})
				.disabled(self.isReadOnly)
			}
			HStack() {
				Text("Password")
					.fontWeight(.heavy)
				TextField("Password", text: self.$password, onCommit: {
				})
				.disabled(self.isReadOnly)
			}
		}
		.padding(10)
		.border(Color.secondary, width: 1)
	}
}

/// Displays a login item from the vault.
struct SecureServerView: View {
	@ObservedObject var item: SecureServerItem
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
					Text("Server")
						.fontWeight(.heavy)
						.font(.system(size: 32))
						.multilineTextAlignment(.center)
				}
				TextField("Title", text: self.$item.title)
					.fontWeight(.heavy)
					.font(.system(size: 24))
					.foregroundColor(.white)
					.multilineTextAlignment(.center)
					.disabled(self.isReadOnly)
				Divider()
				VStack(alignment: .leading) {
					Group() {
						Text("URI")
							.fontWeight(.heavy)
						ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center), content: {
							TextField("URI", text: self.$item.uri)
								.disabled(self.isReadOnly)
								.padding(10)
							Button(action: {
								copyToPasteboard(value: self.item.uri)
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
						Text("Credentials")
							.fontWeight(.heavy)
						ForEach(Array(self.item.logins), id: \.self) { login in
							SecureServerLoginView(isReadOnly: self.isReadOnly, username: login.username, password: login.password)
						}
						Button(action: {
							self.item.logins.append(SecureServerLogin(username: "", password: ""))
						}, label: {
							Label("Add Username/Password", systemImage: "person.badge.key")
								.labelStyle(.titleAndIcon)
						})
						.help("Add a new username / password combination")
					}
					Group() {
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
