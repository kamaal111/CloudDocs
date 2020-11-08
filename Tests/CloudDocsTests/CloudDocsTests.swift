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
    var mockFileManager: MockFileManager?

    override func setUpWithError() throws {
        continueAfterFailure = false
        let containerURL = URL(string: "https://github.com/kamaal111/CloudDocs")
        let mockFileManager = MockFileManager(containerURL: containerURL)
        self.mockFileManager = mockFileManager
        self.cloudDocs = CloudDocs(fileManager: mockFileManager)
    }

    override func tearDownWithError() throws {
        cloudDocs = nil
        mockFileManager = nil
    }

    func test_createFile() {
        XCTAssertNotNil(cloudDocs)
        let file = CloudyFile(name: "namer")
        let created = try! cloudDocs!._createFile(fileName: "file-1",
                                                  fileExtension: "cloudy",
                                                  content: file,
                                                  force: false)
        XCTAssert(created)
    }

    func test_createFileThrowsNoFolderFoundError() {
        XCTAssertNotNil(cloudDocs)
        XCTAssertNotNil(mockFileManager)
        mockFileManager!.containerURL = nil
        let file = CloudyFile(name: "namer")
        do {
            _ = try cloudDocs!._createFile(fileName: "file-1",
                                           fileExtension: "cloudy",
                                           content: file,
                                           force: false)
        } catch {
            XCTAssertEqual(error.localizedDescription,
                           CloudDocs.CloudDocsError.cloudDocumentFolderNotFound.localizedDescription)
        }
    }

    func test_createFileThrowsFileExistsError() {
        XCTAssertNotNil(cloudDocs)
        XCTAssertNotNil(mockFileManager)
        let urlThatExists = mockFileManager!
            .containerURL!
            .appendingPathComponent("Documents")
            .appendFile(name: "file-1", fileExtension: "cloudy")
        mockFileManager!.addContentToDirectory(url:urlThatExists)
        let file = CloudyFile(name: "namer")
        do {
            _ = try cloudDocs!._createFile(fileName: "file-1",
                                           fileExtension: "cloudy",
                                           content: file,
                                           force: false)
        } catch {
            XCTAssertEqual(error.localizedDescription,
                           CloudDocs.CloudDocsError.fileAllreadyExists.localizedDescription)
        }
    }

    func testCreateFolderIfNotExistsCreated() {
        XCTAssertNotNil(cloudDocs)
        XCTAssertNotNil(mockFileManager)
        let containerUrl = mockFileManager!.containerURL!.appendingPathComponent("NotDocuments")
        let folderState = try! cloudDocs!.createFolderIfNotExists(from: containerUrl)
        XCTAssertEqual(folderState, .created)
    }

    func testCreateFolderIfNotExistsExists() {
        XCTAssertNotNil(cloudDocs)
        XCTAssertNotNil(mockFileManager)
        let containerUrl = mockFileManager!.containerURL!.appendingPathComponent("Documents")
        let folderState = try! cloudDocs!.createFolderIfNotExists(from: containerUrl)
        XCTAssertEqual(folderState, .exists)
    }

    static var allTests = [
        ("test_createFile", test_createFile),
        ("test_createFileThrowsNoFolderFoundError", test_createFileThrowsNoFolderFoundError),
        ("test_createFileThrowsFileExistsError", test_createFileThrowsFileExistsError),
        ("testCreateFolderIfNotExistsCreated", testCreateFolderIfNotExistsCreated),
        ("testCreateFolderIfNotExistsExists", testCreateFolderIfNotExistsExists)
    ]

}
