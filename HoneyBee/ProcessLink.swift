//
//  ProcessLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class Executable<A> {
	func execute(argument: A, completion: @escaping () -> Void) -> Void {}
}

final public class JoinPoint<A> : Executable<A> {
	private let resultLock = NSLock()
	private var result: A?
	private var resultCallback: ((A) -> Void)?
	private var queue: DispatchQueue
	private var conjoinLink: Executable<Void>?
	
	fileprivate init(queue: DispatchQueue) {
		self.queue = queue
	}
	
	private func yieldResult(_ callback: @escaping (A) -> Void) {
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}
		// this needs to be atomic
		if let result = result {
			callback(result)
		} else {
			self.resultCallback = callback
		}
	}
	
	override func execute(argument: A, completion: @escaping (Void) -> Void) {
		if let link = self.conjoinLink {
			link.execute(argument: Void(), completion:  completion)
		}
		
		self.resultLock.lock()
		defer {
			self.resultLock.unlock()
		}
		result = argument
		
		if let resultCallback = self.resultCallback {
			resultCallback(argument)
		}
	}
	
	public func conjoin<B, C>(_ other: JoinPoint<B>, _ function: @escaping (A, B) -> (C)) -> ProcessLink<Void, C> {
		let link = ProcessLink<Void, C>(function: {[unowned self] _, callback in
			self.yieldResult { a in
				other.yieldResult { b in
					callback(function(a, b))
				}
			}
		}, queue: self.queue)
		
		self.conjoinLink = link
		return link
	}
}

final public class ProcessLink<A, B> : Executable<A> {
	
	private var createdLinks: [Executable<B>] = []
	
	private var function: (A, @escaping (B) -> Void) throws -> Void
	private var errorHandler: (Error) -> Void
	fileprivate var queue: DispatchQueue
	
	convenience init(function:  @escaping (A, @escaping (B) -> Void) -> Void, queue: DispatchQueue) {
		self.init(function: function, errorHandler: {_ in /* no possibilty of checked error here */}, queue: queue)
	}
	
	init(function:  @escaping (A, @escaping (B) -> Void) throws -> Void, errorHandler: @escaping (Error) -> Void, queue: DispatchQueue) {
		self.function = function
		self.errorHandler = errorHandler
		self.queue = queue
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) throws -> Void, on queue: DispatchQueue? = nil, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, C> {
		let link = ProcessLink<B, C>(function: function, errorHandler: errorHandler, queue: queue ?? self.queue)
		self.createdLinks.append(link)
		return link
	}
	
	public func fork(_ defineBlock: (ProcessLink<A, B>) -> Void) {
		defineBlock(self)
	}
	
	public func joinPoint() -> JoinPoint<B> {
		let link = JoinPoint<B>(queue: self.queue)
		self.createdLinks.append(link)
		return link
	}
	
	override func execute(argument: A, completion fullChainCompletion: @escaping () -> Void) {
		do {
			try self.function(argument) { result in
				let group = DispatchGroup()
				
				for createdLink in self.createdLinks {
					let workItem = DispatchWorkItem(block: {
						createdLink.execute(argument: result) {
							group.leave()
						}
					})
					group.enter()
					self.queue.async(group: group, execute: workItem)
				}
				
				group.notify(queue: self.queue, execute: fullChainCompletion)
			}
		} catch {
			self.queue.async {
				self.errorHandler(error)
			}
		}
	}
}

extension ProcessLink {
	// simplifed forms
	
	@discardableResult public func chain<C>(_ function:  @escaping (B) -> (C) ) -> ProcessLink<B, C> {
		return self.chain(function, {_ in /* no checked errors possible */})
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
		return self.chain(function, {_ in /* no checked errors possible */})
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B) throws -> (C), _ errorHandler: @escaping (Error) -> Void ) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			try callback(function(b))
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, ((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			function(b,callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, ((C) -> Void)?) throws -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) throws in
			try function(b,callback)
		}, errorHandler)
	}
}

extension ProcessLink {
	// special forms
	
