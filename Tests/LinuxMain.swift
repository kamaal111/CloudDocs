import XCTest

import CloudDocsTests

var tests = [XCTestCaseEntry]()
tests += ICloudDocsTests.allTests()
tests += MockFileManagerTests.allTests()
tests += ExtensionsTests.allTests()
tests += CloudyFileTests.allTests()

XCTMain(tests)
