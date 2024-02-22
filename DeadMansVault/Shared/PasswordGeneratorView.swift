//
//  PasswordGeneratorView.swift
//  Created by Michael Simms on 8/26/22.
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

struct PasswordGeneratorView: View {
	@Environment(\.dismiss) var dismiss
	@Binding var existingPassword: String
	@State var suggestedPassword: String = ""
	@State private var numChars: Double = 8
	@State private var numWords: Double = 3
	@State private var alphaNumOnly: Bool = false
	@State var gen = PasswordGenerator()

	var body: some View {
	
		Group() {
			VStack(alignment: .center) {
				Group() {
					Text("Password Generator")
						.fontWeight(.heavy)
						.font(.system(size: 32))
				}
				.padding(10)
				Divider()
				Group() {
					TextField("Suggested Password", text: self.$suggestedPassword)
					VStack() {
						VStack() {
							Text("Number of Characters")
							Slider(value: Binding(
								get: {
									self.numChars
								},
								set: {(newValue) in
									self.numChars = newValue
									self.suggestedPassword = self.gen.generateUsingCharacters(numChars: UInt8(self.numChars), alphaNumOnly: self.alphaNumOnly)
								}
							), in: 1...32, step: 1)
						}

						VStack() {
							Text("Number of Words")
							Slider(value: Binding(
								get: {
									self.numWords
								},
								set: {(newValue) in
									self.numWords = newValue
									self.suggestedPassword = self.gen.generateUsingWords(numWords: UInt8(self.numWords))
								}
							), in: 1...8, step: 1)
						}

						HStack() {
							Toggle("Alphanumerics Only", isOn: $alphaNumOnly)
						}
					}
				}
				.padding(10)
				Divider()
				Group() {
					VStack() {
						Button(action: {
							self.suggestedPassword = self.gen.generateUsingWords(numWords: UInt8(self.numWords))
						}) {
							Text("Generate With Words")
								.frame(width: 256)
						}
						.padding(10)
						Button(action: {
							self.suggestedPassword = self.gen.generateUsingCharacters(numChars: UInt8(self.numChars), alphaNumOnly: self.alphaNumOnly)
						}) {
							Text("Generate With Characters")
								.frame(width: 256)
						}
					}
				}
				.padding(10)
				Divider()
				Group() {
					HStack() {
#if os(macOS)
						Button(action: {
							self.dismiss()
						}) {
							Text("Cancel")
						}
#endif
						Button(action: {
							self.existingPassword = self.suggestedPassword
							self.dismiss()
						}) {
							Label("Save", systemImage: "square.and.arrow.down")
						}
					}
				}
				.padding(10)
			}
			.padding(10)
		}
		.padding(10)

	}
}
