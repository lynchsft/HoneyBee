//
//  ProcessLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class Executable<A> {
	fileprivate func execute(argument: A) -> Void {}
}

class ProcessResult<A>  : Executable<A>{
	private let resultLock = NSLock()
	private var result: A?
	private var callback: ((A) -> Void)?
	
	func yieldResult(_ callback: @escaping (A) -> Void) {
		resultLock.lock()
		// this needs to be atomic
		if let result = result {
			callback(result)
		} else {
			self.callback = callback
		}
		resultLock.unlock()
	}
	
	override fileprivate func execute(argument: A) {
		resultLock.lock()
		result = argument
		if let callback = callback {
			callback(argument)
		}
		resultLock.unlock()
	}
	
	func cojoin<B,C>(_ other: ProcessResult<B>, _ functor: @escaping (A,B) -> (C)) -> ProcessLink<Void,C>{
		let link = ProcessLink<Void,C>(function: {_,callback in
			self.yieldResult { a in
				other.yieldResult { b in
					callback(functor(a, b))
				}
			}
		})
		link.execute(argument: ())
		return link
	}
}

class ProcessLink<A,B> : Executable<A> {
	
	static func rootProcess() -> ProcessLink<Void,Void> {
		return ProcessLink<Void, Void>(function: {_,block in block()})
	}
	
	fileprivate var createdLinks: [Executable<B>] = []
	
	fileprivate var function: (A, @escaping (B)->Void) throws -> Void
	fileprivate var errorHandler: (Error) -> Void
	
	fileprivate convenience init(function:  @escaping (A, @escaping (B)->Void) -> Void) {
		self.init(function: function, errorHandler: {_ in /* no possibilty of checked error here */})
	}
	
	fileprivate init(function:  @escaping (A, @escaping (B)->Void) throws -> Void, errorHandler: @escaping (Error) -> Void) {
		self.function = function
		self.errorHandler = errorHandler
	}
	
	func chain<C>(_ functor:  @escaping (B) -> (C) ) -> ProcessLink<B,C> {
		return self.chain(functor, errorHandler: {_ in /* no checked errors possible */})
	}
	
	func chain<C>(_ functor:  @escaping (B, @escaping (C) -> Void) -> Void) -> ProcessLink<B,C> {
		return self.chain(functor, errorHandler: {_ in /* no checked errors possible */})
	}
	
	func chain<C>(_ functor:  @escaping (B) throws -> (C), errorHandler: @escaping (Error)->Void ) -> ProcessLink<B,C> {
		return self.chain({ (b, callback) in
			try callback(functor(b))
		}, errorHandler: errorHandler)
	}
	
	func chain<C>(_ functor:  @escaping (B, @escaping (C) -> Void) throws -> Void, errorHandler: @escaping (Error)->Void) -> ProcessLink<B,C> {
		let link = ProcessLink<B,C>(function: functor, errorHandler: errorHandler)
		createdLinks.append(link)
		return link
	}
	
	func fork(_ defineBlock: (ProcessLink<A,B>)->Void) {
		defineBlock(self)
	}
	
	func end() {
		
	}
	
	func joinPoint() -> ProcessResult<B> {
		let link = ProcessResult<B>()
		createdLinks.append(link)
		return link
	}
	
	override fileprivate func execute(argument: A) {
		do {
			try self.function(argument) { result in
				for createdLink in self.createdLinks {
					DispatchQueue.global().async {
						createdLink.execute(argument: result)
					}
				}
			}
		} catch {
			self.errorHandler(error)
		}
	}
}

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	
	func map<C>(_ transform: @escaping (B.Iterator.Element) -> C) -> ProcessLink<B,[C]> {
		let link = ProcessLink<B,[C]>(function:{sequence, callback in
			sequence.asyncMap(transform: transform, completion: callback)
		})
		createdLinks.append(link)
		return link
	}
}

func startProccess(_ defineBlock: (ProcessLink<Void,Void>)->Void) {
	let root = ProcessLink<Void, Void>.rootProcess()
	defineBlock(root)
	root.execute(argument: ())
}

