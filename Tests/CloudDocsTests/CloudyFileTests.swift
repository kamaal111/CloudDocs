//
//  CloudyFileTests.swift
//  
//
//  Created by Kamaal Farah on 08/11/2020.
//

import XCTest

final class CloudyFileTests: XCTest {

    func testCloudyFileNameHasBeenSet() {
        let file = CloudyFile(name: "namer")
        XCTAssertEqual(file.name, "namer")
    }

    static var allTests = [
        ("testCloudyFileNameHasBeenSet", testCloudyFileNameHasBeenSet),
    ]

}

struct CloudyFile: Codable {
    let name: String
}
