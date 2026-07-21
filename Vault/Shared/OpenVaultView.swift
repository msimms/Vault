//
//  OpenVaultView.swift
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

import SwiftUI

@ViewBuilder
func createVaultItemView(item: SecureVaultItem, isNewItem: Bool) -> some View {
	switch item {
	case is SecureCardItem: SecureCardView(item: item as! SecureCardItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureLoginItem: SecureLoginView(item: item as! SecureLoginItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureNoteItem: SecureNoteView(item: item as! SecureNoteItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureAccessPointItem: SecureAccessPointView(item: item as! SecureAccessPointItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureLicenseItem: SecureLicenseView(item: item as! SecureLicenseItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureServerItem: SecureServerView(item: item as! SecureServerItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureMembershipItem: SecureMembershipView(item: item as! SecureMembershipItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecurePassportItem: SecurePassportView(item: item as! SecurePassportItem, isNewItem: isNewItem, isReadOnly: true)
	case is SecureIdentityItem: SecureIdentityView(item: item as! SecureIdentityItem, isNewItem: isNewItem, isReadOnly: true)
	default: EmptyView()
	}
}

func iconForVaultItem(item: SecureVaultItem) -> String {
	switch item {
	case is SecureCardItem: return "creditcard.and.123";
	case is SecureLoginItem: return "lock";
	case is SecureNoteItem: return "note";
	case is SecureAccessPointItem: return "wifi";
	case is SecureLicenseItem: return "key";
	case is SecureServerItem: return "server.rack";
	case is SecureMembershipItem: return "lanyardcard";
	case is SecurePassportItem: return "book.closed";
	case is SecureIdentityItem: return "person";
	default: return ""
	}
}

func iconForVaultType(type: VaultItemType) -> String {
	switch type {
	case .card: return "creditcard.and.123";
	case .login: return "lock";
	case .note: return "note";
	case .accessPoint: return "wifi";
	case .license: return "key";
	case .server: return "server.rack";
	case .membership: return "lanyardcard";
	case .passport: return "book.closed";
	case .identity: return "person";
	}
}

func title(item: SecureVaultItem) -> String {
	switch item {
	case is SecureCardItem: let item2 = item as! SecureCardItem; return item2.displayTitle();
	case is SecureLoginItem: let item2 = item as! SecureLoginItem; return item2.displayTitle();
	case is SecureNoteItem: let item2 = item as! SecureNoteItem; return item2.displayTitle();
	case is SecureAccessPointItem: let item2 = item as! SecureAccessPointItem; return item2.displayTitle();
	case is SecureLicenseItem: let item2 = item as! SecureLicenseItem; return item2.displayTitle();
	case is SecureServerItem: let item2 = item as! SecureServerItem; return item2.displayTitle();
	case is SecureMembershipItem: let item2 = item as! SecureMembershipItem; return item2.displayTitle();
	case is SecurePassportItem: let item2 = item as! SecurePassportItem; return item2.displayTitle();
	case is SecureIdentityItem: let item2 = item as! SecureIdentityItem; return item2.displayTitle();
	default: return ""
	}
}

func subtitle(item: SecureVaultItem) -> String {
	switch item {
	case is SecureCardItem: let item2 = item as! SecureCardItem; return item2.displaySubtitle();
	case is SecureLoginItem: let item2 = item as! SecureLoginItem; return item2.displaySubtitle();
	case is SecureNoteItem: let item2 = item as! SecureNoteItem; return item2.displaySubtitle();
	case is SecureAccessPointItem: let item2 = item as! SecureAccessPointItem; return item2.displaySubtitle();
	case is SecureLicenseItem: let item2 = item as! SecureLicenseItem; return item2.displaySubtitle();
	case is SecureServerItem: let item2 = item as! SecureServerItem; return item2.displaySubtitle();
	case is SecureMembershipItem: let item2 = item as! SecureMembershipItem; return item2.displaySubtitle();
	case is SecurePassportItem: let item2 = item as! SecurePassportItem; return item2.displaySubtitle();
	case is SecureIdentityItem: let item2 = item as! SecureIdentityItem; return item2.displaySubtitle();
	default: return ""
	}
}

/// Displays all the items within the open vault.
struct OpenVaultView: View {
	@Environment(\.dismiss) var dismiss
#if os(macOS)
	@EnvironmentObject private var appDelegate: AppDelegate
#endif
	@ObservedObject var vault = AppState.shared.vault
	@State var showNewItem: Bool = false
	@State var showPrefs: Bool = false
	@State var newItemType: VaultItemType = VaultItemType.login
	@State private var showingFailedToDeleteAlert: Bool = false
	@State private var showingDeleteVaultAlert: Bool = false
	@State private var showingSuccessfulImportAlert: Bool = false
	@State private var showingFailedImportAlert: Bool = false
	@State private var showingFailedExportAlert: Bool = false
	@State private var searchTerm: String = ""
	@State private var closeVaultTimer = Timer.publish(every: 600, on: .main, in: .common).autoconnect() // Timer to automatically close the vault

	func resetTimer() {
		self.closeVaultTimer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()
	}

	var results: [String: [SecureVaultItem]] {
		let items = self.searchTerm.isEmpty ? self.vault.vaultItems : self.vault.vaultItems.filter { $0.displayTitle().lowercased().contains(searchTerm.lowercased())
		}
		let grouped = Dictionary(grouping: items) {
			String($0.displayTitle().first ?? Character(" "))
		}
		return grouped
	}

	var body: some View {
		VStack(alignment: .leading) {

			// List of all of the items in the vault.
			List {
				if results.keys.isEmpty {
					Text("Nothing to display!")
				}
				else {
					let keys: [String] = results.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
					ForEach(keys, id: \.self) { key in
						Section(header: Text(key)) {
							ForEach(results[key]!) { item in
								NavigationLink(destination: createVaultItemView(item: item, isNewItem: false)) {
									VStack(alignment: .leading) {
										HStack() {
											Text(title(item: item))
												.font(.headline)
											Image(systemName: iconForVaultItem(item: item))
										}
										Text(subtitle(item: item))
											.font(.subheadline)
									}
								}
							}
						}
					}
				}
			}
			.onChange(of: results, initial: false) { oldValue, newValue in
				resetTimer()
			}
			.searchable(text: $searchTerm)
			.listStyle(.plain)
			.padding(10)
#if os(macOS)
			// On macOS, use NavigationStack with navigationDestination(isPresented:)
			.background(EmptyView())
#else
			.navigationBarTitle(self.vault.name(), displayMode: .inline)
#endif
			.toolbar {

				// Toolbar item for creating new entries.
				ToolbarItem() {
					HStack {
						Menu {
							
							// New Login
							Button(action: {
								self.newItemType = VaultItemType.login
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Login", systemImage: iconForVaultType(type: .login))
									.labelStyle(.titleAndIcon)
							}

							// New Note
							Button(action: {
								self.newItemType = VaultItemType.note
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Note", systemImage: iconForVaultType(type: .note))
									.labelStyle(.titleAndIcon)
							}

							// New Card
							Button(action: {
								self.newItemType = VaultItemType.card
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Card", systemImage: iconForVaultType(type: .card))
									.labelStyle(.titleAndIcon)
							}

							// New Access Point
							Button(action: {
								self.newItemType = VaultItemType.accessPoint
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Access Point", systemImage: iconForVaultType(type: .accessPoint))
									.labelStyle(.titleAndIcon)
							}

							// New License Key
							Button(action: {
								self.newItemType = VaultItemType.license
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("License Key", systemImage: iconForVaultType(type: .license))
									.labelStyle(.titleAndIcon)
							}

							// New Server Credentials
							Button(action: {
								self.newItemType = VaultItemType.server
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Server", systemImage: iconForVaultType(type: .server))
									.labelStyle(.titleAndIcon)
							}

							// New Membership Card
							Button(action: {
								self.newItemType = VaultItemType.membership
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Membership", systemImage: iconForVaultType(type: .membership))
									.labelStyle(.titleAndIcon)
							}

							// Passport
							Button(action: {
								self.newItemType = VaultItemType.passport
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Passport", systemImage: iconForVaultType(type: .passport))
									.labelStyle(.titleAndIcon)
							}

							// Identity
							Button(action: {
								self.newItemType = VaultItemType.identity
								self.showNewItem = true
								self.resetTimer()
							}) {
								Label("Identity", systemImage: iconForVaultType(type: .identity))
									.labelStyle(.titleAndIcon)
							}
						}
						label: {
							Label("Add", systemImage: "plus")
						}

						Menu {
#if os(macOS)
							// Import Data
							Button(action: {
								let panel = NSOpenPanel()
								panel.allowsMultipleSelection = false
								panel.canChooseDirectories = false

								if panel.runModal() == .OK {
									if AppState.shared.importVaultFromUrl(from: panel.url!) {
										self.showingSuccessfulImportAlert = true
									}
									else {
										self.showingFailedImportAlert = true
									}
								}
							}) {
								Label("Import...", systemImage: "square.and.arrow.down")
									.labelStyle(.titleAndIcon)
							}

							// Export Data
							Button(action: {
								let panel = NSSavePanel()

								if panel.runModal() == .OK {
									self.showingFailedExportAlert = !AppState.shared.exportVaultToUrl(to: panel.url!)
								}
							}) {
								Label("Export...", systemImage: "square.and.arrow.up")
									.labelStyle(.titleAndIcon)
							}
							.alert("Failed to export the data!", isPresented: self.$showingFailedExportAlert) {
								Button("OK", role: .cancel) { }
							}

							Divider()
#endif

							// Preferences
							Button(action: {
								self.showPrefs = true
							}, label: {
								Label("Preferences...", systemImage: "note.text")
									.labelStyle(.titleAndIcon)
							})

							Divider()

							// Close the Vault
							Button(action: {
								AppState.shared.closeVault()
								self.dismiss()
							}) {
								Label("Close Vault", systemImage: "xmark.circle")
									.labelStyle(.titleAndIcon)
							}
							
							// Delete the Vault
							Button(action: {
								self.showingDeleteVaultAlert = true
							}) {
								Label("Delete Vault...", systemImage: "trash")
									.labelStyle(.titleAndIcon)
							}
						}
						label: {
							Label("File", systemImage: "folder")
						}
						.alert("Are you sure you want to do this? It cannot be undone.", isPresented: self.$showingDeleteVaultAlert) {
							Button("No", role: .cancel) { }
								.keyboardShortcut(.defaultAction)
							Button("Yes") {
								if AppState.shared.deleteVault() {
									AppState.shared.closeVault()
									self.dismiss()
								}
								else {
									self.showingFailedToDeleteAlert = true
								}
							}
							.keyboardShortcut(.cancelAction)
						}
						.alert("Failed to delete the vault!", isPresented: self.$showingFailedToDeleteAlert) {
							Button("OK", role: .cancel) { }
						}
						.alert("File imported!", isPresented: self.$showingSuccessfulImportAlert) {
							Button("OK", role: .cancel) { }
						}
						.alert("Failed to import the data!", isPresented: self.$showingFailedImportAlert) {
							Button("OK", role: .cancel) { }
						}
					}
				}
			}
#if os(macOS)
			.navigationDestination(isPresented: self.$showNewItem) {
				NewItemView(newItemType: self.$newItemType)
			}
			.navigationDestination(isPresented: self.$showPrefs) {
				VaultPrefsView()
			}
#endif
#if !os(macOS)
			.navigationDestination(
				isPresented: self.$showNewItem) {
					NewItemView(newItemType: self.$newItemType)
				}
			.navigationDestination(
				isPresented: self.$showPrefs) {
					VaultPrefsView()
				}
			.navigationBarBackButtonHidden(true)
#endif
		}
		.onReceive(self.closeVaultTimer) { _ in
			AppState.shared.closeVault()
			self.dismiss()
		}
		.onAppear() {
#if os(macOS)
			self.appDelegate.updateStatusBar()
#endif
		}
		.onDisappear() {
#if os(macOS)
			self.appDelegate.clearStatusBar()
#endif
		}
		.navigationTitle(self.vault.name())
	}
}
