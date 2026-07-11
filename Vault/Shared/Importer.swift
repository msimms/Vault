//
//  Importer.swift
//  Created by Michael Simms on 9/9/22.
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

import Foundation

enum StringOrIntType: Codable {
	case string(String)
	case int(Int)
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		do {
			self = try .string(container.decode(String.self))
		} catch DecodingError.typeMismatch {
			self = try .int(container.decode(Int.self))
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .int(let int):
			try container.encode(int)
		case .string(let string):
			try container.encode(string)
		}
	}
	
	func decodeToString() throws -> String {
		if case .string(let int) = self {
			return int
		}
		if case .int(let int) = self {
			return String(int)
		}
		return ""
	}
	
	func decodeToInt() throws -> Int {
		if case .string(let int) = self {
			return Int(int) ?? 0
		}
		if case .int(let int) = self {
			return int
		}
		return 0
	}
}

struct PifLabeledUrls: Codable {
	var label: String
	var url: String
}

struct PifSectionFields: Codable {
	var k: String
	var n: String
	var v: StringOrIntType?
	var t: String
	var inputTraits: Dictionary<String, String>?
}

struct PifSecureContentsFields: Codable {
	var value: String
	var name: String
	var type: String
	var designation: String
}

struct PifPasswordHistory: Codable {
	var value: String
	var time: UInt64
}

struct PifSection: Codable {
	var fields: Array<PifSectionFields>?
	var title: String?
	var name: String?
}

struct PifSecureContents: Codable {
	var urls: Array<PifLabeledUrls>?
	var fields: Array<PifSecureContentsFields>?
	var passwordHistory: Array<PifPasswordHistory>?
	var reg_name: String?
	var reg_code: String?
	var reg_email: String?
	var company: String?
	var phoneLocal: String?
	var expiry_mm: String?
	var expiry_yy: String?
	var validFrom_yy: String?
	var validFrom_mm: String?
	var bank: String?
	var type: String?
	var notesPlain: String?
	var name: String?
	var password: String?
	var membership_no: String?
	var member_since_yy: String?
	var member_since_mm: String?
	var sections: Array<PifSection>?
}

struct PifOpenContents: Codable {
	var tags: Array<String>?
}

struct PifEncoding: Codable {
	var uuid: String
	var updatedAt: UInt64
	var locationKey: String?
	var securityLevel: String
	var openContents: PifOpenContents?
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
				do {
					let pifContents = try JSONDecoder().decode(PifEncoding.self, from: entry.data(using: .utf8)!)
					let vaultItem = try createVaultItemFrom1Pif(contents: pifContents)
					
					try vault.addItem(item: vaultItem)
				}
				catch {
					print("Error importing " + entry + ".")
					print(error)
				}
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
