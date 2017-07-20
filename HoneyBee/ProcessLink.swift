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

/**
`ProcessLink` is the primary interface for HoneyBee processes.
A link represents a single asynchronous function, as well as it's execution context.
The execution context includes:

1. A `DispatchQueue` execution context
2. An error handling function for when things go wrong
3. A list of child `ProcessLink`s to execute using the result of this link.

A single link's execution process is as follows:

1. Private method `execute(_:)` is called with the execution parameter A.
2. This method's function is executed with argument A. If the function throws, then the error is given to this links registered error handler along with A, for context
3. (If the function does not throw) The result value B is captured.
4. This link's child links are individually, in parallel executed in this link's `DispatchQueue`
5. When _all_ of the child links have completed their execution, then this link signals that it has completed execution, via callback.
*/
final public class ProcessLink<A, B> : Executable<A>, PathDescribing {
	
	private var createdLinks: [Executable<B>] = []
	fileprivate var finalLink: ProcessLink<A,A>?
	
	private var function: (A, @escaping (B) -> Void) throws -> Void
	fileprivate var errorHandler: ((Error, Any) -> Void)
	fileprivate var queue: DispatchQueue // This is the queue which is passed on to chains
	
	let path: [String]
	
	init(function:  @escaping (A, @escaping (B) -> Void) throws -> Void, errorHandler: @escaping ((Error, Any) -> Void), queue: DispatchQueue, path: [String]) {
		self.function = function
		self.errorHandler = errorHandler
		self.queue = queue
		self.path = path
	}
	
	
	/// Primary chain form. All other forms translate into this form.
	///
	/// - Parameter function: will be executed as a child link of this `ProcessLink`. Receives `B` (the result of this `ProcessLink` and generates `C`.
	/// - Returns: The child link which has been added to this `ProcessLink`'s child list. Children are executed in parallel. See `ProcessLink`'s description.
	@discardableResult public func chain<C>(_ function:  @escaping (B, @escaping (C) -> Void) throws -> Void) -> ProcessLink<B, C> {
		let link = ProcessLink<B, C>(function: function, errorHandler: self.errorHandler, queue: self.queue, path: self.path + [tname(function)])
		self.createdLinks.append(link)
		return link
	}
	
	/// Yields self to a new definition block. Within the block the caller may invoke chaining methods on block multiple times, thus achieving parallel chains. Example:
	///
	///     link.fork { cntx in
	///       cntx.chain(func1)
	///           .chain(func2)
	///
	///       cntx.chain(func3)
	///           .chain(func4)
	///     }
	///
	/// In the preceding example, when `link` is executed it will start the links containing `func1` and `func3` in parallel.
	/// `func2` will execute when `func1` is finished. Likewise `func4` will execute when `func3` is finished.
	///
	/// - Parameter defineBlock: the block to which this `ProcessLink` yields itself.
	public func fork(_ defineBlock: (ProcessLink<A, B>) -> Void) {
		defineBlock(self)
	}
	
	/**
	 `finally` creates a subchain which will be executed whether or not the proceeding chain errors.
	 In the case that no error occurs in the proceeding chain, finally is executed after the final link of the chain, as though it had been directly appended there.
	 In the case that an error, the subchain defined by `finally` will be executed after the error handler has finished.
	 If there is no error, the subchain defined by `finally` will be executed after all subsequent changes have finished.
	 Example:
	
	     HoneyBee.start { root in
	        root.errorHandler(funcE)
	            .chain(funcA)
	            .finally { cntx in
	                cntx.chain(funcZ)
	            }
                .chain(funcB)
	            .chain(funcC)
	     }

	 In the preceding example, if no error occurs then the functions will execute in this order: `funcA`, `funcB`, `funcC`, `funcZ`. The error handler, `funcE` will not be executed.
	 If `funcB` produces an error, then execution is as follows: `funcA`, `funcB`, `funcE`, `funcZ`. The links after the error, (`funcC`), will not be executed.

	 - Parameter defineBlock: context within which to define the finally chain.
	 - Returns: a `ProcessLink` with the same execution context as self, but with a finally chain registered.
	*/
	public func finally(_ defineBlock: @escaping (ProcessLink<A,A>) -> Void ) -> ProcessLink<A,B> {
		if let oldFinalLink = self.finalLink {
			let _ = oldFinalLink.finally(defineBlock)
		} else {
			let newFinalLink = ProcessLink<A,A>(function: { (a: A, completion: @escaping (A) -> Void) in
				completion(a)
			}, errorHandler: self.errorHandler,
			   queue: self.queue,
			   path: self.path+["finally"])
			self.finalLink = newFinalLink
			
			defineBlock(newFinalLink)
		}
		return self
	}
	
