//
//  SecureLoginView.swift
//  Created by Michael Simms on 9/5/23.
//

// MIT License
//
// Copyright (c) 2023 Mike Simms
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

func copyToPasteboard(value: String) {
#if os(iOS)
	let pasteboard = UIPasteboard.general
	pasteboard.string = value
#else
	let pasteboard = NSPasteboard.general
	pasteboard.clearContents()
	pasteboard.setString(value, forType: NSPasteboard.PasteboardType.string)
#endif
}

func showOpenPanel() -> URL? {
#if os(macOS)
	let savePanel = NSOpenPanel()
	savePanel.allowedContentTypes = []
	savePanel.isExtensionHidden = false
	savePanel.title = "Select the file"
	savePanel.message = "Choose a file to add to the vault."
	
	let response = savePanel.runModal()
	return response == .OK ? savePanel.url : nil
#elseif os(iOS)
	let keyWindow = UIApplication.shared.connectedScenes
		.filter({$0.activationState == .foregroundActive})
		.compactMap({$0 as? UIWindowScene})
		.first?.windows
		.filter({$0.isKeyWindow}).first
	let allowedExtensions = ["txt", "csv", "pdf"]
	let documentPicker = UIDocumentPickerViewController(documentTypes: allowedExtensions, in: .import)
	
	documentPicker.allowsMultipleSelection = false
	documentPicker.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	keyWindow?.rootViewController?.present(documentPicker, animated: true)
	return nil
#endif
}
