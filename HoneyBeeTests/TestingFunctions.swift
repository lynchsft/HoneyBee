//
//  TestingFunctions.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 10/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee
import Foundation

func failIfReached() {
	XCTFail("This function should never be reached")
}

func assertEquals<T: Equatable>(t1: T, t2: T) -> Void {
	XCTAssert(t1 == t2, "Expected \(t1) to equal \(t2)")
}

enum SimpleError : Error {
	case error
}

class TestingFunctions : Equatable {
	static func == (lhs: TestingFunctions, rhs: TestingFunctions) -> Bool {
		return true // just a type check since we have no state
	}
	
	func multiplyInt(int: Int) -> Int {
		return int * 2
	}
	
	func stringCat(string: String, callback: (String?, Error?) -> Void) -> Void {
		callback("\(string)cat",nil)
	}
	
	#if swift(>=5.0)
	func stringToInt(string: String, callback: ((Result<Int, Error>) -> Void)?) {
		if let int = Int(string) {
			callback?(.success(int))
		} else {
			let error = NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
			callback?(.failure(error))
		}
	}
	#else
	func stringToInt(string: String, callback: ((FailableResult<Int>) -> Void)?) {
		if let int = Int(string) {
			callback?(.success(int))
		} else {
			let error = NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
			callback?(.failure(error))
		}
	}
	#endif
	
	func intToString(int: Int, callback: (String) -> Void) {
		return callback("\(int)")
	}
	
	func constantInt(callback:(FailableResult<Int>)->Void) {
		callback(.success(8))
	}
	
	func constantString(callback: ((String?, Error?) -> Void)? ) -> Void {
		callback?("lamb", nil)
	}
	
	func randomInt(callback: ((FailableResult<Int>) -> Void)) -> Void {
		callback(.success(Int(arc4random())))
	}
	
	func isEven(int: Int, callback:(Bool)->Void) -> Void {
		callback(int%2 == 0)
	}
	
	func noop(callback: @escaping () -> Void) {
		callback()
	}
	
	func voidFunc(callback: @escaping (Error?) -> Void) -> Void {
		callback(nil)
	}
	
	func multiplyString(string: String, count: Int) -> String {
		var acc = ""
		for _ in 0..<count {
			acc.append(string)
		}
		return acc
	}
	
	func stringLengthEquals(length: Int, string: String) -> Bool {
		return string.count == length
	}
	
	func decompose(string: String, callback:(String,String)->Void) {
		let comps = string.components(separatedBy: ",")
		callback(comps[0],comps[1])
	}
	
	func returnLonger(first: String, second: String) -> String {
		if first.count > second.count {
			return first
		} else {
			return second
		}
	}
	
	func explode(callback: ((Int) -> Void)?) throws -> Void {
		throw NSError(domain: "intentional", code: -1, userInfo: nil)
	}
}

func fail(on error: Error) {
	XCTFail("Error occured during test \(error)")
}
func fail() -> Void {
	XCTFail("This function shoult not be reachable")
}

class FibonaciGenerator {
	
	private var a = 0
	private var b = 1
	
	func ready(completion: ((FailableResult<Bool>) -> Void)) {
		completion(.success(true))
	}
	
	func next(completion: ((Int?, Error?) -> Void)? ) {
		let next = a + b
		a = b
		b = next
		completion?(next, nil)
	}
}
