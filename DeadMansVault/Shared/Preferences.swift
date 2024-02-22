//
//  Preferences.swift
//  Created by Michael Simms on 12/12/21.
//

//	MIT License
//
//  Copyright (c) 2021 Michael J Simms. All rights reserved.
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

let PREF_KEY_VAULT_LOCATION = "Vault Location"
let PREF_KEY_DEFAULT_VAULT_NAME = "Default Vault Name"
let PREF_VALUE_ICLOUD_DRIVE = ""

class Preferences {
	static func baseVaultsLocation() -> String? {
		let mydefaults: UserDefaults = UserDefaults.standard
		let defaultLocation = mydefaults.string(forKey: PREF_KEY_VAULT_LOCATION)

		// If we don't have a default location then assume the iCloud drive
		if defaultLocation == nil {
			return PREF_VALUE_ICLOUD_DRIVE
		}
		return defaultLocation
	}
	
	static func setBaseVaultsLocation(location: String) {
		let mydefaults: UserDefaults = UserDefaults.standard
		mydefaults.set(location, forKey: PREF_KEY_VAULT_LOCATION)
	}
	
	static func defaultVaultName() -> String? {
		let mydefaults: UserDefaults = UserDefaults.standard
		return mydefaults.string(forKey: PREF_KEY_DEFAULT_VAULT_NAME)
	}
	
	static func setDefaultVaultName(name: String) {
		let mydefaults: UserDefaults = UserDefaults.standard
		mydefaults.set(name, forKey: PREF_KEY_DEFAULT_VAULT_NAME)
	}
}
