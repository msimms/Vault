//
//  Importer.swift
//  Created by Michael Simms on 9/9/22.
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

struct PifLabeledUrls: Codable {
	var label: String
	var url: String
}

struct PifFields: Codable {
	var k: String
	var n: String
	var v: String
	var t: String
}

struct PifSection: Codable {
	var fields: Array<PifFields>?
	var title: String?
	var name: String?
}

struct PifSecureContents: Codable {
	var urls: Array<PifLabeledUrls>?
	var notesPlain: String?
	var password: String?
	var sections: Array<PifSection>?
}

struct PifEncoding: Codable {
	var uuid: String
	var updatedAt: UInt64
	var locationKey: String?
	var securityLevel: String
	var contentsHash: String
	var title: String
	var location: String?
	var secureContents: PifSecureContents
	var txTimestamp: UInt64
	var createdAt: UInt64
	var typeName: String
}

class Importer {

	/// Entry point for importing a 1pif file.
	func importFrom1pif(location: URL, vault: Vault) throws {
		let fileName = location.path
		let data = try String(contentsOfFile: fileName, encoding: .utf8)
		let entries = data.components(separatedBy: .newlines)

		for entry in entries {

			// 1Password puts a comment line between each entry.
			if entry.starts(with: "***") == false {
				let pifContents = try JSONDecoder().decode(PifEncoding.self, from: entry.data(using: .utf8)!)
				let vaultItem = try createVaultItemFrom1Pif(contents: pifContents)
				
				try vault.addItem(item: vaultItem)
			}
		}
	}

	/// Entry point for importing a file.
	/// The import function will be determined based on the file's extension.
	func importFrom(location: URL, vault: Vault) throws {
		if location.pathExtension == "1pif" {
			try self.importFrom1pif(location: location, vault: vault)
		}
	}
}
