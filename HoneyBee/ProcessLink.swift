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

public class ProcessResult<A>  : Executable<A>{
	private let resultLock = NSLock()
	private var result: A?
	private var callback: ((A) -> Void)?
	private var queue: DispatchQueue
	
	fileprivate init(queue: DispatchQueue) {
		self.queue = queue
	}
	
	private func yieldResult(_ callback: @escaping (A) -> Void) {
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
	
	public func cojoin<B,C>(_ other: ProcessResult<B>, _ functor: @escaping (A,B) -> (C)) -> ProcessLink<Void,C>{
		let link = ProcessLink<Void,C>(function: {_,callback in
			self.yieldResult { a in
				other.yieldResult { b in
					callback(functor(a, b))
				}
			}
		}, queue: self.queue)
		link.execute(argument: ())
		return link
	}
}

public class ProcessLink<A,B> : Executable<A> {
	
	private var createdLinks: [Executable<B>] = []
	
	private var function: (A, @escaping (B)->Void) throws -> Void
	private var errorHandler: (Error) -> Void
	private var queue: DispatchQueue
	
	fileprivate convenience init(function:  @escaping (A, @escaping (B)->Void) -> Void, queue: DispatchQueue) {
		self.init(function: function, errorHandler: {_ in /* no possibilty of checked error here */}, queue: queue)
	}
	
	fileprivate init(function:  @escaping (A, @escaping (B)->Void) throws -> Void, errorHandler: @escaping (Error) -> Void, queue: DispatchQueue) {
		self.function = function
		self.errorHandler = errorHandler
		self.queue = queue
	}
	
	public func chain<C>(_ functor:  @escaping (B, @escaping (C) -> Void) throws -> Void, on queue: DispatchQueue? = nil, _ errorHandler: @escaping (Error)->Void) -> ProcessLink<B,C> {
		let link = ProcessLink<B,C>(function: functor, errorHandler: errorHandler, queue: queue ?? self.queue)
		createdLinks.append(link)
		return link
	}
	
	public func fork(_ defineBlock: (ProcessLink<A,B>)->Void) {
		defineBlock(self)
	}
	
	public func joinPoint() -> ProcessResult<B> {
		let link = ProcessResult<B>(queue: self.queue)
		createdLinks.append(link)
		return link
	}
	
	public func end() {} // semantic convenience
	
	override fileprivate func execute(argument: A) {
		do {
			try self.function(argument) { result in
				for createdLink in self.createdLinks {
					self.queue.async {
						createdLink.execute(argument: result)
					}
				}
			}
		} catch {
			self.errorHandler(error)
		}
	}
}

extension ProcessLink {
	// simplifed forms
	
	public func chain<C>(_ functor:  @escaping (B) -> (C) ) -> ProcessLink<B,C> {
		return self.chain(functor, {_ in /* no checked errors possible */})
	}
	
	public func chain<C>(_ functor:  @escaping (B, @escaping (C) -> Void) -> Void) -> ProcessLink<B,C> {
		return self.chain(functor, {_ in /* no checked errors possible */})
	}
	
	public func chain<C>(_ functor:  @escaping (B) throws -> (C), _ errorHandler: @escaping (Error)->Void ) -> ProcessLink<B,C> {
		return self.chain({ (b, callback) in
			try callback(functor(b))
		}, errorHandler)
	}
}

extension ProcessLink {
	// special forms
	
	public func splice<C>(_ functor: @escaping () -> C) -> ProcessLink<Void,C> {
		return self.splice(functor, {_ in /* no checked errros possible */})
	}
	
	public func splice<C>(_ functor: @escaping () throws -> C, _ errorHandler: @escaping (Error)->Void) -> ProcessLink<Void,C> {
		let link = self.chain({(_,callback) in
			callback()
		})
		
		return link.chain(functor, errorHandler)
	}
	
	public func value<C>(_ c: C) -> ProcessLink<Void,C> {
		return self.splice({ return c })
	}
}

extension ProcessLink {
	// secondary forms
	
	private func elevate<T>(_ functor: @escaping (T) -> (@escaping (Error?)->Void)->Void) -> (T, @escaping (FailableResult<T>)->Void) -> Void {
		let wrapper: (T, @escaping (FailableResult<T>)->Void) -> Void = { t, callback in
			functor(t)({ error in
				if let error = error {
					callback(.failure(error))
				} else {
					callback(.success(t))
				}
			})
		}
		
		return wrapper
	}
	
	private func elevate<T>(_ functor: @escaping (T, @escaping (Error?)->Void)->Void) -> (T, @escaping (FailableResult<T>)->Void) -> Void {
		return elevate { t in
			return { callback in
				functor(t,callback)
			}
		}
	}
	
	private func checkResult<T>(_ result: FailableResult<T>) throws -> T{
		switch result {
		case let .success(t):
			return t
		case let .failure(error):
			throw error
		}
	}
	
	public func chain(_ functor: @escaping (B) -> (@escaping (Error?)->Void)->Void, _ errorHandler: @escaping (Error)->Void) -> ProcessLink<FailableResult<B>,B> {
		return self.chain(elevate(functor)).chain(checkResult, errorHandler)
	}
	
	public func chain(_ functor: @escaping (B, @escaping (Error?)->Void)->Void, _ errorHandler: @escaping (Error)->Void) -> ProcessLink<FailableResult<B>,B> {
		return self.chain(elevate(functor)).chain(checkResult, errorHandler)
	}
}

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	
	public func map<C>(_ transform: @escaping (B.Iterator.Element) -> C) -> ProcessLink<B,[C]> {
		return self.chain({sequence, callback in
			sequence.asyncMap(transform: transform, completion: callback)
		})
	}
}

public func startProccess(on queue: DispatchQueue = DispatchQueue.global(), _ defineBlock: (ProcessLink<Void,Void>)->Void) {
	let root = ProcessLink<Void, Void>(function: {_,block in block()}, queue: queue)
	defineBlock(root)
	root.execute(argument: ())
}

public func startProccess<A>(with arg: A, on queue: DispatchQueue = DispatchQueue.global(), _ defineBlock: (ProcessLink<A,A>)->Void) {
	let root = ProcessLink<A, A>(function: {a,block in block(a)}, queue: queue)
	defineBlock(root)
	root.execute(argument: arg)
}

