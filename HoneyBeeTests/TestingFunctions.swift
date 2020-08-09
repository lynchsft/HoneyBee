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

enum SimpleError: FailureRateAwareError {
    static func failureRateExceeded(_ failureRate: FailureRate) -> SimpleError {
        .tooManyErrors
    }

    case tooManyErrors
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

    lazy private(set) var stringCat = async1(self.stringCat) as SingleArgFunction<String, String, Error>
	func stringCat(string: String, callback: @escaping (String?, Error?) -> Void) -> Void {
		callback("\(string)cat",nil)
	}

    lazy private(set) var stringToInt = async1(self.stringToInt) as SingleArgFunction<String, Int, NSError>
	func stringToInt(string: String, callback: ((Result<Int, NSError>) -> Void)?) {
		if let int = Int(string) {
			callback?(.success(int))
		} else {
			let error = NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
			callback?(.failure(error))
		}
	}


    lazy private(set) var intToString = async1(self.intToString) as SingleArgFunction<Int, String, Never>
	func intToString(int: Int, callback: @escaping (String) -> Void) {
		callback("\(int)")
	}

    lazy private(set) var constantInt = async0(self.constantInt)
	func constantInt(callback: @escaping (Result<Int, Error>)->Void) {
		callback(.success(8))
	}

    lazy private(set) var constantString = async0(self.constantString)
	func constantString(callback: ((String?, Error?) -> Void)? ) -> Void {
		callback?("lamb", nil)
	}

    lazy private(set) var randomInt = async0(self.randomInt)
	func randomInt(callback: @escaping (Result<Int, Error>) -> Void) -> Void {
		callback(.success(Int(arc4random())))
	}

    lazy private(set) var isEven = async1(self.isEven) as SingleArgFunction<Int, Bool, Never>
	func isEven(int: Int, callback: @escaping (Bool)->Void) -> Void {
		callback(int%2 == 0)
	}

    lazy private(set) var noop = async0(self.noop)
	func noop(callback: @escaping () -> Void) {
		callback()
	}

    lazy private(set) var voidFunc = async0(self.voidFunc)
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
	
	func decompose(string: String, callback: @escaping (String,String)->Void) {
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
	func explode(callback: @escaping (Int?, NSError?) -> Void) -> Void {
		callback(nil, NSError(domain: "intentional", code: -1, userInfo: nil))
	}
}
func failIfError<T,E:Error>(_ result: Result<T,E>) {
    switch result {
    case .success(_):
        break
    case let .failure(error):
        XCTFail("Error occured during test: \(error)")
    }
}
func fail(on error: Error) {
	XCTFail("Error occured during test: \(error)")
}
func fail() -> Void {
	XCTFail("This function shoult not be reachable")
}

class FibonaciGenerator {
	
	private var a = 0
	private var b = 1

    lazy private(set) var ready = async0(self.ready)
	func ready(completion: @escaping ((Result<Bool, Error>) -> Void)) {
		completion(.success(true))
	}

    lazy private(set) var next = async0(self.next)
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

struct User {

    var reset: SingleArgFunction<Int, Void, Never> { async1(self.reset) }
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

extension XCTestExpectation {
    var fulfill: ZeroArgFunction<Void, Never> { async0(self.fulfill) }
}

@discardableResult
func XCTAssertEqual<S: Equatable, E: Error, P: AsyncBlockPerformer>(_ one: Link<S, E, P>, _ two: Link<S, E, P>) -> Link<Void, E, P> {
    (one+two).chain { (e: (S, S), completion: @escaping (Result<Void, Never>) -> Void) in
        XCTAssertEqual(e.0, e.1)
        completion(.success(Void()))
    }
}