	fileprivate func joinPoint() -> JoinPoint<B> {
		let link = JoinPoint<B>(queue: self.queue, path: self.path+["joinpoint"], errorHandler: self.errorHandler)
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
					
					var continueExecuting = true
					for createdLink in self.createdLinks {
						let workItem = DispatchWorkItem(block: {
							
							if continueExecuting {
								createdLink.execute(argument: result) { cont in
									if continueExecuting {
										continueExecuting = cont
									}
									group.leave()
								}
							} else {
								group.leave()
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
	
	/// `value` inserts a value of any type into the chain data flow.
	///
	/// - Parameter c: Any value
	/// - Returns: a `ProcessLink` whose child links will receive `c` as their function argument.
	public func value<C>(_ c: C) -> ProcessLink<B, C> {
		return self.chain { (b:B, callback: (C) -> Void) in callback(c) }
	}
	
	/// `conjoin` is a compliment to `fork`.
	/// Within the context of a `fork` it is natural and expected to create parallel execution chains.
	/// If the process definition wishes at some point to combine the results of these execution chains, then `conjoin` should be used.
	/// `conjoin` returns a `ProcessLink` which waits for both the receiver and the argument `ProcessLink`s have created results. Those results are combined into a tuple `(B,C)` which is passed to the child links of the returned `ProcessLink`
	///
	/// - Parameter other: the `ProcessLink` to join with
	/// - Returns: A `ProcessLink` which combines the receiver and the arguments results.
	public func conjoin<C,X>(_ other: ProcessLink<X,C>) -> ProcessLink<Void, (B,C)> {
		return self.joinPoint().conjoin(other.joinPoint())
	}
}

extension ProcessLink : ErrorHandling {
	
	/// Establishes a new error handler for this link and all descendant links.
	///
	/// - Parameter errorHandler: a function which takes an Error and an `Any` context object. The context object is usual the object which was being acted upon when the error occurred.
	/// - Returns: A `ProcessLink` which has `errorHandler` installed
	public func setErrorHandler(_ errorHandler: @escaping (Error, Any) -> Void ) -> ProcessLink<A,B> {
		self.errorHandler = errorHandler
		return self
	}
}

extension ProcessLink : Chainable {
	
	@discardableResult public func chain<C>(_ function:  @escaping (B) throws -> (C) ) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			try callback(function(b))
		})
	}

	@discardableResult public func chain<C>(_ function:  @escaping (B, ((C) -> Void)?) throws -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) throws in
			try function(b,callback)
		})
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
	
	private func failableResultWrapper<C>(_ body:@escaping (B, @escaping (FailableResult<C>)->Void) -> Void) -> ProcessLink<B,C>{
		var storedB: B! = nil
		var storedC: C! = nil
		return self.chain({ (b:B, callback: @escaping (FailableResult<C>) -> Void) in
			storedB = b
			body(b,callback)
		}).chain(checkResult).chain({storedC = $0}).chain{_ in return storedB!}.chain{_ in return storedC!}
	}
	
	private func failableResultWrapper(_ body:@escaping (B, @escaping (FailableResult<B>)->Void) -> Void) -> ProcessLink<B,B>{
		return self.chain({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			body(b,callback)
		}).chain(checkResult).chain(identity)
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (((Error?) -> Void)?) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain(_ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain(_ function: @escaping (B, ((Error?) -> Void)?) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain(_ function: @escaping (B, @escaping (Error?) -> Void) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) throws -> Void in
			try function(b)(callback)
		})
	}

