//
//  AsyncCurryTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import XCTest
import Foundation
import HoneyBee

func increment(val: Int) -> Int {
	return val + 1
}

func addTogether(one: Int, two: Double) throws -> Double {
	return Double(one) + two
}

enum User {
	case any
	func reset(in seconds: Int) {
		
	}
	
	static func login(username: String, age: Int, completion: ((Error?) -> Void)?) {
		DispatchQueue.global().async {
			sleep(1)
			//completion?(NSError(domain: "Foo", code: -1, userInfo: nil))
			completion?(nil)
		}
	}
}

class AsyncCurryTests: XCTestCase {
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testBatch() {
		let expect1 = expectation(description: "Chain 1 should complete")
		let expect2 = expectation(description: "Chain 2 should complete")
		
		func handleError(_ context: ErrorContext) {
			print(context)
			fail(on: context.error)
		}
		
		let a = HoneyBee.start().handlingErrors(with: handleError)
		
		a.await(User.reset)[.any][5][{
			print($0)
		}]
//		c.await(User.reset)[.any](5) // segfault
		
		a.await(User.login)["Fred"][17].mute

		a.await(User.login)["Fred"][17]
			.await(expect1.fulfill)

		a.await(addTogether)(one: 1)(two: 3.5)
			.await(addTogether)(1)(3.5)
			.await(addTogether)(1)(3.5)

		let r1 = a.await(increment)(3)
		let r2 = a.await(increment)(val: r1)
		let r3 = a.await(increment(val:))(val: r2)({
			$0/2
		})
		a.await(increment)(fox: r3)({
			XCTAssertEqual($0, 4)
		}).await(expect2.fulfill)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}
