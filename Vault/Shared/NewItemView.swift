//
//  NewItemView.swift
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

@ViewBuilder
func createNewVaultItemView(itemType: VaultItemType) -> some View {
	switch itemType {
	case .login: SecureLoginView(item: SecureLoginItem(), isNewItem: true, isReadOnly: false)
	case .note: SecureNoteView(item: SecureNoteItem(), isNewItem: true, isReadOnly: false)
	case .card: SecureCardView(item: SecureCardItem(), isNewItem: true, isReadOnly: false)
	case .accessPoint: SecureAccessPointView(item: SecureAccessPointItem(), isNewItem: true, isReadOnly: false)
	case .license: SecureLicenseView(item: SecureLicenseItem(), isNewItem: true, isReadOnly: false)
	case .server: SecureServerView(item: SecureServerItem(), isNewItem: true, isReadOnly: false)
	case .membership: SecureMembershipView(item: SecureMembershipItem(), isNewItem: true, isReadOnly: false)
	case .passport: SecurePassportView(item: SecurePassportItem(), isNewItem: true, isReadOnly: false)
	case .identity: SecureIdentityView(item: SecureIdentityItem(), isNewItem: true, isReadOnly: false)
	}
}

/// Displays all the items within the open vault.
struct NewItemView: View {
	@Binding var newItemType: VaultItemType

	var body: some View {
		createNewVaultItemView(itemType: self.newItemType)
	}
}
