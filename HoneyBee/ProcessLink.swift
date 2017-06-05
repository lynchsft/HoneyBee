//
//  ProcessLink.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

fileprivate func tname(_ t: Any) -> String {
	return String(describing: type(of: t))
}

final public class ProcessLink<A, B> : Executable<A>, PathDescribing {
	
	private var createdLinks: [Executable<B>] = []
	fileprivate var finalLink: ProcessLink<A,A>?
	
	private var function: (A, @escaping (B) -> Void) throws -> Void
	private var errorHandler: (Error, A) -> Void
	fileprivate var queue: DispatchQueue
	fileprivate var maxParallelContexts:Int? {
		didSet {
			if let maxParallelContexts = self.maxParallelContexts {
				self.rateLimiter = DispatchSemaphore(value: maxParallelContexts)
			}
		}
	}
	fileprivate var rateLimiter:DispatchSemaphore?
	
	let path: [String]
	
	convenience init(function:  @escaping (A, @escaping (B) -> Void) -> Void, queue: DispatchQueue, path: [String]) {
		self.init(function: function, errorHandler: {_ in /* no possibilty of checked error here */}, queue: queue, path: path)
	}
	
	init(function:  @escaping (A, @escaping (B) -> Void) throws -> Void, errorHandler: @escaping (Error, A) -> Void, queue: DispatchQueue, path: [String]) {
		self.function = function
		self.errorHandler = errorHandler
		self.queue = queue
		self.path = path
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) throws -> Void, _ errorHandler: @escaping (Error, B) -> Void) -> ProcessLink<B, C> {
		return self.chain(function, on: nil, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) throws -> Void, on queue: DispatchQueue?, _ errorHandler: @escaping (Error, B) -> Void) -> ProcessLink<B, C> {
		let link = ProcessLink<B, C>(function: function, errorHandler: errorHandler, queue: queue ?? self.queue, path: self.path + [tname(function)])
		self.createdLinks.append(link)
		return link
	}
	
	public func fork(_ defineBlock: (ProcessLink<A, B>) -> Void) {
		defineBlock(self)
	}
	
	public func finally(_ defineBlock: @escaping (ProcessLink<A,A>) -> Void ) -> ProcessLink<A,B> {
		if let oldFinalLink = self.finalLink {
			let _ = oldFinalLink.finally(defineBlock)
		} else {
			let newFinalLink = ProcessLink<A,A>(function: { (a: A, completion: @escaping (A) -> Void) in
				completion(a)
			},
											   queue: self.queue,
											   path: self.path+["finally"])
			self.finalLink = newFinalLink
			
			defineBlock(newFinalLink)
		}
		return self
	}
	
	fileprivate func joinPoint() -> JoinPoint<B> {
		let link = JoinPoint<B>(queue: self.queue, path: self.path+["joinpoint"])
		self.createdLinks.append(link)
		return link
	}
	
	
	override func execute(argument: A, completion fullChainCompletion: @escaping (Continue) -> Void) {
		self.queue.async {
			do {
				var callbackInvoked = false
				let callbackInvokedLock = NSLock()
				
				try self.function(argument) { (result: B) in
					callbackInvokedLock.lock()
					defer {
						callbackInvokedLock.unlock()
					}
					guard !callbackInvoked else {
						return // protect ourselves against clients invoking the callback more than once
					}
					callbackInvoked = true
					
					let group = DispatchGroup()
					let rateLimiter = self.rateLimiter
					
					
					var continueExecuting = true
					for createdLink in self.createdLinks {
						rateLimiter?.wait()
						let workItem = DispatchWorkItem(block: {
							func cleanup() {
								rateLimiter?.signal()
								group.leave()
							}
							
							if continueExecuting {
								createdLink.execute(argument: result) { cont in
									if continueExecuting {
										continueExecuting = cont
									}
									cleanup()
								}
							} else {
								cleanup()
							}
						})
						group.enter()
						self.queue.async(group: group, execute: workItem)
					}
					
					group.notify(queue: self.queue, execute: {
						if let finalLink = self.finalLink {
							if continueExecuting {
								finalLink.execute(argument: argument, completion: fullChainCompletion)
							} else {
								finalLink.execute(argument: argument) { _ in // doesn't matter how the finally chain ended
									fullChainCompletion(false) // don't continue
								}
							}
						} else {
							fullChainCompletion(continueExecuting)
						}
					})
				}
			} catch {
				self.errorHandler(error, argument)
				if let finalLink = self.finalLink {
					finalLink.execute(argument: argument) { _ in // doesn't matter how the finally chain ended
						fullChainCompletion(false) // don't continue
					}
				} else {
					fullChainCompletion(false) // don't continue
				}
			}
		}
	}
}