	@discardableResult public func splice<C>(_ function: @escaping () -> C) -> ProcessLink<Void, C> {
		return self.splice(function, {_ in /* no checked errros possible */})
	}
	
	@discardableResult public func splice<C>(_ function: @escaping () throws -> C, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<Void, C> {
		let link = self.chain({ (b: B, callback: @escaping () -> Void) in
			callback()
		})
		
		return link.chain(function, errorHandler)
	}
	
	public func value<C>(_ c: C) -> ProcessLink<Void, C> {
		return self.splice({ return c })
	}
}

extension ProcessLink {
	// secondary forms
	
	private func elevate<T>(_ function: @escaping (T) -> (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
		let wrapper = { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
			function(t)({ error in
				if let error = error {
					callback(.failure(error))
				} else {
					callback(.success(t))
				}
			})
		}
		
		return wrapper
	}
	
	private func elevate<T>(_ function: @escaping (T, @escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
		return elevate({ t in
			return { callback in
				function(t, callback)
			}
		})
	}
	
	private func elevate<T, C>(_ function: @escaping (T, @escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<C>) -> Void) -> Void {
		let wrapper = { (t: T, callback: @escaping (FailableResult<C>) -> Void) in
			function(t, { c, error in
				if let error = error {
					callback(.failure(error))
				} else {
					if let c = c {
						callback(.success(c))
					} else {
						callback(.failure(NSError(domain: "Unexpectedly missing value", code: -99, userInfo: nil)))
					}
				}
			})
		}
		
		return wrapper
	}
	
	private func checkResult<T>(_ result: FailableResult<T>) throws -> T {
		switch result {
		case let .success(t):
			return t
		case let .failure(error):
			throw error
		}
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<FailableResult<B>, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler)
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<FailableResult<B>, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler)
	}
	
	@discardableResult public func chain(_ function: @escaping (B, @escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<FailableResult<B>, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler)
	}
	
	@discardableResult public func chain(_ function: @escaping (B, ((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<FailableResult<B>, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<FailableResult<C>, C> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<FailableResult<C>, C> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (@escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			function(b)(callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			function(b)(callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (() -> C)) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			callback(function(b)())
		})
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (() -> Void)) -> ProcessLink<B, Void> {
		return self.chain({ (b: B, callback: @escaping () -> Void) in
			function(b)()
			callback()
		})
	}
}

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	public func map<C>(_ transform: @escaping (B.Iterator.Element) -> C) -> ProcessLink<B, [C]> {
		return self.chain({(sequence: B, callback: @escaping ([C]) -> Void) in
			sequence.asyncMap(transform: transform, completion: callback)
		})
	}
}

extension ProcessLink where B : Sequence {
	@discardableResult public func each(_ defineBlock: @escaping (ProcessLink<Void, B.Iterator.Element>) -> Void) -> ProcessLink<B, Void> {
		var rootLink: ProcessLink<Void, Void> = ProcessLink<Void,Void>( function: {_,callback in
			callback()
		}, queue: self.queue)
		
		return self.chain { (sequence:B, callback:@escaping ()->Void) -> Void in
			for element in sequence {
				defineBlock(rootLink.value(element))
			}
			
			rootLink.execute(argument: Void(), completion: callback)
		}
	}
}

public protocol OptionalProtocol {
	associatedtype WrappedType
	
	func getWrapped() -> WrappedType?
}

extension Optional : OptionalProtocol {
	public typealias WrappedType = Wrapped
	
	public func getWrapped() -> WrappedType? {
		return self
	}
}

extension ProcessLink where B : OptionalProtocol {
	@discardableResult public func optionally(_ defineBlock: @escaping (ProcessLink<B.WrappedType, B.WrappedType>) -> Void) -> ProcessLink<B, Void> {
		return self.chain { (b: B, callback: @escaping ()->Void) in
			if let unwrapped = b.getWrapped() {
				let context = ProcessLink<B.WrappedType, B.WrappedType>(function: {arg, block in block(arg)}, queue: self.queue)
				defineBlock(context)
				context.execute(argument: unwrapped, completion: callback)
			} else {
				callback()
			}
		}
	}
}
