//
//  VaultMasterFile.swift
//  Created by Michael Simms on 2/2/22.
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
