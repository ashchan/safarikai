//
//  SafarikaiEngineTests.swift
//  SafarikaiEngineTests
//
//  Created by James Chen on 2018/10/05.
//  Copyright © 2018 ashchan.com. All rights reserved.
//

import XCTest
@testable import SafarikaiEngine

class SafarikaiEngineTests: XCTestCase {
    func testLoadDictAsync() {
        measure {
            Dict().load(async: true)
        }
    }

    func testLoadDictSync() {
        measure {
            Dict().load(async: false)
        }
    }

    func testLookup() {
        let dict = Dict()
        dict.load(async: false)
        var (results, match) = dict.search("台風")
        (results, match) = dict.search("呼びかけています")
        (results, match) = dict.search("あわせて読みたい")
        (results, match) = dict.search("いずれも")
        (results, match) = dict.search("に")
        (results, match) = dict.search("")
        XCTAssertTrue(results.count == 0)
        XCTAssertNil(match)
        (results, match) = dict.search("高さ")
        XCTAssertTrue(results.count > 0)
        (results, match) = dict.search("寿司")
        XCTAssertTrue(results.count > 1)
    }

    func testConvertEdict2u() {
        Dict.convertEdict2()
    }
}
