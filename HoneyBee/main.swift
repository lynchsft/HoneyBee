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

func randomInt() -> Int {
	return Int(arc4random())
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

sleep(3)
