//
//  HoneyBeeTestAppTests.swift
//  HoneyBeeTestAppTests
//
//  Created by Alex Lynch on 2/14/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
@testable import HoneyBeeTestApp
import HoneyBee

class HoneyBeeTestAppTests: XCTestCase {
    
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
		
		
		HoneyBee.start(with: 4) { root in
			root.chain(intToString)
				.chain(stringToInt, fail)
				.chain(multiplyInt)
				.chain(assertEquals(8))
				.chain(expect.fulfill)
		}
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
			root.chain(randomInt)
				.chain(intToString)
				.chain(stringCat)
				.chain(stringToInt) {error in expect.fulfill()}
				.chain(multiplyInt)
				.value(Void())
				.chain(failIfReached)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFork() {
		let expect1 = expectation(description: "First fork should be reached")
		let expect2 = expectation(description: "Second fork should be reached")
		
		
		HoneyBee.start(with: 10) { root in
			root.chain(intToString)
				.chain(stringToInt) {error in stdHandleError(error)}
				.fork { ctx in
					ctx.chain(assertEquals(10))
						.chain(expect1.fulfill)
					
					ctx.chain(multiplyInt)
						.chain(assertEquals(20))
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
		
		
		HoneyBee.start { root in
			root.fork { ctx in
				let result1 = ctx.chain(constantInt)
					.joinPoint()
				
				let result2 = ctx.chain(constantString)
					.joinPoint()
				
				result2.conjoin(result1)
					.chain(multiplyString)
					.chain(stringCat)
					.chain(assertEquals("lamblamblamblamblamblamblamblambcat"))
					.chain(expectA.fulfill)
			}
		}
		
		HoneyBee.start { root in
			root.fork { ctx in
				let result1 = ctx.chain(constantInt)
					.joinPoint()
				
				let result2 = ctx.chain(constantString)
					.joinPoint()
				
				result1.conjoin(result2)
					.chain(stringLengthEquals)
					.chain(assertEquals(false))
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
		
		let source = Array(0...10)
		for int in source {
			intsToExpectations[int] = expectation(description: "Expected to map value for \(int)")
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start(with: source) { root in
			root.map(multiplyInt)
				.each { ctx in
					ctx.chain { (int:Int) -> Void in
						let sourceValue = int/2
						if let exepct = intsToExpectations[sourceValue]  {
							exepct.fulfill()
						} else {
							XCTFail("Map source value not found \(sourceValue)")
						}
					}
				}
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
		
		HoneyBee.start(with:source, on: DispatchQueue.main) { root in
			root.map { (int:Int) -> Int in
					XCTAssert(Thread.current.isMainThread, "Not main thread")
					return int*2
				}
				.value(Void())
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
		
		HoneyBee.start(with:source) { root in
			root.filter(isEven)
				.chain(Array.sorted)
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
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start(with:expectations) { root in
			root.each { ctx in
				ctx.chain(XCTestExpectation.fulfill)
				   .chain { () -> Void in
						countLock.lock()
						filledExpectationCount += 1
						countLock.unlock()
					}
				}
				.chain { () -> Void in
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
	
	func testMultiParams() {
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start(with: "leg,foot") { root in
			root.chain(decompose)
				.chain(returnLonger)
				.chain(assertEquals("foot"))
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
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

func assertEquals<T: Equatable>(_ t: T) -> (T) -> Void {
	return { otherT in
		XCTAssert(t == otherT, "Expected \(t) to equal \(otherT)")
	}
}

// mock functions

func multiplyInt(int: Int) -> Int {
	return int * 2
}

func stringCat(string: String) -> String {
	return "\(string)cat"
}

func dangerous() throws -> Int {
	return try stringToInt(string: "27")
}

func stringToInt(string: String) throws -> Int {
	if let int = Int(string) {
		return int
	} else {
		throw NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
	}
}

func intToString(int: Int, callback: (String) -> Void) {
	return callback("\(int)")
}

func constantInt() -> Int {
	return 8
}

func constantString() -> String {
	sleep(2)
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

func stdHandleError(_ error: Error) {
	print("Error: \(error)")
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
