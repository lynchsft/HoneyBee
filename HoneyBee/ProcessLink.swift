//
//  ProcessLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation


final public class ProcessLink<A, B> : Executable<A> {
	
	private var createdLinks: [Executable<B>] = []
	
	private var function: (A, @escaping (B) -> Void) throws -> Void
	private var errorHandler: (Error) -> Void
	fileprivate var queue: DispatchQueue
	fileprivate var maxParallelContexts:Int?
	
	convenience init(function:  @escaping (A, @escaping (B) -> Void) -> Void, queue: DispatchQueue) {
		self.init(function: function, errorHandler: {_ in /* no possibilty of checked error here */}, queue: queue)
	}
	
	init(function:  @escaping (A, @escaping (B) -> Void) throws -> Void, errorHandler: @escaping (Error) -> Void, queue: DispatchQueue) {
		self.function = function
		self.errorHandler = errorHandler
		self.queue = queue
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) throws -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, C> {
		return self.chain(function, on: nil, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) throws -> Void, on queue: DispatchQueue?, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, C> {
		let link = ProcessLink<B, C>(function: function, errorHandler: errorHandler, queue: queue ?? self.queue)
		self.createdLinks.append(link)
		return link
	}
	
	public func fork(_ defineBlock: (ProcessLink<A, B>) -> Void) {
		defineBlock(self)
	}
	
	fileprivate func joinPoint() -> JoinPoint<B> {
		let link = JoinPoint<B>(queue: self.queue)
		self.createdLinks.append(link)
		return link
	}
	
	private var rateLimter:DispatchSemaphore? {
		if let maxParallelContexts = self.maxParallelContexts {
			return DispatchSemaphore(value: maxParallelContexts)
		} else {
			return nil
		}
	}
	
	override func execute(argument: A, completion fullChainCompletion: @escaping () -> Void) {
		do {
			try self.function(argument) { result in
				let group = DispatchGroup()
				let rateLimiter = self.rateLimter
				
				
				for createdLink in self.createdLinks {
					rateLimiter?.wait()
					let workItem = DispatchWorkItem(block: {
						createdLink.execute(argument: result) {
							rateLimiter?.signal()
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
	// special forms
	
	public func value<C>(_ c: C) -> ProcessLink<B, C> {
		return self.chain({_ in return c })
	}
	
	public func conjoin<C,X>(_ other: ProcessLink<X,C>) -> ProcessLink<Void, (B,C)> {
		return self.joinPoint().conjoin(other.joinPoint())
	}
}

extension ProcessLink : Chainable {
	
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
	
	private func identity<T>(_ value: T) -> T {
		return value
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler).chain(identity)
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler).chain(identity)
	}
	
	@discardableResult public func chain(_ function: @escaping (B, @escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler).chain(identity)
	}
	
	@discardableResult public func chain(_ function: @escaping (B, ((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, B> {
		return self.chain(elevate(function)).chain(checkResult, errorHandler).chain(identity)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, C> {
		// This one is really messy because the most natural result here would be a ProcessLink<C, C>, but that breaks our contract
		var storedB: B! = nil
		var storedC: C! = nil
		return self.chain({ (b:B, callback: @escaping (FailableResult<C>) -> Void) in
				storedB = b
				self.elevate(function)(b,callback)
		}).chain(checkResult, errorHandler).chain({storedC = $0}).value(storedB!).value(storedC!)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, C> {
		// This one is really messy because the most natural result here would be a ProcessLink<C, C>, but that breaks our contract
		var storedB: B! = nil
		var storedC: C! = nil
		return self.chain({ (b:B, callback: @escaping (FailableResult<C>) -> Void) in
			storedB = b
			self.elevate(function)(b,callback)
		}).chain(checkResult, errorHandler).chain({storedC = $0}).value(storedB!).value(storedC!)
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
	
	@discardableResult public func chain(_ function: @escaping (B) -> (() -> Void)) -> ProcessLink<B, B> {
		return self.chain({ (b: B, callback: @escaping (B) -> Void) in
			function(b)()
			callback(b)
		})
	}
	
	// special void forms
	
	@discardableResult public func chain(_ function: @escaping (@escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error) -> Void) -> ProcessLink<B, B> {
		let wrapper = {(_:B,callback:@escaping (Error?) -> Void) in
			function(callback)
		}
		return self.chain(elevate(wrapper)).chain(checkResult, errorHandler).chain(identity)
	}
	
	// void forms
	
	@discardableResult public func chain(_ function: @escaping () -> Void) -> ProcessLink<B, B> {
		return self.chain { (b: B, callback:@escaping (B) -> Void) in
			function()
			callback(b)
		}
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.chain { (b: B, callback: @escaping (C) -> Void) in
			function(callback)
		}
	}
	
	
}

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	public func map<C>(_ transform: @escaping (B.Iterator.Element) -> C) -> ProcessLink<B, [C]> {
		return self.chain({(collection: B, callback: @escaping ([C]) -> Void) in
			collection.asyncMap(on: self.queue, transform: transform, completion: callback)
		})
	}
	
	public func map<C>(_ transform: @escaping (B.Iterator.Element, (C)->Void) -> Void) -> ProcessLink<B, [C]> {
		return self.chain({(collection: B, callback: @escaping ([C]) -> Void) in
			collection.asyncMap(on: self.queue, transform: transform, completion: callback)
		})
	}
}

extension ProcessLink where B : Sequence {
	public func filter(_ transform: @escaping (B.Iterator.Element) -> Bool) -> ProcessLink<B, [B.Iterator.Element]> {
		return self.chain({(sequence: B, callback: @escaping ([B.Iterator.Element]) -> Void) in
			sequence.asyncFilter(on: self.queue, transform: transform, completion: callback)
		})
	}
	
	public func filter(_ transform: @escaping (B.Iterator.Element, (Bool)->Void) -> Void) -> ProcessLink<B, [B.Iterator.Element]> {
		return self.chain({(sequence: B, callback: @escaping ([B.Iterator.Element]) -> Void) in
			sequence.asyncFilter(on: self.queue, transform: transform, completion: callback)
		})
	}
}

extension ProcessLink where B : Sequence {
	@discardableResult public func each(maxParallel:Int? = nil, _ defineBlock: @escaping (ProcessLink<Void, B.Iterator.Element>) -> Void) -> ProcessLink<B, Void> {
		let rootLink: ProcessLink<Void, Void> = ProcessLink<Void,Void>( function: {_,callback in
			callback()
		}, queue: self.queue)
		rootLink.maxParallelContexts = maxParallel
		
		return self.chain { (sequence:B, callback:@escaping ()->Void) -> Void in
			for element in sequence {
				defineBlock(rootLink.chain{element})
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
