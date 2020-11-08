import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ICloudDocsTests.allTests),
        testCase(MockFileManagerTests.allTests),
        testCase(ExtensionsTests.allTests),
        testCase(CloudyFileTests.allTests),
    ]
}
#endif
