//
//  FileUtils.swift
//  PasswordVault
//
//  Created by Michael Simms on 1/22/22.
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

func writeToFile(fileName: String, writeText: String) -> Bool {
	let desktopURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
	let fileURL = desktopURL.appendingPathComponent(fileName).appendingPathExtension("txt")

	do {
		try writeText.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
	} catch let error as NSError {
		print("Error: Failed to write: \n\(error)" )
		return false
	}
	return true
}

func contentsOfDir(dirName: URL) -> [URL] {
	let fileManager = FileManager.default

	do {
		let contents = try fileManager.contentsOfDirectory(atPath: dirName.path)

		let urls = contents.map { return dirName.appendingPathComponent($0) }
		return urls
	} catch {
	}
	return []
}
