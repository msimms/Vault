//
//  PasswordGenerator.swift
//  Created by Michael Simms on 8/27/22.
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

class PasswordGenerator {
	func generateRandomWord() -> String {
		let chunkSize = 64

#if os(iOS)
		let filePath = Bundle.main.path(forResource: "words", ofType: "txt")
		let fileUrl = URL(string: filePath!)
#else
		// We'll select a random word from /usr/share/dict/words
		let fileUrl = URL(string: "/usr/share/dict/words")
#endif
		guard let fileHandle = try? FileHandle(forReadingFrom: fileUrl!) else { return "" }

		// Get the size of the file.
		let numBytes = fileHandle.availableData.count

		// Jump to some random point in the file and read a chunk.
		let randLoc = arc4random_uniform(UInt32(numBytes - chunkSize))
		fileHandle.seek(toFileOffset: UInt64(randLoc))
		let chunkData = fileHandle.readData(ofLength: chunkSize)
		let chunkStr = String(data: chunkData, encoding: .utf8) ?? ""
		
		// Look through the chunk that was read for a word on it's own line.
		var randWord = ""
		var started = false
		for i in 0...chunkStr.count - 1 {
			let char = chunkStr[chunkStr.index(chunkStr.startIndex, offsetBy: i)]
			if char == "\n" {
				if randWord.count > 0 {
					return randWord
				}
				started = true
			}
			else if started {
				randWord.append(char)
			}
		}

		return "foo" // not currently very random :)
	}

	func generateUsingWords(numWords: UInt8) -> String {
		var result = ""

		for i in 1...numWords {
			if i != 1 {
				result = result + "-"
			}
			result = result + generateRandomWord()
		}
		return result
	}

	func generateUsingCharacters(numChars: UInt8, alphaNumOnly: Bool, prohibitedChars: String) -> String {
		var letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		if !alphaNumOnly {
			letters += "!@#$%^&*()-=_+[]{};':,.<>?`~"
		}
		letters = letters.filter { prohibitedChars.range(of: String($0)) == nil }
		if letters.isEmpty {
			return ""
		}
		return String((0..<numChars).map{ _ in letters.randomElement()! })
	}
}
