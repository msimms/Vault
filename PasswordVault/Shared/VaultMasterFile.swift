//
//  VaultMasterFile.swift
//  PasswordVault
//
//  Created by Michael Simms on 2/2/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct TextFile: FileDocument {
	static var readableContentTypes = [UTType.json]

	var text = ""

	/// A simple initializer that creates new, empty documents
	init(initialText: String = "") {
		text = initialText
	}

	/// This initializer loads data that has been saved previously
	init(configuration: ReadConfiguration) throws {
		if let data = configuration.file.regularFileContents {
			text = String(decoding: data, as: UTF8.self)
		} else {
			throw CocoaError(.fileReadCorruptFile)
		}
	}

	/// This will be called when the system wants to write our data to disk
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		let data = Data(text.utf8)
		return FileWrapper(regularFileWithContents: data)
	}
}
