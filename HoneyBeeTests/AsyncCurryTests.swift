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

struct User {
    
    var reset: SingleArgFunction<Int, Void> { async1(self.reset) }
	func reset(in seconds: Int) {
		
	}
	
    static let login = async2(User.login)
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
	
	func testErrorContext() {
		let explode = expectation(description: "Chain should explode")
        let successfulResult = expectation(description: "Successful result")
        let unsuccessfulResult = expectation(description: "Unsuccessful result")
		
		func handleError(_ context: ErrorContext) {
			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: "\n")
			XCTAssertEqual(chains.count, 7 + 1 /*for the trailing return*/)
			explode.fulfill()
		}
		
		let hb = HoneyBee.start()
        
        let r1 = increment(3)(hb)
        let r2 = increment(val: r1)
        let r3 = increment(val: r2)
        let r4 = increment(fox: r3).chain {
			XCTAssertEqual($0, 7)
        }
        r4.result { (result: Result<Int, Error>) in
            switch result {
            case .success(_):
                successfulResult.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        let error = TestingFunctions().explode(r4.drop)
        error.result { (result: Result<Int, ErrorContext>) in
            switch result {
            case .success(_):
                XCTFail()
            case let .failure(context):
                unsuccessfulResult.fulfill()
                handleError(context)
            }
        }
		
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
			let chains = traceString.components(separatedBy: "\n")
			XCTAssertEqual(chains.count, 9) //"commands" + 1 for the "+" (conjoin) and + 1 for the final newline
			expect.fulfill()
		}
		
		do {
			let a = HoneyBee.start().finally {
				$0.chain(finalExpect.fulfill)
			}
			
			let sum = a.insert(source)
				.map {
                    increment($0)
                }.reduce(with: 0) {
                    let value = $0.chain(+)
						.chain(increment)
						.insert(TestingFunctions()).explode()

                    value.error(longError)
                    return value
				}
            sum.error(shortError)
			sum.drop.chain(fail) // shouldn't run
		}
		
		waitForExpectations(timeout: 6) { error in
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
			let chains = traceString.components(separatedBy: "\n")
			XCTAssertEqual(chains.count, 8) // "commands" + 1
			expect.fulfill()
		}
		
		let a = HoneyBee.start()
		
		let source = [1, 2, 3]
		let sum = a.insert(source)
			.map {
                increment(val: $0)
			}.reduce(with: 0) {
				$0.chain(+)
			}
		
        increment(val: sum).chain {
			XCTAssertEqual($0, 10)
		}.chain(TestingFunctions().explode)
            .error(handleError)
		
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
			let chains = traceString.components(separatedBy: "\n")
			XCTAssertEqual(chains.count, 4) //"commands" + 1
			expect.fulfill()
		}
		
		func longError(_ context: ErrorContext) { // this one handles the errors thrown by `explode`.
//			print(context.trace.toString())
			let traceString = context.trace.toString()
			let chains = traceString.components(separatedBy: "\n")
			XCTAssertEqual(chains.count, 6) //"commands" + 1
			expect.fulfill()
		}
		
		do {
			let a = HoneyBee.start().finally {
				$0.chain(finalExpect.fulfill)
			}
		
			let mapping = a.insert(source)
                .map { (int: Link<Int, DefaultDispatchQueue>) -> Link<Int, DefaultDispatchQueue> in
                    let bigger = increment(int)

                    let explode = TestingFunctions().explode(bigger.drop)
                    explode.error(longError)
                    return explode
			}
			
			mapping.drop.chain(fail) // shouldn't run
            mapping.error(shortError)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}
