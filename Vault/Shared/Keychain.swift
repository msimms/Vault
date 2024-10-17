//
//  Keychain.swift
//  Created by Michael Simms on 7/27/23.
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

import Foundation

class Keychain {
	func save(keyName: String, data: Data) -> Bool {
		let query = [
			kSecClass as String : kSecClassGenericPassword as String,
			kSecAttrAccount as String : keyName,
			kSecValueData as String : data ] as [String : Any]
		
		// Remove any old versions.
		SecItemDelete(query as CFDictionary)
		
		// Write the key/value pair.
		return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
	}

	func load(keyName: String) -> Data? {
		let query = [
			kSecClass as String : kSecClassGenericPassword,
			kSecAttrAccount as String : keyName,
			kSecReturnData as String : kCFBooleanTrue!,
			kSecMatchLimit as String : kSecMatchLimitOne ] as [String : Any]

		var dataTypeRef: AnyObject? = nil
		
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
		
		if status == noErr {
			return dataTypeRef as! Data?
		} else {
			return nil
		}
	}
	
	func delete(keyName: String) -> Bool {
		let query = [
			kSecClass as String : kSecClassGenericPassword as String,
			kSecAttrAccount as String : keyName  ] as [String : Any]
		
		// Remove any old versions.
		return SecItemDelete(query as CFDictionary) == errSecSuccess
	}
}
