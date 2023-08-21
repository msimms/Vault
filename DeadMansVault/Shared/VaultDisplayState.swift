//
//  VaultDisplayState.swift
//  Created by Michael Simms on 2/18/23.
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

final class VaultDisplayState: ObservableObject {
	static let shared = VaultDisplayState()
	@Published var vaultState: VaultState = VaultState.CreateNewVault
	
	func update(vaultState: VaultState) {
		self.vaultState = vaultState
	}
	
	func createButtonText() -> String {
		switch (self.vaultState) {
		case VaultState.CreateNewVault: return "Create Vault"
		case VaultState.VaultClosed: return "Open Vault"
		case VaultState.VaultOpen: return "View Vault"
		}
	}
	
#if !os(watchOS)
	@ViewBuilder
	func createView(isPushed: Binding<Bool>) -> some View {
		switch (self.vaultState) {
		case VaultState.CreateNewVault: NewVaultView(isPushed: isPushed)
		case VaultState.VaultClosed: LockView(isPushed: isPushed)
		case VaultState.VaultOpen: OpenVaultView(isPushed: isPushed)
		}
	}
#endif
}