extension ProcessLink {
	// special forms
	
	public func value<C>(_ c: C) -> ProcessLink<B, C> {
		return self.chain { (b:B) in return c }
	}
	
	public func conjoin<C,X>(_ other: ProcessLink<X,C>) -> ProcessLink<Void, (B,C)> {
		return self.joinPoint().conjoin(other.joinPoint())
	}
}

extension ProcessLink : Chainable {
	
	@discardableResult public func chain<C>(_ function:  @escaping (B) -> (C) ) -> ProcessLink<B, C> {
		return self.chain(function, {_ in /* no checked errors possible */})
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
		return self.chain(function, {_ in /* no checked errors possible */})
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B) throws -> (C), _ errorHandler: @escaping (Error,B) -> Void ) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			try callback(function(b))
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, ((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			function(b,callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (B, ((C) -> Void)?) throws -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) throws in
			try function(b,callback)
		}, errorHandler)
	}
	
	private func objcErrorCallbackToSwift(_ function: @escaping (@escaping (Error?)->Void ) -> Void) -> (@escaping (FailableResult<Void>) -> Void) -> Void {
		return {(callback: @escaping ((FailableResult<Void>) -> Void)) in
			function { error in
				if let error = error {
					callback(.failure(error))
				} else {
					callback(.success(Void()))
				}
			}
		}
	}
	
	private func objcErrorCallbackToSwift<C>(_ function: @escaping (@escaping (C?, Error?)->Void ) -> Void) -> (@escaping (FailableResult<C>) -> Void) -> Void {
		return {(callback: @escaping ((FailableResult<C>) -> Void)) in
			function { c, error in
				if let error = error {
					callback(.failure(error))
				} else {
					if let c = c {
						callback(.success(c))
					} else {
						callback(.failure(NSError(domain: "Unexpectedly missing value", code: -99, userInfo: nil)))
					}
				}
			}
		}
	}
	
	private func populateVoid<T>(failableResult: FailableResult<Void>, with t: T) -> FailableResult<T> {
		switch failableResult {
		case let .failure(error):
			return .failure(error)
		case .success():
			return .success(t)
		}
	}
	
	private func elevate<T>(_ function: @escaping (T) -> (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
		return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
			self.objcErrorCallbackToSwift(function(t))({ result in
				callback(self.populateVoid(failableResult: result, with: t))
			})
		}
	}
	
	private func elevate<T>(_ function: @escaping (T, @escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
		return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
			self.objcErrorCallbackToSwift(function =<< t)({ result in
				callback(self.populateVoid(failableResult: result, with: t))
			})
		}
	}
	
	private func elevate<T>(_ function: @escaping (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
		return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
			self.objcErrorCallbackToSwift(function)({ result in
				callback(self.populateVoid(failableResult: result, with: t))
			})
		}
	}
	
	private func elevate<T, C>(_ function: @escaping (T, @escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<C>) -> Void) -> Void {
		return { (t: T, callback: @escaping (FailableResult<C>) -> Void) -> Void in
			self.objcErrorCallbackToSwift(bind(function, t))(callback)
		}
	}
	
	private func elevate<C>(_ function: @escaping (@escaping (C?, Error?) -> Void) -> Void) -> (@escaping (FailableResult<C>) -> Void) -> Void {
		return { (callback: @escaping (FailableResult<C>) -> Void) -> Void in
			self.objcErrorCallbackToSwift(function)(callback)
		}
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
	
	private func failableResultWrapper<C>(_ body:@escaping (B, @escaping (FailableResult<C>)->Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B,C>{
		var storedB: B! = nil
		var storedC: C! = nil
		return self.chain({ (b:B, callback: @escaping (FailableResult<C>) -> Void) in
			storedB = b
			body(b,callback)
		}).chain(checkResult, {e,_ in errorHandler(e,storedB!)}).chain({storedC = $0}).chain{_ in return storedB!}.chain{_ in return storedC!}
	}
	
	private func failableResultWrapper(_ body:@escaping (B, @escaping (FailableResult<B>)->Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B,B>{
		var storedB: B! = nil
		return self.chain({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			storedB = b
			body(b,callback)
		}).chain(checkResult, {e,_ in errorHandler(e,storedB!)}).chain(identity)
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain(_ function: @escaping (B, @escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain(_ function: @escaping (B, ((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
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
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> () -> C) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			callback(function(b)())
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> () throws -> C, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			try callback(function(b)())
		}, errorHandler)
	}
	
	@discardableResult public func chain(_ function: @escaping (@escaping (Error?) -> Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function:  @escaping (((C) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.chain { (b: B, callback: @escaping (C) -> Void) in
			function(callback)
		}
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function)(callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function(b))(callback)
		}, errorHandler)
	}
	
	
	@discardableResult public func chain<C>(_ function: @escaping (@escaping (C?, Error?) -> Void) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function)(callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) throws -> Void in
			try function(b)(callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (@escaping (C) -> Void) throws -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.chain( { (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (((C) -> Void)?) throws -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.chain( { (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (@escaping (C) -> Void) -> Void) -> ProcessLink<B, C> {
		return self.chain( { (b:B, callback: @escaping (C) -> Void) -> Void in
			function(callback)
		})
	}
	
	@discardableResult public func chain(_ function: @escaping (((Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function(b))(callback)
		}, errorHandler)
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (((C) -> Void)?) throws -> Void, _ errorHandler: @escaping (Error,B) -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(b)(callback)
		}, errorHandler)
	}

	@discardableResult public func splice<C>(_ function: @escaping () -> C ) -> ProcessLink<B,C> {
		return self.chain({ (b:B, callback: @escaping (C) -> Void) in
			callback(function())
		})
	}
	
	@discardableResult public func splice<C>(_ function: @escaping () throws -> C, _ errorHandler: @escaping (Error,B) -> Void ) -> ProcessLink<B,C> {
		return self.chain({ (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try callback(function())
		}, errorHandler)
	}
}

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	public func map<C>(_ transform: @escaping (B.Iterator.Element) -> C) -> ProcessLink<B, [C]> {
		return self.chain({(collection: B, callback: @escaping ([C]) -> Void) in
			collection.asyncMap(on: self.queue, transform: transform, completion: callback)
		})
	}
		
	public func map<C>(_ transform: @escaping (B.Iterator.Element, @escaping (C)->Void) -> Void) -> ProcessLink<B, [C]> {
		return self.chain({(collection: B, callback: @escaping ([C]) -> Void) in
			collection.asyncMap(on: self.queue, transform: transform, completion: callback)
		})
	}

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
	@discardableResult public func each(_ defineBlock: @escaping (ProcessLink<Void, B.Iterator.Element>) -> Void) -> ProcessLink<B, B> {
		var rootLink: ProcessLink<B, Void>!
		
		rootLink = self.chain { (sequence: B) -> Void in
			for element in sequence {
				let elemLink = rootLink.value(element)
				defineBlock(elemLink)
			}
		}
		
		let returnLink = ProcessLink<B,B>(function: { (b, callback) in
			callback(b)
		}, queue: self.queue, path: self.path+["each"])
		
		rootLink.finalLink = returnLink
		
		return returnLink
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
	@discardableResult public func optionally<X,Y>(_ defineBlock: @escaping (ProcessLink<B.WrappedType, B.WrappedType>) -> ProcessLink<X, Y>) -> ProcessLink<Void, Void> {
		
		let returnLink = ProcessLink<Void, Void>(function: {_, block in block()},
		                                                           queue: self.queue,
		                                                           path: self.path + ["optionally"])
		
		var immediateChain: ProcessLink<B,Void>! = nil
		
		immediateChain = self.chain { (b: B, callback: @escaping ()->Void) in
			if let unwrapped = b.getWrapped() {
				let unwrappedContext = ProcessLink<B.WrappedType, B.WrappedType>(function: {_, block in block(unwrapped)},
				                                                                 queue: self.queue,
				                                                                 path: self.path + ["optionally"])
				
				let lastLinkOfPostivePath = defineBlock(unwrappedContext)
				let _  = lastLinkOfPostivePath.finally { cntx in
							cntx.value(Void())
								.value(Void())
								.finalLink = returnLink
				}
				
				let _ = immediateChain.finally { cntx in
					cntx.value(unwrapped)
						.value(unwrapped)
						.finalLink = unwrappedContext
				}
				callback()
			} else {
				let _  = immediateChain.finally { cntx in
					cntx.value(Void())
						.value(Void())
						.finalLink = returnLink
				}

				callback()
			}
		}
		
		return returnLink
	}
}

fileprivate let limitPathsToSemaphoresLock = NSLock()
fileprivate var limitPathsToSemaphores: [String:DispatchSemaphore] = [:]

extension ProcessLink  {
	@discardableResult public func limit<I,J>(_ maxParallel: Int, _ defineBlock: @escaping (ProcessLink<A,B>) -> ProcessLink<I,J>) -> ProcessLink<I,J> {
		
		let pathString = self.path.joined()
		
		limitPathsToSemaphoresLock.lock()
		let semaphore = limitPathsToSemaphores[pathString] ?? DispatchSemaphore(value: maxParallel)
		limitPathsToSemaphores[pathString] = semaphore
		limitPathsToSemaphoresLock.unlock()
		
		self.rateLimiter = semaphore
			
		let lastLink = defineBlock(self)
		
		return lastLink
	}
}
