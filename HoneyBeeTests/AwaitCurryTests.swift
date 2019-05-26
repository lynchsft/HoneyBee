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
	
	private var filename: String {
		return  URL(fileURLWithPath: #file).lastPathComponent
	}
	
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
	
	func testErrorContext() {
		let expect = expectation(description: "Chainshould complete")
		
		func handleError(_ context: ErrorContext) {
//			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: self.filename)
			XCTAssertEqual(chains.count, 7)
			expect.fulfill()
		}
		
		let a = HoneyBee.start().handlingErrors(with: handleError)
		
		let r1 = a.await(increment)(3)
		let r2 = a.await(increment)(val: r1)
		let r3 = a.await(increment(val:))(val: r2)({
			$0/2
		})
		a.await(increment)(fox: r3)({
			XCTAssertEqual($0, 4)
		}).await(TestingFunctions().explode)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testErrorContext2() {
		let source = [1, 2, 3, 4, 5]
		let errorCount = source.count + 1
		let expect = expectation(description: "Chain should expload \(errorCount) times.")
		expect.expectedFulfillmentCount = errorCount
		
		let finalExpect = expectation(description: "Chain should finalize")
		
		func shortError(_ context: ErrorContext) { // this one handles the error thrown by reduce(map) itself
//			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: self.filename)
			XCTAssertEqual(chains.count, 5) //"commands" + 1
			expect.fulfill()
		}
		
		func longError(_ context: ErrorContext) { // this one handles the errors thrown by `explode`.
//			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: self.filename)
			XCTAssertEqual(chains.count, 8) //"commands" + 1
			expect.fulfill()
		}
		
		do {
			let a = HoneyBee.start().handlingErrors(with: shortError).finally {
				$0.chain(finalExpect.fulfill)
			}
			
			let sum = a.insert(source)
				.map {
					a.await(increment)(val: $0)
				}
				.reduce(with: 0) {
					a.handlingErrors(with: longError)
						.await(+)(a: $0)
						.chain(increment)
						.await(TestingFunctions().explode)
				}
			
			sum.drop().chain(fail) // shouldn't run
		}
		
		waitForExpectations(timeout: 60) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testErrorContext3() {
		let expect = expectation(description: "Chainshould complete")
		
		func handleError(_ context: ErrorContext) {
			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: filename)
			XCTAssertEqual(chains.count, 7) // "commands" + 1
			expect.fulfill()
		}
		
		let a = HoneyBee.start().handlingErrors(with: handleError)
		
		let source = [1, 2, 3]
		let sum = a.insert(source)
			.map {
				a.await(increment)(val: $0)
			}.reduce(with: 0) {
				a.await(+)(a: $0)
			}
		
		a.await(increment)(val: sum)({
			XCTAssertEqual($0, 10)
		}).await(TestingFunctions().explode)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testErrorContext4() {
		let source = [1, 2, 3, 4, 5]
		let errorCount = source.count + 1
		let expect = expectation(description: "Chain should expload \(errorCount) times.")
		expect.expectedFulfillmentCount = errorCount
		
		let finalExpect = expectation(description: "Chain should finalize")
		
		func shortError(_ context: ErrorContext) { // this one handles the error thrown by map itsself
//			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: self.filename)
			XCTAssertEqual(chains.count, 4) //"commands" + 1
			expect.fulfill()
		}
		
		func longError(_ context: ErrorContext) { // this one handles the errors thrown by `explode`.
//			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: self.filename)
			XCTAssertEqual(chains.count, 6) //"commands" + 1
			expect.fulfill()
		}
		
		do {
			let a = HoneyBee.start().handlingErrors(with: shortError).finally {
				$0.chain(finalExpect.fulfill)
			}
		
			let mapping = a.insert(source)
				.map {
					a.handlingErrors(with: longError)
						.await(increment)(val: $0)
						.await(TestingFunctions().explode)
			}
			
			mapping.drop().chain(fail) // shouldn't run
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}
