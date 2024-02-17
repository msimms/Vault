//
//  DeadMansVaultApp.swift
//  Created by Michael Simms on 8/18/23.
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

@main
struct DeadMansVaultApp: App {
#if os(macOS)
	@NSApplicationDelegateAdaptor(AppDelegate.self) var Delegate
#endif

	var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
	private var statusItem: NSStatusItem!
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
		self.statusItem.menu = NSMenu()
		
		if let button = self.statusItem.button {
			button.image = NSImage(systemSymbolName: "lock", accessibilityDescription: "1")
			self.clearStatusBar()
		}
	}
	
	@objc func statusItemSelected(_ sender: Any) {
		if let menuItem = sender as? NSMenuItem {
			if let vaultItem = menuItem.representedObject as? SecureVaultItem {
				copyToPasteboard(value: vaultItem.copy())
			}
		}
	}
	
	func updateStatusBar() {
		guard self.statusItem != nil else {
			return
		}
		
		if let menu = self.statusItem.menu {
			menu.removeAllItems()

			for vaultItem in AppState.shared.vault.vaultItems {
				let menuItem = NSMenuItem(title: vaultItem.displayTitle(), action: #selector(self.statusItemSelected(_:)), keyEquivalent: "")
				menuItem.image = NSImage(systemSymbolName: iconForVaultItem(item: vaultItem), accessibilityDescription: nil)
				menuItem.representedObject = vaultItem
				menu.items.append(menuItem)
			}
		}
	}
	
	func clearStatusBar() {
		guard self.statusItem != nil else {
			return
		}
		
		if let menu = self.statusItem.menu {
			menu.removeAllItems()

			let menuItem = NSMenuItem(title: "The vault is locked", action: nil, keyEquivalent: "")
			menu.items.append(menuItem)
		}
	}
}
#endif
