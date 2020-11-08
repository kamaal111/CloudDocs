//
//  MockFileManagerTests.swift
//  
//
//  Created by Kamaal Farah on 07/11/2020.
//

import XCTest
@testable import CloudDocs

final class MockFileManagerTests: XCTestCase {

    var fileManager: MockFileManager?

    override func setUpWithError() throws {
        continueAfterFailure = false
        let containerURL = URL(string: "https://github.com/kamaal111/CloudDocs")
        let mockFileManager = MockFileManager(containerURL: containerURL)
        fileManager = mockFileManager
    }

    override func tearDownWithError() throws {
        fileManager = nil
    }

    func testExample() {
        XCTAssertEqual(true, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]

}

class MockFileManager: FileManager {
    var containerURL: URL?
    var content: [URL] = []

    init(containerURL: URL?) {
        self.containerURL = containerURL
    }

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]? = nil) -> Bool {
        return true
    }

    override func url(forUbiquityContainerIdentifier containerIdentifier: String?) -> URL? {
        return containerURL
    }

    override func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        print(url)
        return content
    }

    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        return
    }

    override func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        return path == containerURL?.appendingPathComponent("Documents").path
    }

    override func removeItem(at URL: URL) throws {
        return
    }

    func addContentToDirectory(url: URL) {
        content.append(url)
    }
}
