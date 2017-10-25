//
//  ErrorHandlingTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 10/24/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

import XCTest
import HoneyBee

class ErrorHandlingTests: XCTestCase {
	let funcContainer = TestingFunctions()
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testErrorHandling() {
		let expect = expectation(description: "Chain should fail with error")
		
		HoneyBee.start { root in
			root.setErrorHandler {error in expect.fulfill()}
				.insert(self.funcContainer)
				.chain(TestingFunctions.randomInt)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringCat)
				.drop()
				.chain(self.funcContainer.explode)
				.chain(self.funcContainer.multiplyInt)
				.drop()
				.chain(failIfReached)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFinallyError() {
		var counter = 0
		let incrementCounter = { counter += 1 }
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		func handleError(_ error: Error, arg: Any) {} // we cause an error on purpose
		
		HoneyBee.start { root in
			root.setErrorHandler(fail) // this is just to start off with. We update the error handler below
				.finally { link in
					link.chain { () -> Void in XCTAssert(counter == 2, "counter should be 2") ; finishExpectation.fulfill() }
				}
				.chain{ XCTAssert(counter == 0, "counter should be 0") }
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 1, "counter should be 1") }
				.chain(incrementCounter)
				.setErrorHandler(handleError)
				.chain({ throw NSError(domain: "An expected error", code: -1, userInfo: nil) })
				.chain(incrementCounter)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testErrorContext() {
		let expect = expectation(description: "Chain should fail with error")
		var expectedFile: StaticString! = nil
		var expectedLine: UInt! = nil
		
		func errorHanlderWithContext(_ error: Error, context: ErrorContext) {
			if let subjectString = context.subject as? String  {
				XCTAssert(subjectString == "7cat")
				if let expectedFile = expectedFile, let expectedLine = expectedLine {
					XCTAssertEqual(context.file.description, expectedFile.description)
					XCTAssertEqual(context.line, expectedLine)
				} else {
					XCTFail("expected variables not setup")
				}
				
				expect.fulfill()
			} else {
				XCTFail("Subject is of unexpected type: \(context.subject)")
			}
		}
		
		HoneyBee.start { root in
			root.setErrorHandler(errorHanlderWithContext)
				.insert(7)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringCat)
				.chain{(string:String) -> String in expectedFile = #file; expectedLine = #line; return string}.chain(self.funcContainer.stringToInt)
				.chain(self.funcContainer.multiplyInt)
				.drop()
				.chain(failIfReached)
		}
		
		waitForExpectations(timeout: 2) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testEachWithLimitErroring() {
		let source = Array(0..<20)
		let sleepSeconds = 0.1
		
		let lock = NSLock()
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Int)->Void) {
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				completion(iteration)
			}
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let errorExpectation = expectation(description: "Should error \(source.count) times")
		errorExpectation.expectedFulfillmentCount = source.count
		
		HoneyBee.start { root in
			root.setErrorHandler { _ in errorExpectation.fulfill()}
				.insert(source)
				.each(withLimit: 5) { elem in
					elem.chain(asynchronouslyHoldLock)
						.chain(self.funcContainer.explode)
				}
				.drop()
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 1.0)) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testLimitError() {
		let source = Array(0..<3)
		
		let successExpectation = expectation(description: "Should success mark")
		successExpectation.expectedFulfillmentCount = source.count
		
		for i in 0..<3 {
			let failureExpectation = expectation(description: "Should reach the error handler")
			if i < 2 {
				failureExpectation.expectedFulfillmentCount = source.count
			} else {
				failureExpectation.isInverted = true
			}
			
			HoneyBee.start { root in
				root.setErrorHandler { _ in failureExpectation.fulfill() }
					.insert(source)
					.each() { elem in
						elem.limit(1) { link -> ProcessLink<Void> in
							if i < 2 {
								return link.insert(self.funcContainer)
									.chain(TestingFunctions.explode) // chain errors here
									.chain(assertEquals =<< Int.max)
							} else {
								return link.drop()
									.chain(successExpectation.fulfill)
							}
						}
				}
			}
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testJoinError() {
		let expectNumberOfTests = expectation(description: "two tests should be run")
		expectNumberOfTests.expectedFulfillmentCount = 2
		
		func testJoinError(with customConjoin: @escaping (ProcessLink<String>, ProcessLink<Int>) -> Void) {
			expectNumberOfTests.fulfill()
			
			let expectFinnally = expectation(description: "Join should be reached, path A")
			expectFinnally.expectedFulfillmentCount = 2
			let expectError = expectation(description: "Error should occur once")
			
			let sleepTime:UInt32 = 1
			
			func errorHandler(_ error: Error) {
				expectError.fulfill()
			}
		
			HoneyBee.start { root in
				root.setErrorHandler(errorHandler)
					.finally { link in
						link.chain(expectFinnally.fulfill)
					}
					.branch { stem in
						let result1 = stem.finally { link in
										link.chain(expectFinnally.fulfill)
									}
									.chain(self.funcContainer.constantInt)
						
						let result2 = stem.chain(sleep =<< sleepTime)
							.drop()
							.chain(self.funcContainer.explode)
							.drop()
							.chain(failIfReached)
							.chain(self.funcContainer.constantString)
						
						
						customConjoin(result2,result1)
				}
			}
		}
		
		testJoinError { (getString, getInt) in
			(getInt + getString)
				.chain(self.funcContainer.stringLengthEquals)
		}
		
		testJoinError { (getString, getInt) in
			(getString + getInt)
				.chain(self.funcContainer.multiplyString)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}

