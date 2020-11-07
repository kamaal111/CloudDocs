import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ICloudDocsTests.allTests),
        testCase(MockFileManagerTests.allTests),
    ]
}
#endif
