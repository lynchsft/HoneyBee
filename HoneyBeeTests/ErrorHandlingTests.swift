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
		
		let hb = HoneyBee.start()

        let funcContainer = self.funcContainer >> hb

        let int = funcContainer.randomInt()
        let string = funcContainer.intToString(int)
        let intAgain = funcContainer.stringToInt(string)

        let explodedInt = intAgain <+ funcContainer.explode()
        let multiplied = funcContainer.multiplyInt(explodedInt)
        multiplied.drop
            .chain({ (_: Void) throws -> Void in
                failIfReached()
            })
            .onError { (_:Error) in expect.fulfill() }
		
		waitForExpectations(timeout: 1)
	}
	
	func testRetryNoReturn() {
		let finalErrorExpectation = expectation(description: "Chain should fail with error")

		let retryCount = 3
		let retryExpectation = expectation(description: "Chain should retry \(retryCount) time")
		retryExpectation.expectedFulfillmentCount = retryCount + 1

		let hb = HoneyBee.start()
        let funcContainer = self.funcContainer >> hb

        let int = funcContainer.randomInt()
        let string = funcContainer.intToString(int)
        let cat = funcContainer.stringCat(string)
                            .handleError(fail(on:))
                            .expect(NSError.self)


        cat.retry(retryCount) { link -> Link<Int, NSError, DefaultDispatchQueue> in
            retryExpectation.fulfill(link.drop)
            return funcContainer.explode()
        }
        .onError { (_: NSError) in finalErrorExpectation.fulfill()}

		waitForExpectations(timeout: 1)
	}

	func testRetryReturnSuccess() {
		let finishExpectation = expectation(description: "Chain should finish")

		let retryCount = 3
		let retryExpectation = expectation(description: "Chain should retry \(retryCount) time")
		retryExpectation.expectedFulfillmentCount = 2

		var failed = false

		let hb = HoneyBee.start()
        let funcContainer = self.funcContainer >> hb

        let int = funcContainer.constantInt()


				int.retry(retryCount) { link in
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

		waitForExpectations(timeout: 1)
	}

	func testRetryReturn() {
		let finalErrorExpectation = expectation(description: "Chain should fail with error")

		let retryCount = 3
		let retryExpectation = expectation(description: "Chain should retry \(retryCount) time")
		retryExpectation.expectedFulfillmentCount = retryCount + 1

        let hb = HoneyBee.start()
        let funcContainer = self.funcContainer >> hb

        let int = funcContainer.randomInt()
        let string = funcContainer.intToString(int)

        let cat = funcContainer.stringCat(string)
                    .handleError(fail(on:))
                    .expect(NSError.self)

		let explodedInt = cat.retry(retryCount) { link -> Link<Int, NSError, DefaultDispatchQueue> in
                    retryExpectation.fulfill(link.drop)
                    return funcContainer.explode()
				}

        funcContainer.multiplyInt(explodedInt)
                .onError { _ in finalErrorExpectation.fulfill() }

		waitForExpectations(timeout: 1)
	}

	func testErrorContext() {
		let expect = expectation(description: "Chain should fail with error")
		var expectedFile: StaticString! = nil
		var expectedLine: UInt! = nil

		func errorHanlderWithContext(context: ErrorContext<Error>) {
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

		let hb = HoneyBee.start()

        let seven = 7 >> hb
        let string = self.funcContainer.intToString(seven)
        let int = self.funcContainer.stringCat(string)
            .chain{ (v:String) -> String in expectedFile = #file; expectedLine = #line; return v} ; let intAgain = self.funcContainer.stringToInt(int)

        let multiplied = self.funcContainer.multiplyInt(intAgain)

        multiplied.drop
				.chain(failIfReached)
                .onError(errorHanlderWithContext)

		waitForExpectations(timeout: 2)
	}

	func testEachWithLimitErroring() {
		let source = Array(0..<20)
		let sleepSeconds = 0.1

		let lock = NSLock()

		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Result<Int,Never>)->Void) {
            lock.lock()
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
                lock.unlock()
                completion(.success(iteration))
			}
		}

		let finishExpectation = expectation(description: "Should reach NOT the end of the chain")
		finishExpectation.isInverted = true

		let errorCount = source.count
		let errorExpectation = expectation(description: "Should error \(errorCount) times")
		errorExpectation.expectedFulfillmentCount = errorCount

        let finalErrorExepectation = expectation(description: "Final error should happen once")

		let asynSource = HoneyBee.start()
                .insert(source)
                .expect(NSError.self)

		let finished = asynSource.each(limit: 5) { elem -> Link<Int, NSError, DefaultDispatchQueue> in
					let postLock = elem.chain(asynchronouslyHoldLock)
                    let exploded = self.funcContainer.explode(postLock.drop)
                                        .onError  { (_: NSError) in errorExpectation.fulfill() }
                    return exploded
				}
				.drop

        finishExpectation.fulfill(finished)
            .onError  { (_:Error) in finalErrorExepectation.fulfill()}

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
        let hb = HoneyBee.start()
        let asyncSource = (source >> hb).expect(NSError.self)

        let finished = asyncSource.each(acceptableFailure: .full) { (int: Link<Int, NSError, DefaultDispatchQueue>) -> Link<Void, NSError, DefaultDispatchQueue> in
                    let a = int.limit(1) { link -> Link<Void, NSError, DefaultDispatchQueue> in
                        passCounter += 1
                        let funcContainer = self.funcContainer >> link.drop
                        if intFilter(passCounter) {
                            let explode = funcContainer.explode() // error here
                            return explode.drop
                        } else {
                            return successExpectation.fulfill(link.drop)
                        }
                    }

                    a.onError { (_:NSError) in failureExpectation.fulfill() }
                    return a
                }.drop
        finalExpectation.fulfill(finished)

		waitForExpectations(timeout: 1)
	}

	func testJoinError() {
		let expectNumberOfTests = expectation(description: "two tests should be run")
		expectNumberOfTests.expectedFulfillmentCount = 2

		func testJoinError<X>(with customConjoin: @escaping (Link<String, Error, DefaultDispatchQueue>, Link<Int, Error, DefaultDispatchQueue>) -> Link<X, Error, DefaultDispatchQueue>) {
			expectNumberOfTests.fulfill()

			let expectFinnally = expectation(description: "finnally should be reached")
			expectFinnally.expectedFulfillmentCount = 3
			let expectError = expectation(description: "Error should occur once")

			let sleepTime:UInt32 = 1

			func errorHandler(_ error: Error) {
				expectError.fulfill()
			}

			func excerciseFinally(_ link: Link<Void, Never, DefaultDispatchQueue>) {
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
                        let intResult = self.funcContainer.constantInt(result1)

						let result2 = stem.chain(sleep =<< sleepTime).drop
                        let exploded = self.funcContainer.explode(result2.drop)
                                        .chain { _ in failIfReached() }
                        let stringResult = self.funcContainer.constantString(exploded.drop)


						let downstreamLink = stem.finally { link in
							excerciseFinally(link)
						}
						let joinedLink = customConjoin(stringResult,intResult)

						let _ = joinedLink.drop
                                .conjoin(downstreamLink.expect(Error.self))
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

		waitForExpectations(timeout: 3)
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
					let intResult = self.funcContainer.constantInt(stem.finally { link in
                            link.chain(expectFinnally.fulfill)
						})

					let result2 = stem.chain(sleep =<< sleepTime).drop
                    let exploded = self.funcContainer.explode(result2.drop)
						.insert(["contents don't matter"])
						.map { link in
							link.chain(self.funcContainer.stringToInt)
						}
						.drop
						.chain(failIfReached)

                    let stringResult = self.funcContainer.constantString(exploded)

					(intResult + stringResult)
						.chain(self.funcContainer.stringLengthEquals)
                        .onError(errorHandler)
                }


		waitForExpectations(timeout: 3)
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

            func failableIntConverter(_ int: Int, completion: @escaping (Result<String, SimpleError>) -> Void) {
				if int / 10 == 0 {
                    completion(.success(String(int)))
				} else {
                    completion(.failure(.error))
				}
			}

			let errorExpectation = expectation(description: "Chain should error")

			errorExpectation.expectedFulfillmentCount = numberOfElementErrors + (failures < numberOfElementErrors ? 1 : 0)

			func errorHandler(_ error: SimpleError) {
				errorExpectation.fulfill()
			}

			let hb = HoneyBee.start()

			let mappedValues = hb.insert(source)
                    .expect(SimpleError.self)
                    .map(acceptableFailure: .count(failures)) { (elem: Link<Int, SimpleError, DefaultDispatchQueue>) -> Link<String, SimpleError, DefaultDispatchQueue> in
						elem.chain(failableIntConverter)
							.tunnel { link in
								link.chain { (string: String) -> Void in
									intsToExpectations[Int(string)!]!.fulfill()
								}
							}.onError(errorHandler)
					}

            mappedValues.chain { (strings: [String]) -> Void in
						let expected = ["0","1","2","3","4","5","6","7","8","9"]
						XCTAssert(strings == expected, "Expected \(strings) to equal \(expected)")
					}
					.drop
					.chain(finishExpectation.fulfill)
                    .onError(errorHandler)

			waitForExpectations(timeout: 0.33333)
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

		func errorHandlder(_ error: SimpleError) {
			errorExpectation.fulfill()
		}

		HoneyBee.start()
                .insert(source)
                .expect(SimpleError.self)
				.filter(acceptableFailure: .ratio(0.1)) { elem in
                    let failableInt = elem.tunnel { link in
                        link.chain { (int:Int, completion: @escaping (Result<Void, SimpleError>) -> Void) in
							if int > 9 {
                                completion(.failure(.error))
                            } else {
                                completion(.success(()))
                            }
						}
					}
                    return self.funcContainer.isEven(failableInt)
                        .onError(errorHandlder)
				}
				.chain{ XCTAssert($0 == result, "Filter failed. expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)

		waitForExpectations(timeout: 3)
	}

	func testLinearReduceWithError() {
		func doTest() {
			let source = Array(0...10)
			let result = 45 // we're going to lose 10 to an error.

			let finishExpectation = expectation(description: "Should reach the end of the chain")

			let errorExpectation = expectation(description: "Chain should error")

			func errorHandler(_ error: SimpleError) {
				errorExpectation.fulfill()
			}

			HoneyBee.start()
					.insert(source)
                    .expect(SimpleError.self)
					.reduce(with: 0, acceptableFailure: .ratio(0.1)) { elem in
						elem.tunnel { link in
                            link.chain { (arg: (_: Int, int:Int), completion: @escaping (Result<Void, SimpleError>) -> Void) in
                                if arg.int > 9 {
                                    XCTAssertEqual(arg.int, 10)
                                    completion(.failure(.error))
                                } else {
                                    completion(.success(Void()))
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

		func errorHandler(_ error: SimpleError) {
			errorExpectation.fulfill()
		}

        do {
		HoneyBee.start()
                .insert(source)
                .expect(SimpleError.self)
				.finally { link in
					link.drop
						.chain(finallyExpectation.fulfill)
				}
				.reduce { pair in
					pair.tunnel { link in
                        link.chain { (arg: (int1: Int, int2:Int), completion: @escaping (Result<Void, SimpleError>) -> Void) in
                            if arg.int1+arg.int2 == sum {
                                completion(.failure(.error))
                            } else {
                                completion(.success(Void()))
                            }
						}
					}
					.chain(+)
                    .onError(errorHandler) //†
				}
				.chain{ (_:Int) -> Void in /* unreachable */ }
                .onError(errorHandler) //†
        }

        // † Because this reduce has zero acceptable failure (the default)
        // the error handler, when applied both inside the reduce and outside the reduce
        // receives the same error, two times.

		waitForExpectations(timeout: 3)
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

		let hb = HoneyBee.start()

        let string = self.funcContainer.intToString(4 >> hb)

		let int = self.funcContainer.multiplyInt(self.funcContainer.stringToInt(string))

        let c = self.funcContainer.explode(int.drop)
        let d = self.funcContainer.explode(int.drop)

        (c+d).onError(errorHandler)

		waitForExpectations(timeout: 3)
	}

	func testResultChains() {
		let expect1 = expectation(description: "Chain 1 should complete")
		let expect2 = expectation(description: "Chain 2 should complete")


		let hb = HoneyBee.start().expect(Error.self)
        let generator = FibonaciGenerator() >> hb
        let readyState = generator.ready()

        XCTAssertEqual(readyState, true >> hb)
                .chain(expect1.fulfill)
                .onError(fail)

        let int = generator.next()
        XCTAssertEqual(int, 1 >> hb)
				.chain(expect2.fulfill)
                .onError(fail)

		waitForExpectations(timeout: 1)
	}
}

