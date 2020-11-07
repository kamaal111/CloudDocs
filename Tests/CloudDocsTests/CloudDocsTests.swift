//
//  ICloudDocsTests.swift
//
//
//  Created by Kamaal Farah on 05/11/2020.
//

import XCTest
@testable import CloudDocs

final class ICloudDocsTests: XCTestCase {

    var cloudDocs: CloudDocs?

    override func setUpWithError() throws {
        continueAfterFailure = false
        let containerURL = URL(string: "https://github.com/kamaal111/CloudDocs")
        let mockFileManager = MockFileManager(containerURL: containerURL)
        cloudDocs = CloudDocs(fileManager: mockFileManager)
    }

    override func tearDownWithError() throws {
        cloudDocs = nil
    }

    func testExample() {
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]

}
