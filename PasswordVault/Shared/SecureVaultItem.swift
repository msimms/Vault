//
//  Login.swift
//  PasswordVault
//
//  Created by Michael Simms on 12/13/21.
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

import Foundation

class SecureVaultItem: Codable, Identifiable {
	enum CodingKeys: CodingKey {
		case id
		case vaultVersion
		case note
	}

	var id = UUID()
	var vaultVersion: UInt8
	var note: String

	init() {
		self.vaultVersion = Vault.kCurrentVaultVersion
		self.note = ""
	}

	/// Creates the file for the vault item.
	func write(location: URL, key: Data) throws {

		// Sanity check the parameters.
		if key.count == 0 {
			throw VaultException.runtimeError("Error when saving a vault item.")
		}
	}
}
