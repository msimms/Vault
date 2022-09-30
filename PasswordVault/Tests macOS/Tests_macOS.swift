//
//  Tests_macOS.swift
//  Created by Michael Simms on 12/12/21.
//

import XCTest

class Tests_macOS: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testImport() throws {
		let importer = Importer()
		let testFilesLocation = URL(fileURLWithPath: #file.replacingOccurrences(of: "PasswordVault/Tests macOS/Tests_macOS.swift", with: "Test"))
		let dirListing = try FileManager.default.contentsOfDirectory(at: testFilesLocation, includingPropertiesForKeys: nil)
		var testVault = Vault()

		for testFileLocation in dirListing {
			do {
				try importer.importFrom(location: testFileLocation, vault: testVault)
			} catch {
				print(error.localizedDescription)
			}
		}
	}

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
