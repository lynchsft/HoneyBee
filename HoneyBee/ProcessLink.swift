//
//  ProcessLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class Executable<A> {
	func execute(argument: A) -> Void {}
}

class ProcessLink<A,B> : Executable<A> {
	
	static func startProcess() -> ProcessLink<Void,Void> {
		return ProcessLink<Void, Void>(function: {})
	}
	
	private var createdLinks: [Executable<B>] = []
	
	private var function: (A)->(B)
	
	private init(function:  @escaping (A)->(B)) {
		self.function = function
	}
	
	func invoke<C>(_ functor:  @escaping (B)->(C)) -> ProcessLink<B,C> {
		let link = ProcessLink<B,C>(function: functor)
		createdLinks.append(link)
		return link
	}
	
	func terminate() {
		
	}
	
	override func execute(argument: A) {
		let result = function(argument)
		for createdLink in self.createdLinks {
			createdLink.execute(argument: result)
		}
	}
}
