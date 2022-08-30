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
	@Binding var isPushed : Bool
	@Binding var suggestedPassword : String
	@State private var numChars: Double = 8
	@State private var numWords: Double = 3
	@State private var alphaNumOnly = false
	@State var gen = PasswordGenerator()

	var body: some View {

		VStack(alignment: .center) {
			Text("Password Generator")
				.fontWeight(.heavy)
			Divider()
			TextField("Suggested Password", text: $suggestedPassword)
			Group() {
				VStack() {
					VStack() {
						Text("Number of Characters")
						Slider(value: self.$numChars, in: 0...32, step: 1)
					}

					VStack() {
						Text("Number of Words")
						Slider(value: self.$numWords, in: 0...6, step: 1)
					}

					HStack() {
						Text("Alphanumerics Only")
						Button(action: { self.alphaNumOnly.toggle() }) {
							Label("", systemImage: "checkmark")
						}
					}
				}
			}
			Divider()
			Group() {
				HStack() {
					Button(action: {
						self.suggestedPassword = self.gen.generateUsingWords(numWords: 1)
					}) {
						Text("Generate With Words")
					}
					Button(action: {
						self.suggestedPassword = self.gen.generateUsingCharacters(numChars: UInt8(self.numChars), alphaNumOnly: self.alphaNumOnly)
					}) {
						Text("Generate With Characters")
					}
				}
			}
			Divider()
			Group() {
				HStack() {
					Button(action: {
						self.isPushed = false
					}) {
						Text("Cancel")
					}
					Button(action: {
						self.isPushed = false
					}) {
						Label("Save", systemImage: "square.and.arrow.down")
					}
				}
			}
		}
		.padding(10)

	}
}
