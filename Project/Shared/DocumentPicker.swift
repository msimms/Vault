//
//  DocumentPicker.swift
//  Created by Michael Simms on 10/23/23.
//

//	MIT License
//
//  Copyright (c) 2023 Michael J Simms. All rights reserved.
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
import UniformTypeIdentifiers

#if os(iOS)

typealias DocumentResponse = (_: URL) -> ()

struct DocumentPicker: UIViewControllerRepresentable {
	private var callback: DocumentResponse
	private var contentTypes: [UTType] = []

	init(contentTypes: [UTType], callback: @escaping DocumentResponse) {
		self.contentTypes = contentTypes
		self.callback = callback
	}

	func makeUIViewController(context: Context) -> some UIViewController {
		let controller = UIDocumentPickerViewController(forOpeningContentTypes: self.contentTypes)
		controller.allowsMultipleSelection = false
		controller.shouldShowFileExtensions = true
		controller.delegate = context.coordinator
		return controller
	}

	func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
	}

	func makeCoordinator() -> DocumentPickerCoordinator {
		DocumentPickerCoordinator(callback: self.callback)
	}
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
	private var callback: DocumentResponse

	init(callback: @escaping DocumentResponse) {
		self.callback = callback
	}

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let url = urls.first else {
			return
		}
		self.callback(url)
	}
}

#endif

