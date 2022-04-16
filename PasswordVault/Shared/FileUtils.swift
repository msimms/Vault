//
//  FileUtils.swift
//  PasswordVault
//
//  Created by Michael Simms on 1/22/22.
//

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
