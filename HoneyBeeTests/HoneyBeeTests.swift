//
//  HoneyBeeTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 4/11/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee

class HoneyBeeTests: XCTestCase {
    
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testSimpleChain() {
		let expect = expectation(description: "Simple chain should complete")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(4)
				.chain(intToString)
				.chain(stringToInt)
				.chain(multiplyInt)
				.chain(assertEquals =<< 8)
				.chain(expect.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testOptionally() {
		let expect = expectation(description: "Expect should be reached")
		let optionalExpect = expectation(description: "Optional expect should be reached")
		
		var optionallyCompleted = false
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(Optional(7))
				.optionally { link in
					link.chain(assertEquals =<< 7)
						.chain(optionalExpect.fulfill)
						.chain{ optionallyCompleted = true }
				}
				.chain{ XCTAssert(optionallyCompleted, "Optionally chain should have completed by now") }
				.chain(expect.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testOptionallylNegative() {
		let expect = expectation(description: "Expect should be reached")
		let optionalExpect = expectation(description: "Optional expect should not be reached")
		optionalExpect.isInverted = true
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(Optional<Int>(nilLiteral: ()))
				.optionally { link in
					link.drop()
						.chain(optionalExpect.fulfill)
				}
				.chain(expect.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testErrorHandling() {
		let expect = expectation(description: "Chain should fail with error")
		
		
		HoneyBee.start { root in
			root.setErrorHandler {error in expect.fulfill()}
				.chain(randomInt)
				.chain(intToString)
				.chain(stringCat)
				.chain(stringToInt)
				.chain(multiplyInt)
				.drop()
				.chain(failIfReached)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFork() {
		let expect1 = expectation(description: "First branch should be reached")
		let expect2 = expectation(description: "Second branch should be reached")
		
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(10)
				.chain(intToString)
				.chain(stringToInt)
				.branch { stem in
					stem.chain(assertEquals =<< 10)
						.chain(expect1.fulfill)
					
					stem.chain(multiplyInt)
						.chain(assertEquals =<< 20)
						.chain(expect2.fulfill)
			}
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testJoin() {
		let expectA = expectation(description: "Join should be reached, path A")
		let expectB = expectation(description: "Join should be reached, path B")
		
		let sleepTime:UInt32 = 1
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.branch { stem in
				let result1 = stem.chain(constantInt)
				
				let result2 = stem.chain(sleep =<< sleepTime)
								  .drop()
								  .chain(constantString)
				
				(result2 + result1)
					.chain(multiplyString)
					.chain(stringCat)
					.chain(assertEquals =<< "lamblamblamblamblamblamblamblambcat")
					.chain(expectA.fulfill)
			}
		}
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.branch { stem in
				let result1 = stem.chain(constantInt)
				
				let result2 = stem.chain(sleep =<< sleepTime)
								  .drop()
								  .chain(constantString)
				
				(result1 + result2)
					.chain(stringLengthEquals)
					.chain(assertEquals =<< false)
					.chain(expectB.fulfill)
			}
		}
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMap() {
		var intsToExpectations:[Int:XCTestExpectation] = [:]
		
		let source = Array(0..<10)
		for int in source {
			intsToExpectations[int] = expectation(description: "Expected to map value for \(int)")
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(source)
				.map { elem in
					elem.chain(multiplyInt)
				}
				.each { elem in
					elem.chain { (int:Int) -> Void in
						let sourceValue = int/2
						if let exepct = intsToExpectations[sourceValue]  {
							exepct.fulfill()
						} else {
							XCTFail("Map source value not found \(sourceValue)")
						}
					}
				}
				.drop()
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMapQueue() {
		let source = Array(0...10)
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start(on: DispatchQueue.main) { root in
			root.setErrorHandler(fail)
				.insert(source)
				.map { elem in
					elem.chain{ (int:Int) -> Int in
						XCTAssert(Thread.current.isMainThread, "Not main thread")
						return int*2
					}
				}
				.drop()
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFilter() {
		let source = Array(0...10)
		let result = [0,2,4,6,8,10]
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(source)
				.filter { elem in
					elem.chain(isEven)
				}
				.chain{ XCTAssert($0 == result, "Filter failed. expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	
	func testEach() {
		var expectations:[XCTestExpectation] = []
		let countLock = NSLock()
		var filledExpectationCount = 0
		
		for int in 0..<10 {
			expectations.append(expectation(description: "Expected to evaluate \(int)"))
		}
		
		func incrementFullfilledExpectCount() {
			countLock.lock()
			filledExpectationCount += 1
			countLock.unlock()
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(expectations)
				.each { elem in
					elem.chain(XCTestExpectation.fulfill)
						.chain(incrementFullfilledExpectCount)
				}
				.drop()
				.chain {
					XCTAssert(filledExpectationCount == expectations.count, "All expectations should be filled by now, but was actually \(filledExpectationCount) != \(expectations.count)")
				}
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testEachWithRateLimiter() {
		var expectations:[XCTestExpectation] = []
		let countLock = NSLock()
		var filledExpectationCount = 0
		
		for int in 0..<10 {
			expectations.append(expectation(description: "Expected to evaluate \(int)"))
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		func incrementFullfilledExpectCount() {
			countLock.lock()
			filledExpectationCount += 1
			countLock.unlock()
		}
		
		func assertAllExpectationsFullfilled() {
			XCTAssert(filledExpectationCount == expectations.count, "All expectations should be filled by now, but was actually \(filledExpectationCount) != \(expectations.count)")
		}
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(expectations)
				.each { elem in
					elem.limit(3) { link in
						link.chain(XCTestExpectation.fulfill)
							.chain(incrementFullfilledExpectCount)
					}
				}
				.drop()
				.chain(assertAllExpectationsFullfilled)
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMultiParams() {
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert("leg,foot")
				.chain(decompose)
				.chain(returnLonger)
				.chain(assertEquals =<< "foot")
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testEachWithLimit() {
		let source = Array(0..<3)
		let sleepSeconds = 1
		
		let lock = NSLock()
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Int)->Void) {
			if !lock.try() {
				XCTFail("Lock should never be held at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				lock.unlock()
				completion(iteration)
			}
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(source)
				.each { elem in
					elem.limit(1) { link in
						link.chain(asynchronouslyHoldLock)
					}
				}
				.drop()
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: TimeInterval(source.count * sleepSeconds + 1)) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFinallyNoError() {
		var counter = 0
		let incrementCounter = { counter += 1 }
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.finally { link in
					link.chain { XCTAssert(counter == 3, "counter should be 3: was actually \(counter)") }
						.chain(incrementCounter)
				}.finally { link in
					link.chain { () -> Void in XCTAssert(counter == 4, "counter should be 4: was actually \(counter)") ; finishExpectation.fulfill() }
				}
				.chain{ XCTAssert(counter == 0, "counter should be 0") }
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 1, "counter should be 1") }
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 2, "counter should be 2") }
				.chain(incrementCounter)
		}
		
		waitForExpectations(timeout: 3) { error in
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
	
	func testLimit() {
		let source = Array(0..<3)
		let sleepNanoSeconds:UInt32 = 100
		
		let lock = NSLock()
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Int)->Void) {
			if !lock.try() {
				XCTFail("Lock should never be held at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				usleep(sleepNanoSeconds)
				lock.unlock()
				completion(iteration)
			}
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let startParalleCodeExpectation = expectation(description: "Should start parallel code")
		startParalleCodeExpectation.expectedFulfillmentCount = UInt(source.count)
		let finishParalleCodeExpectation = expectation(description: "Should finish parallel code")
		finishParalleCodeExpectation.expectedFulfillmentCount = UInt(source.count)
		var parallelCodeFinished = false
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(source)
				.each() { elem in
					elem.limit(1) { link in
						link.chain(asynchronouslyHoldLock)
							.chain(asynchronouslyHoldLock)
							.chain(asynchronouslyHoldLock)
					}
					.drop()
					.chain(startParalleCodeExpectation.fulfill)
					// parallelize
					.chain{ _ in usleep(sleepNanoSeconds * 3) }
					.drop()
					.chain(finishParalleCodeExpectation.fulfill)
					.chain({parallelCodeFinished = true})
				}
				.drop()
				.chain{ XCTAssert(parallelCodeFinished, "the parallel code should have finished before this") }
				.chain(finishExpectation.fulfill)
		}
		
		let sleepSeconds = (Double(sleepNanoSeconds)/1000.0)
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds * 4.0 + 2.0)) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testLimitReturnChain() {
		let intermediateExpectation = expectation(description: "Should reach the intermediate end")
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		var intermediateFullfilled = false
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.limit(29) { link in
					link.insert("Right")
						.chain(stringCat)
						.drop()
						.chain(intermediateExpectation.fulfill)
						.chain{ intermediateFullfilled = true }
				}
				.chain{ XCTAssert(intermediateFullfilled, "Intermediate expectation not fullfilled") }
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMultipleCallback() {
		let finishExpectation = expectation(description: "Should finish chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.chain{ (callback: (FailableResult<Int>) -> Void) in
					callback(.success(1))
					callback(.success(2))
					callback(.failure(NSError(domain: "Purposeful error", code: 3, userInfo: nil)))
					callback(.failure(NSError(domain: "Purposeful error", code: 4, userInfo: nil)))
				}
				.chain(assertEquals =<< 1)
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testQueueChange() {
		let expect = expectation(description: "Simple chain should complete")
		
		func assertThreadIsMain(_ isMain: Bool){
			XCTAssert(Thread.isMainThread == isMain, "Thead-mainness expected to be \(isMain) but is \(Thread.isMainThread)")
		}
		
		HoneyBee.start(on: DispatchQueue.main) { root in
			root.setErrorHandler(fail)
				.insert(4)
				.chain(intToString)
				.drop()
				.chain(assertThreadIsMain =<< true)
				.setBlockPerformer(DispatchQueue.global())
				.chain(assertThreadIsMain =<< false)
				.setBlockPerformer(DispatchQueue.main)
				.chain(assertThreadIsMain =<< true)
				.chain(expect.fulfill)
		}
		
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
				.chain(intToString)
				.chain(stringCat)
				.chain{(string:String) -> String in expectedFile = #file; expectedLine = #line; return string}.chain(stringToInt)
				.chain(multiplyInt)
				.drop()
				.chain(failIfReached)
		}
		
		waitForExpectations(timeout: 2) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFailableResultChains() {
		let expect1 = expectation(description: "Chain 1 should complete")
		let expect2 = expectation(description: "Chain 2 should complete")
		
		let generator = FibonaciGenerator()
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(generator)
				.chain(FibonaciGenerator.ready)
				.chain(assertEquals =<< true)
				.chain(expect1.fulfill)
		}
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(generator)
				.chain(FibonaciGenerator.next)
				.chain(assertEquals =<< 1)
				.chain(expect2.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testTunnel() {
		let expectFinal = expectation(description: "Chain should complete")
		let expectTunnel = expectation(description: "Tunnel chain should complete")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(4)
				.tunnel { link in
					link.chain(intToString)
						.chain(assertEquals =<< "4")
						.chain(expectTunnel.fulfill)
				}
				.chain(multiplyInt)
				.chain(assertEquals =<< 8)
				.chain(expectFinal.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}

// test helper functions

func failIfReached() {
	XCTFail("This function should never be reached")
}

func assertEquals<T: Equatable>(t1: T, t2: T) -> Void {
	XCTAssert(t1 == t2, "Expected \(t1) to equal \(t2)")
}

// mock functions

func multiplyInt(int: Int) -> Int {
	return int * 2
}

func stringCat(string: String) -> String {
	return "\(string)cat"
}

func stringToInt(string: String, callback: ((FailableResult<Int>) -> Void)?) {
	if let int = Int(string) {
		callback?(.success(int))
	} else {
		let error = NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
		callback?(.failure(error))
	}
}

func intToString(int: Int, callback: (String) -> Void) {
	return callback("\(int)")
}

func constantInt(callback:(FailableResult<Int>)->Void) {
	callback(.success(8))
}

func constantString() -> String {
	return "lamb"
}

func randomInt() -> Int {
	return Int(arc4random())
}

func isEven(int: Int, callback:(Bool)->Void) -> Void {
	callback(int%2 == 0)
}

func randomInts(count: Int) -> [Int] {
	return Array(0..<count).map { _ in randomInt() }
}

func printAll(values: [Any]) {
	print(values)
}

func multiplyString(string: String, count: Int) -> String {
	var acc = ""
	for _ in 0..<count {
		acc.append(string)
	}
	return acc
}

func stringLengthEquals(length: Int, string: String) -> Bool {
	return string.characters.count == length
}

func decompose(string: String, callback:(String,String)->Void) {
	let comps = string.components(separatedBy: ",")
	callback(comps[0],comps[1])
}

func returnLonger(first: String, second: String) -> String {
	if first.characters.count > second.characters.count {
		return first
	} else {
		return second
	}
}

func fail(on error: Error) {
	XCTFail("Error occured during test \(error)")
}

class FibonaciGenerator {
	
	private var a = 0
	private var b = 1
	
	func ready(completion: ((FailableResult<Bool>) -> Void)) {
		completion(.success(true))
	}
	
	func next(completion: ((FailableResult<Int>) -> Void)? ) {
		let next = a + b
		a = b
		b = next
		completion?(.success(next))
	}
}

