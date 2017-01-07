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

func stringToInt(string: String) -> Int {
	return Int(string)!
}

func intToString(int: Int) -> String {
	return "\(int)"
}

func randomInt() -> Int {
	return Int(arc4random())
}


let root = ProcessLink<Void, Void>.startProcess()
	root
	.invoke(randomInt)
	.invoke(intToString)
	.invoke(stringToInt)
	.invoke(printInt)
	.terminate()

root.execute(argument: ())

