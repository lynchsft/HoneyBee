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

func stringToInt(string: String) -> Int {
	return Int(string)!
}

func intToString(int: Int, callback: (String)->Void) {
	return callback("\(int)")
}

func constantInt() -> Int {
	return 8
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

startProccess { root in
	root.link(randomInt)
		.link(intToString)
		.link(stringToInt)
		.fork { ctx in
			ctx.link(printInt)
				.end()
			
			ctx.link(multiplyInt)
				.link(printInt)
				.end()
		}
}

startProccess { root in
	root.link(constantInt)
		.link(randomInts)
		.map(multiplyInt)
		.link(printAll)
		.end()
}

sleep(300)
