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
		
		let ctx = HoneyBee.start().handlingErrors(with: handleError)
		
		ctx.await(User.reset)[.any][5][{
			print($0)
		}]
//		ctx.await(User.reset)[.any](7) // segfault
		
		ctx.await(User.login)["Fred"][17]

		ctx.await(User.login)["Fred"][17]
			.await(expect1.fulfill)

		ctx.await(addTogether)(one: 1)(two: 3.5)
			.await(addTogether)(1)(3.5)
			.await(addTogether)(1)(3.5)

		let a = ctx.await(increment)(3)
		let b = ctx.await(increment)(val: a)
		let c = ctx.await(increment(val:))(val: b)({
			$0/2
		})
		ctx.await(increment)(fox: c).chain { (int:Int) -> Void in
			XCTAssertEqual(int, 4)
			expect2.fulfill()
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}
