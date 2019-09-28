import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RxNetworkClientTests.allTests),
    ]
}
#endif