	@discardableResult public func chain<C>(_ function: @escaping (B) -> () throws -> C) -> ProcessLink<B, C> {
		return self.chain({ (b: B, callback: @escaping (C) -> Void) in
			try callback(function(b)())
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function(b))(callback)
		})
	}

	@discardableResult public func chain(_ function: @escaping (@escaping (Error?) -> Void) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (@escaping (C) -> Void) throws -> Void) -> ProcessLink<B, C> {
		return self.chain( { (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(callback)
		})
	}

	@discardableResult public func chain<C>(_ function: @escaping (((C?, Error?) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function)(callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (@escaping (C?, Error?) -> Void) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function)(callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (((C) -> Void)?) throws -> Void) -> ProcessLink<B, C> {
		return self.chain( { (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(callback)
		})
	}
	
	@discardableResult public func chain(_ function: @escaping (((Error?) -> Void)?) -> Void) -> ProcessLink<B, B> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			self.elevate(function)(b,callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void) -> ProcessLink<B, C> {
		return self.failableResultWrapper({ (b:B, callback: @escaping (FailableResult<C>)->Void) in
			self.objcErrorCallbackToSwift(function(b))(callback)
		})
	}
	
	@discardableResult public func chain<C>(_ function: @escaping (B) -> (((C) -> Void)?) throws -> Void) -> ProcessLink<B, C> {
		return self.chain({ (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(b)(callback)
		})
	}
	
	@discardableResult public func splice<C>(_ function: @escaping () throws -> C ) -> ProcessLink<B,C> {
		return self.chain({ (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try callback(function())
		})
	}
}

extension ProcessLink {
	// queue management
	
	
	/// Set the execution queue for all descendant links. N.B. *this does not change the execution queue for the receiver's function.*
	/// Example
	///
	///     HoneyBee.start(on: .main) { root in
	///        root.setErrorHandlder(handleError)
    ///            .chain(funcA)
	///            .setQueue(.global())
	///            .chain(funcB)
	///     }
	///
	/// In the preceding example, `funcA` will run on `DispatchQueue.main` and `funcB` will run on `DispatchQueue.global()`
	///
	/// - Parameter queue: the new `DispatchQueue` for child links
	/// - Returns: the receiver
	public func setQueue(_ queue: DispatchQueue) -> ProcessLink<A,B> {
		self.queue = queue
		return self
	}
}

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	
	/// When the inbound type is a `Collection` with `Int` indexes (most are), then you may call `map` to asynchronously map over the elements of B in parallel, transforming them with `transform`.
	///
	/// - Parameter transform: the transformation function which converts `B.Iterator.Element` to `C`
	/// - Returns: a `ProcessLink` which will yield an array of `C`s to it's child links.
	public func map<C>(_ transform: @escaping (B.Iterator.Element) -> C) -> ProcessLink<B, [C]> {
		return self.chain({(collection: B, callback: @escaping ([C]) -> Void) in
			collection.asyncMap(on: self.queue, transform: transform, completion: callback)
		})
	}
	
	/// When the inbound type is a `Collection` with `Int` indexes (most are), then you may call `map` to asynchronously map over the elements of B in parallel, transforming them with `transform`.
	///
	/// - Parameter transform: the transformation function which converts `B.Iterator.Element` to `C`
	/// - Returns: a `ProcessLink` which will yield an array of `C`s to it's child links.
	public func map<C>(_ transform: @escaping (B.Iterator.Element, @escaping (C)->Void) -> Void) -> ProcessLink<B, [C]> {
		return self.chain({(collection: B, callback: @escaping ([C]) -> Void) in
			collection.asyncMap(on: self.queue, transform: transform, completion: callback)
		})
	}
	
	/// When the inbound type is a `Collection` with `Int` indexes (most are), then you may call `filter` to asynchronously filter the elements of B in parallel, using `filter`
	///
	/// - Parameter filter: the filter function
	/// - Returns: a `ProcessLink` which will yield to it's child links an array containing those `B.Iterator.Element`s which `filter` approved.
	public func filter(_ filter: @escaping (B.Iterator.Element) -> Bool) -> ProcessLink<B, [B.Iterator.Element]> {
		return self.chain({(sequence: B, callback: @escaping ([B.Iterator.Element]) -> Void) in
			sequence.asyncFilter(on: self.queue, transform: filter, completion: callback)
		})
	}
	
	/// When the inbound type is a `Collection` with `Int` indexes (most are), then you may call `filter` to asynchronously filter the elements of B in parallel, using `filter`
	///
	/// - Parameter filter: the filter function
	/// - Returns: a `ProcessLink` which will yield to it's child links an array containing those `B.Iterator.Element`s which `filter` approved.
	public func filter(_ filter: @escaping (B.Iterator.Element, (Bool)->Void) -> Void) -> ProcessLink<B, [B.Iterator.Element]> {
		return self.chain({(sequence: B, callback: @escaping ([B.Iterator.Element]) -> Void) in
			sequence.asyncFilter(on: self.queue, transform: filter, completion: callback)
		})
	}
}

extension ProcessLink where B : Sequence {
	
	
	/// When the inbound type is a `Sequence` you may call `each`
	/// Each accepts a define block which creates a subchain which will be invoked once per element of the sequence.
	/// The `ProcessLink` which is given as argument to the define block will pass to it's child links the element of the sequence which is currently being processed.
	///
	/// - Parameter defineBlock: a block which creates a subchain for each element of the sequence
	/// - Returns: a ProcessLink which will pass the `Sequence` `B` to its child links
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
		}, errorHandler: self.errorHandler, queue: self.queue, path: self.path+["each"])
		
		rootLink.finalLink = returnLink
		
		return returnLink
	}
}

/// Protocol for handling Optionals as a protocol. Useful for generic constraints
public protocol OptionalProtocol {
	/// The type which this optional wraps
	associatedtype WrappedType
	
	/// Return an optional value of the wrapped type.
	///
	/// - Returns: an optional value
	func getWrapped() -> WrappedType?
}

/// Optional implements OptionalProtocol for use in generic constraints
extension Optional : OptionalProtocol {
	/// The type which this optional wraps
	public typealias WrappedType = Wrapped
	
	/// return self
	public func getWrapped() -> WrappedType? {
		return self
	}
}

extension ProcessLink where B : OptionalProtocol {
	/// When `B` is an `Optional` you may call `optionally`. The supplied define block creates a subchain which will be run if the Optional value is non-nil. The `ProcessLink` given to the define block yields a non-optional value of `B.WrappedType` to its child links
	/// This function returns a `ProcessLink` with a void result value, because the subchain defined by optionally will not be executed if `B` is `nil`.
	///
	/// - Parameter defineBlock: a block which creates a subchain to run if B is non-nil
	/// - Returns: a `ProcessLink` with a void value type.
	@discardableResult public func optionally<X,Y>(_ defineBlock: @escaping (ProcessLink<B.WrappedType, B.WrappedType>) -> ProcessLink<X, Y>) -> ProcessLink<Void, Void> {
		
		let returnLink = ProcessLink<Void, Void>(function: {_, block in block()},
		                                         errorHandler: self.errorHandler,
		                                         queue: self.queue,
		                                         path: self.path + ["optionally"])
		
		var immediateChain: ProcessLink<B,Void>! = nil
		
		immediateChain = self.chain { (b: B, callback: @escaping ()->Void) in
			if let unwrapped = b.getWrapped() {
				let unwrappedContext = ProcessLink<B.WrappedType, B.WrappedType>(function: {_, block in block(unwrapped)},
				                                                                 errorHandler: self.errorHandler,
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
	/// `limit` defines a subchain with special runtime protections. The links within the `limit` subchain are guaranteed to have at most `maxParallel` parallel executions. `limit` is particularly useful in the context of a fully parallel process when part of the process must access a limited resource pool such as CPU execution contexts or network resources.
	/// This method returns a `ProcessLink` whose execution result `J` is the result of the final link of the subchain. This permits the chain to proceed naturally after limit. For example:
	///
	///      .limit(5) { cntx in
	///         cntx.chain(resourceLimitedIntGenerator)
	///		}
	///     .chain(multiplyInt)
	///
	/// In the example above `resourceLimitedIntGenerator` results in an `Int` and that int is passed along to `multipyInt` after the `limit` context has finished.
	///
	/// - Parameters:
	///   - maxParallel: the maximum number of parallel executions permitted for the subchains defined by `defineBlock`
	///   - defineBlock: a block which creates a subchain to be limited.
	/// - Returns: a `ProcessLink` whose execution result `J` is the result of the final link of the subchain.
	@discardableResult public func limit<I,J>(_ maxParallel: Int, _ defineBlock: @escaping (ProcessLink<B,B>) -> ProcessLink<I,J>) -> ProcessLink<J,J> {
		
		let pathString = self.path.joined()
		
		limitPathsToSemaphoresLock.lock()
		let semaphore = limitPathsToSemaphores[pathString] ?? DispatchSemaphore(value: maxParallel)
		limitPathsToSemaphores[pathString] = semaphore
		limitPathsToSemaphoresLock.unlock()
		
		let openingLink = self.chain { (b:B) -> B in
			semaphore.wait()
			return b
		}
		
		openingLink.queue = DispatchQueue.global()
		
		let lastLink = defineBlock(openingLink)
		
		let returnLink = lastLink.chain { (j:J) -> J in
			semaphore.signal()
			return j
		}
		
		
		return returnLink
	}
}
