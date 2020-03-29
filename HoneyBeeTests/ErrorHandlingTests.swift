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
		
		HoneyBee.functionOvercallResponse = .fail
		HoneyBee.functionUndercallResponse = .fail
		HoneyBee.internalFailureResponse = .fail
		HoneyBee.mismatchedConjoinResponse = .fail
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testErrorHandling() {
		let expect = expectation(description: "Chain should fail with error")
		
		HoneyBee.start()
				.insert(self.funcContainer)
				.chain(TestingFunctions.randomInt)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringCat).drop
				.chain(self.funcContainer.explode)
				.chain(self.funcContainer.multiplyInt).drop
				.chain(failIfReached)
                .onError { _ in expect.fulfill() }
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testRetryNoReturn() {
		let finalErrorExpectation = expectation(description: "Chain should fail with error")
		
		let retryCount = 3
		let retryExpectation = expectation(description: "Chain should retry \(retryCount) time")
		retryExpectation.expectedFulfillmentCount = retryCount + 1
		
		HoneyBee.start()
				.insert(self.funcContainer)
				.chain(TestingFunctions.randomInt)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringCat)
				.retry(retryCount) { link in
					link.drop
						.chain(retryExpectation.fulfill)
						.chain(self.funcContainer.explode)
						.chain(self.funcContainer.multiplyInt)
				}
                .onError {_ in finalErrorExpectation.fulfill()}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testRetryReturnSuccess() {
		let finishExpectation = expectation(description: "Chain should finish")
		
		let retryCount = 3
		let retryExpectation = expectation(description: "Chain should retry \(retryCount) time")
		retryExpectation.expectedFulfillmentCount = 2
		
		var failed = false
		
		HoneyBee.start()
                .insert(self.funcContainer)
				.chain(self.funcContainer.constantInt)
				.retry(retryCount) { link in
					link.tunnel { link in
							link.drop
								.chain(retryExpectation.fulfill)
								.chain{
									if !failed {
										failed = true
										throw SimpleError.error
									}
								}
						}
						.chain(self.funcContainer.multiplyInt)
				}
				.chain(self.funcContainer.multiplyInt)
				.chain(assertEquals =<< 32).drop
				.chain(finishExpectation.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testRetryReturn() {
		let finalErrorExpectation = expectation(description: "Chain should fail with error")
		
		let retryCount = 3
		let retryExpectation = expectation(description: "Chain should retry \(retryCount) time")
		retryExpectation.expectedFulfillmentCount = retryCount + 1
		
		HoneyBee.start()
                .insert(self.funcContainer)
				.chain(TestingFunctions.randomInt)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringCat)
				.retry(retryCount) { link in
					link.drop
						.chain(retryExpectation.fulfill)
						.chain(self.funcContainer.explode)
						.chain(self.funcContainer.multiplyInt)
				}
				.chain(self.funcContainer.multiplyInt)
                .onError { _ in finalErrorExpectation.fulfill() }
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testErrorContext() {
		let expect = expectation(description: "Chain should fail with error")
		var expectedFile: StaticString! = nil
		var expectedLine: UInt! = nil
		
		func errorHanlderWithContext(context: ErrorContext) {
			if let subjectString = context.subject as? String  {
				XCTAssert(subjectString == "7cat")
				if let expectedFile = expectedFile, let expectedLine = expectedLine {
                    XCTAssertEqual(context.trace.lastFile.description, expectedFile.description)
                    XCTAssertEqual(context.trace.lastLine, expectedLine)
				} else {
					XCTFail("expected variables not setup")
				}
				
				expect.fulfill()
			} else {
				XCTFail("Subject is of unexpected type: \(context.subject)")
			}
		}
		
		HoneyBee.start()
                .insert(7)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringCat)
				.chain{(string:String) -> String in expectedFile = #file; expectedLine = #line; return string}.chain(self.funcContainer.stringToInt)
				.chain(self.funcContainer.multiplyInt).drop
				.chain(failIfReached)
                .onError(errorHanlderWithContext)
		
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
            lock.lock()
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
                lock.unlock()
				completion(iteration)
			}
		}
		
		let finishExpectation = expectation(description: "Should reach NOT the end of the chain")
		finishExpectation.isInverted = true
		
		let errorCount = source.count
		let errorExpectation = expectation(description: "Should error \(errorCount) times")
		errorExpectation.expectedFulfillmentCount = errorCount

        let finalErrorExepectation = expectation(description: "Final error should happen once")
		
		HoneyBee.start()
                .insert(source)
				.each(limit: 5) { elem in
					elem.chain(asynchronouslyHoldLock)
						.chain(self.funcContainer.explode)
                        .onError  { _ in errorExpectation.fulfill()}
				}
				.drop
				.chain(finishExpectation.fulfill)
                .onError  { _ in finalErrorExepectation.fulfill()}
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 1.0))
	}
	
	func testLimitError() {
		let source = Array(0..<3)
        let intFilter = { (i:Int) -> Bool in i < 2 }
        let invertedIntFilter = { (i:Int) -> Bool in !intFilter(i) }
		
		let successExpectation = expectation(description: "Success mark")
		successExpectation.expectedFulfillmentCount = source.filter(invertedIntFilter).count
		
        let failureExpectation = expectation(description: "Error handler")
        failureExpectation.expectedFulfillmentCount = source.filter(intFilter).count

        let finalExpectation = expectation(description: "Chain should complete")

        var passCounter = -1
        HoneyBee.start()
                .insert(source)
                .each(acceptableFailure: .full) { int -> Link<Void, DefaultDispatchQueue> in
                    let a = int.limit(1) { link -> Link<Void, DefaultDispatchQueue> in
                        passCounter += 1
                        if intFilter(passCounter) {
                            return link.insert(self.funcContainer)
                                .chain(TestingFunctions.explode) // error here
                                .chain(assertEquals =<< Int.max).drop

                        } else {
                            return link.drop
                                .chain(successExpectation.fulfill).drop
                        }
                    }

                    a.onError { (_:Error) in failureExpectation.fulfill() }
                    return a
                }.drop
                .chain(finalExpectation.fulfill)

		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testJoinError() {
		let expectNumberOfTests = expectation(description: "two tests should be run")
		expectNumberOfTests.expectedFulfillmentCount = 2
		
		func testJoinError<X>(with customConjoin: @escaping (Link<String, DefaultDispatchQueue>, Link<Int, DefaultDispatchQueue>) -> Link<X, DefaultDispatchQueue>) {
			expectNumberOfTests.fulfill()
			
			let expectFinnally = expectation(description: "finnally should be reached")
			expectFinnally.expectedFulfillmentCount = 3
			let expectError = expectation(description: "Error should occur once")
			
			let sleepTime:UInt32 = 1
			
			func errorHandler(_ error: Error) {
				expectError.fulfill()
			}
			
			func excerciseFinally(_ link: Link<Void, DefaultDispatchQueue>) {
				let a = link.insert("a")
				let b = link.insert("b")
				(a + b)
					.chain(<)
					.chain(assertEquals =<< true)
					.chain(expectFinnally.fulfill)
			}
		
			HoneyBee.start()
					.finally { link in
						excerciseFinally(link)
					}
					.branch { stem in
						let result1 = stem.finally { link in
										excerciseFinally(link)
									}
									.chain(self.funcContainer.constantInt)
						
						let result2 = stem.chain(sleep =<< sleepTime).drop
							.chain(self.funcContainer.explode).drop
							.chain(failIfReached)
							.chain(self.funcContainer.constantString)
						
						
						let downstreamLink = stem.finally { link in
							excerciseFinally(link)
						}
						let joinedLink = customConjoin(result2,result1)
						
						let _ = joinedLink.drop
								.conjoin(downstreamLink)
                                .onError(errorHandler)
                    }

		}
		
		testJoinError { (getString, getInt) in
			return (getInt + getString)
						.chain(self.funcContainer.stringLengthEquals)
		}
		
		testJoinError { (getString, getInt) in
			return (getString + getInt)
					.chain(self.funcContainer.multiplyString)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testJoinWithMapError() {
		
		let expectFinnally = expectation(description: "finnally should be reached")
		expectFinnally.expectedFulfillmentCount = 2
		let expectError = expectation(description: "Error should occur once")
		
		let sleepTime:UInt32 = 1
		
		func errorHandler(_ error: Error) {
			expectError.fulfill()
		}
		
		HoneyBee.start()
                .finally { link in
					link.chain(expectFinnally.fulfill)
				}
				.branch { stem in
					let result1 = stem.finally { link in
						link.chain(expectFinnally.fulfill)
						}
						.chain(self.funcContainer.constantInt)
					
					let result2 = stem.chain(sleep =<< sleepTime).drop
						.chain(self.funcContainer.explode).drop
						.insert(["contents don't matter"])
						.map { link in
							link.chain(self.funcContainer.stringToInt)
						}
						.drop
						.chain(failIfReached)
						.chain(self.funcContainer.constantString)
					
					
					
					(result1 + result2)
						.chain(self.funcContainer.stringLengthEquals)
                        .onError(errorHandler)
                }

		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMapWithErrors() {
		
		func doTest(withAcceptableFailureCount failures: Int) {
		
			var intsToExpectations:[Int:XCTestExpectation] = [:]
			
			let source = Array(0..<12)
			let numberOfElementErrors = source.filter({ $0 >= 10}).count
			
			for int in source {
				if int < 10 {
					intsToExpectations[int] = expectation(description: "Expected to map value for \(int)")
				} else {
					intsToExpectations[int] = expectation(description: "Should not map value for \(int)")
					intsToExpectations[int]!.isInverted = true
				}
			}
			
			let finishExpectation:XCTestExpectation
			if failures < numberOfElementErrors {
				finishExpectation = expectation(description: "Should not reach the end of the chain")
				finishExpectation.isInverted = true
			} else {
				finishExpectation = expectation(description: "Should reach the end of the chain")
			}
			
			func failableIntConverter(_ int: Int) throws -> String {
				if int / 10 == 0 {
					return String(int)
				} else {
					throw SimpleError.error
				}
			}
			
			let errorExpectation = expectation(description: "Chain should error")
			
			errorExpectation.expectedFulfillmentCount = numberOfElementErrors + (failures < numberOfElementErrors ? 1 : 0)
			
			func errorHandler(_ error: Error) {
				errorExpectation.fulfill()
			}
			
			HoneyBee.start()
					.insert(source)
					.map(acceptableFailure: .count(failures)) { elem in
						elem.chain(failableIntConverter)
							.tunnel { link in
								link.chain { (string: String) -> Void in
									intsToExpectations[Int(string)!]!.fulfill()
								}
							}.onError(errorHandler)
					}
					.chain { (strings: [String]) -> Void in
						let expected = ["0","1","2","3","4","5","6","7","8","9"]
						XCTAssert(strings == expected, "Expected \(strings) to equal \(expected)")
					}
					.drop
					.chain(finishExpectation.fulfill)
                    .onError(errorHandler)
			
			waitForExpectations(timeout: 0.33333) { error in
				if let error = error {
					XCTFail("waitForExpectationsWithTimeout errored: \(error)")
				}
			}
		}
		
		doTest(withAcceptableFailureCount: 0)
		doTest(withAcceptableFailureCount: 1)
		doTest(withAcceptableFailureCount: 2)
	}
	
	func testFilterWithError() {
		let source = Array(0...10)
		let result = [0,2,4,6,8] // we're going to lose one to an error
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		let errorExpectation = expectation(description: "Chain should error")
		errorExpectation.expectedFulfillmentCount = 1
		
		func errorHandlder(_ error: Error) {
			errorExpectation.fulfill()
		}
		
		HoneyBee.start()
                .insert(source)
				.filter(acceptableFailure: .ratio(0.1)) { elem in
					elem.tunnel { link in
						link.chain { (int:Int) throws -> Void in
							if int > 9 {
								throw SimpleError.error
							}
						}
					}
					.chain(self.funcContainer.isEven)
                    .onError(errorHandlder)
				}
				.chain{ XCTAssert($0 == result, "Filter failed. expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testLinearReduceWithError() {
		func doTest() {
			let source = Array(0...10)
			let result = 45 // we're going to lose 10 to an error.
			
			let finishExpectation = expectation(description: "Should reach the end of the chain")
			
			let errorExpectation = expectation(description: "Chain should error")
			
			func errorHandler(_ error: Error) {
                XCTAssert(error is SimpleError)
				errorExpectation.fulfill()
			}
			
			HoneyBee.start()
					.insert(source)
					.reduce(with: 0, acceptableFailure: .ratio(0.1)) { elem in
						elem.tunnel { link in
							link.chain { (_: Int, int:Int) throws -> Void in
								if int > 9 {
                                    XCTAssertEqual(int, 10)
									throw SimpleError.error
								}
							}
						}
						.chain(+)
                        .onError(errorHandler)
					}
					.chain{ (int: Int)-> Void in
						XCTAssert(int == result, "Reduce failed. Expected: \(result). Received: \(int).")
					}
					.chain(finishExpectation.fulfill)
			
            waitForExpectations(timeout: 0.33333) { error in
				if let error = error {
					XCTFail("waitForExpectationsWithTimeout errored: \(error)")
				}
			}
			
		}
		
		for _ in 0..<50 {
			doTest()
		}
		
	}
	
	func testParallelReduceWithError() {
		let source = Array(0...10)
		let sum = source.reduce(0, +)

		let finallyExpectation = expectation(description: "Should reach the the finally")
		
		let errorExpectation = expectation(description: "Chain should error")
		errorExpectation.expectedFulfillmentCount = 2
		
		func errorHandler(_ error: Error) {
			errorExpectation.fulfill()
		}
		
		HoneyBee.start()
                .insert(source)
				.finally { link in
					link.drop
						.chain(finallyExpectation.fulfill)
				}
				.reduce { pair in
					pair.tunnel { link in
						link.chain { (int1: Int, int2:Int) throws -> Void in
							if int1+int2 == sum {
								throw SimpleError.error
							}
						}
					}
					.chain(+)
                    .onError(errorHandler) //†
				}
				.chain{ (_:Int) -> Void in /* unreachable */ }
                .onError(errorHandler) //†

        // † Because this reduce has zero acceptable failure (the default)
        // the error handler, when applied both inside the reduce and outside the reduce
        // receives the same error, two times.
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testCompletionHandler() {
		let expect1 = expectation(description: "Chain should error only once")
		
		func errorHandler(_ error: Error?) {
			if error != nil{
				expect1.fulfill()
			} else {
				XCTFail("Success state should not be reached.")
			}
		}
		
		let a = HoneyBee.start()
				.insert(4)
				.chain(self.funcContainer.intToString)
		let b = a.chain(self.funcContainer.stringToInt)
                .chain(self.funcContainer.multiplyInt)


        let c = b.chain(self.funcContainer.explode)
                    .chain(assertEquals =<< 8)

        let d = b.chain(self.funcContainer.explode)
                    .chain(assertEquals =<< 8)

        (c+d).onError(errorHandler)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testResultChains() {
		let expect1 = expectation(description: "Chain 1 should complete")
		let expect2 = expectation(description: "Chain 2 should complete")
		
		let generator = FibonaciGenerator()
		HoneyBee.start()
                .insert(generator)
                .chain(FibonaciGenerator.ready)
                .chain(assertEquals =<< true)
                .chain(expect1.fulfill)
                .onError(fail)
		
		HoneyBee.start()
				.insert(generator)
				.chain(FibonaciGenerator.next)
				.chain(assertEquals =<< 1)
				.chain(expect2.fulfill)
                .onError(fail)
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}

