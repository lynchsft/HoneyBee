//
//  main.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

func printString(string: String) {
	print("printing: \(string)")
}

func printInt(int: Int) {
	print("printing: \(int)")
}
func multiplyInt(int: Int) -> Int {
	return int * 2
}


func stringCat(string: String) -> String {
	return "\(string)cat"
}

func stringToInt(string: String) throws -> Int {
	if let int = Int(string) {
		return int
	} else {
		throw NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
	}
}

func intToString(int: Int, callback: (String)->Void) {
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

startProccess { root in
	root.chain(randomInt)
		.chain(intToString)
		//.chain(stringCat)
		.chain(stringToInt) {error in stdHandleError(error)}
		.fork { ctx in
			ctx.chain(printInt)
				.end()
			
			ctx.chain(multiplyInt)
				.chain(printInt)
				.end()
		}
}

startProccess { root in
	root.chain(constantInt)
		.chain(randomInts)
		.map(multiplyInt)
		.chain(printAll)
		.end()
}

startProccess { root in
	root.fork { ctx in
		let result1 = ctx.chain(constantInt)
						 .joinPoint()
	
		let result2 = ctx.chain(constantString)
						 .joinPoint()
			
		result2.cojoin(result1, multiplyString)
			   .chain(printString)
			   .end()
	}
}

sleep(5)
