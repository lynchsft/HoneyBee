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
	
    lazy private(set) var multiplyInt = async1(self.multiplyInt)
	func multiplyInt(int: Int) -> Int {
		return int * 2
	}
	
    lazy private(set) var stringCat = async1(self.stringCat)
	func stringCat(string: String, callback: (String?, Error?) -> Void) -> Void {
		callback("\(string)cat",nil)
	}
	
    lazy private(set) var stringToInt = async1(self.stringToInt) as SingleArgFunction<String, Int>
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
	func stringToInt(string: String, callback: ((Result<Int, Error>) -> Void)?) {
		if let int = Int(string) {
			callback?(.success(int))
		} else {
			let error = NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
			callback?(.failure(error))
		}
	}
	#endif
	
    lazy private(set) var intToString = async1(self.intToString)
	func intToString(int: Int, callback: (String) -> Void) {
		return callback("\(int)")
	}
	
    lazy private(set) var constantInt = async0(self.constantInt)
	func constantInt(callback:(Result<Int, Error>)->Void) {
		callback(.success(8))
	}
	
    lazy private(set) var constantString = async0(self.constantString)
	func constantString(callback: ((String?, Error?) -> Void)? ) -> Void {
		callback?("lamb", nil)
	}
	
	func randomInt(callback: ((Result<Int, Error>) -> Void)) -> Void {
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
	
    lazy private(set) var multiplyString = async2(self.multiplyString)
	func multiplyString(string: String, count: Int) -> String {
		var acc = ""
		for _ in 0..<count {
			acc.append(string)
		}
		return acc
	}
	
    lazy private(set) var stringLengthEquals = async2(self.stringLengthEquals)
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
	
    lazy private(set) var explode = async0(self.explode)
	func explode(callback: ((Int) -> Void)?) throws -> Void {
		throw NSError(domain: "intentional", code: -1, userInfo: nil)
	}
}
func failIfError<T>(_ result: Result<T,Error>) {
    switch result {
    case .success(_):
        break
    case let .failure(error):
        XCTFail("Error occured during test \(error)")
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
	
	func ready(completion: ((Result<Bool, Error>) -> Void)) {
		completion(.success(true))
	}
	
	func next(completion: ((Int?, Error?) -> Void)? ) {
		let next = a + b
		a = b
		b = next
		completion?(next, nil)
	}
}

let increment = async1(increment(val:))
func increment(val: Int) -> Int {
	return val + 1
}

let addTogether = async2(addTogether(one: two:))
func addTogether(one: Int, two: Double) throws -> Double {
	return Double(one) + two
}
