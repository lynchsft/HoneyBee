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
A link represents a single asynchronous function, as well as its execution context.
The execution context includes:

1. A `AsyncBlockPerformer` execution context
2. An error handling function for when things go wrong
3. A list of child `ProcessLink`s to execute using the result of this link.

A single link's execution process is as follows:

1. Link is executed with the execution argument.
2. This method's function is called with argument. If the function errors, then the error is given to this link's registered error handler along with an optional `ErrorContext`
3. (If the function does not error) The result value B is captured.
4. This link's child links are individually, in parallel executed in this link's `AsyncBlockPerformer`
5. When _all_ of the child links have completed their execution, then this link signals that it has completed execution, via callback.
*/
final public class ProcessLink<B> : Executable, PathDescribing  {
	
	fileprivate var createdLinks: [Executable] = []
	private let createdLinksLock = NSLock()
	fileprivate var createdLinksAsyncSemaphore: DispatchSemaphore?
	fileprivate var finalLink: ProcessLink<Void>?
	
	private var function: (Any, @escaping (FailableResult<B>) -> Void) -> Void
	fileprivate var errorHandler: ((Error, ErrorContext) -> Void)
	/// This is the queue which is passed on to sub chains
	fileprivate var blockPerformer: AsyncBlockPerformer
	/// This is the queue which is used to execute this chain. This and `blockPerformer` are the same until `setBlockPerformer(_:)` is called
	fileprivate var myBlockPerformer: AsyncBlockPerformer
	
	// Debug info
	
	let path: [String]
	private let functionFile: StaticString
	private let functionLine: UInt
	
	init(function:  @escaping (Any, @escaping (FailableResult<B>) -> Void) -> Void, errorHandler: @escaping ((Error, ErrorContext) -> Void), blockPerformer: AsyncBlockPerformer, path: [String], functionFile: StaticString, functionLine: UInt) {
		self.function = function
		self.errorHandler = errorHandler
		self.blockPerformer = blockPerformer
		self.myBlockPerformer = blockPerformer
		self.path = path
		self.functionFile = functionFile
		self.functionLine = functionLine
	}
	
	
	/// Primary chain form. All other forms translate into this form.
	///
	/// - Parameter function: will be executed as a child link of this `ProcessLink`. Receives `B` (the result of this `ProcessLink` and generates `C`.
	/// - Returns: The child link which has been added to this `ProcessLink`'s child list. Children are executed in parallel. See `ProcessLink`'s description.
	@discardableResult public func chain<C,Failable>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, @escaping (Failable) -> Void) -> Void) -> ProcessLink<C> where Failable: FailableResultProtocol, Failable.Wrapped == C {
		let wrapperFunction = {(a: Any, callback: @escaping (FailableResult<C>) -> Void) -> Void in
			guard let b = a as? B else {
				preconditionFailure("a is not of type B")
			}
			function(b) { failable in
				callback(FailableResult(failable))
			}
		}
		let link = ProcessLink<C>(function: wrapperFunction,
		                             errorHandler: self.errorHandler,
		                             blockPerformer: self.blockPerformer,
		                             path: self.path + ["chain: \(file):\(line) \(functionDescription ?? tname(function))"],
		                             functionFile: file,
		                             functionLine: line)
		self.createdLinksLock.lock()
		self.createdLinks.append(link)
		self.createdLinksLock.unlock()
		return link
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
	            .finally { link in
	                link.chain(funcZ)
	            }
                .chain(funcB)
	            .chain(funcC)
	     }

	 In the preceding example, if no error occurs then the functions will execute in this order: `funcA`, `funcB`, `funcC`, `funcZ`. The error handler, `funcE` will not be executed.
	 If `funcB` produces an error, then execution is as follows: `funcA`, `funcB`, `funcE`, `funcZ`. The links after the error, (`funcC`), will not be executed.

	 - Parameter defineBlock: context within which to define the finally chain.
	 - Returns: a `ProcessLink` with the same execution context as self, but with a finally chain registered.
	*/
	public func finally(_ defineBlock: (ProcessLink<Void>) -> Void ) -> ProcessLink<B> {
		if let oldFinalLink = self.finalLink {
			let _ = oldFinalLink.finally(defineBlock)
		} else {
			let newFinalLink = ProcessLink<Void>(function: { (a, completion) in
				completion(.success(Void()))
			}, errorHandler: self.errorHandler,
			   blockPerformer: self.blockPerformer,
			   path: self.path+["finally"],
			   functionFile: #file,
			   functionLine: #line
			   )
			self.finalLink = newFinalLink
			
			defineBlock(newFinalLink)
		}
		return self
	}
	
	fileprivate func joinPoint() -> JoinPoint<B> {
		let link = JoinPoint<B>(blockPerformer: self.blockPerformer, path: self.path+["joinpoint"], errorHandler: self.errorHandler)
		self.createdLinksLock.lock()
		self.createdLinks.append(link)
		self.createdLinksLock.unlock()
		return link
	}
	
	override func execute(argument: Any, completion fullChainCompletion: @escaping () -> Void) {
		self.myBlockPerformer.asyncPerform {
			var callbackInvoked = false
			let callbackInvokedLock = NSLock()
			
			self.function(argument) { (failableResult: FailableResult<B>) in
				callbackInvokedLock.lock()
				defer {
					callbackInvokedLock.unlock()
				}
				guard !callbackInvoked else {
					return // protect ourselves against clients invoking the callback more than once
				}
				callbackInvoked = true
				
				switch failableResult {
				case .success(let result) :			
					let group = DispatchGroup()
		
					for createdLink in self.createdLinks {
						group.enter()
						self.createdLinksAsyncSemaphore?.wait()
						let workItem = {
							createdLink.execute(argument: result) {
								self.createdLinksAsyncSemaphore?.signal()
								group.leave()
							}
						}
						self.myBlockPerformer.asyncPerform(workItem)
					}
					
					group.notify(queue: .global(), execute: {
						self.myBlockPerformer.asyncPerform {
							if let finalLink = self.finalLink {
								finalLink.execute(argument: Void(), completion: fullChainCompletion)
							} else {
								fullChainCompletion()
							}
						}
					})
					
				case .failure(let error):
					let errorContext = ErrorContext(subject: argument, file: self.functionFile, line: self.functionLine, internalPath: self.path)
					self.errorHandler(error, errorContext)
					if let finalLink = self.finalLink {
						finalLink.execute(argument: Void(), completion: fullChainCompletion)
					} else {
						fullChainCompletion()
					}
				}
			}
		}
	}
}

extension ProcessLink {
	// special forms
	
	/// `insert` inserts a value of any type into the chain data flow.
	///
	/// - Parameter c: Any value
	/// - Returns: a `ProcessLink` whose child links will receive `c` as their function argument.
	public func insert<C>(file: StaticString = #file, line: UInt = #line, _ c: C) -> ProcessLink<C> {
		return self.chain(file: file, line:line, functionDescription: "value") { (b:B, callback: (C) -> Void) in callback(c) }
	}
	
	/// `drop` ignores "drops" the inbound value and returns a `ProcessLink` whose value is `Void`
	///
	/// - Returns: a `ProcessLink` whose child links will receive `Void` as their function argument.
	public func drop(file: StaticString = #file, line: UInt = #line) -> ProcessLink<Void> {
		return self.insert(Void())
	}
	
	/// `tunnel` defines a subchain with whose value is ultimately discarded. The links within the `tunnel` subchain run sequentially before the link which is the return value of `tunnel`. `tunnel` returns a `ProcessLink` whose execution result `B` is the result the receiver link. Thus the value `B` "hides" or "goes under ground" while the subchain processes and "pops back up" when it is completed.
	/// For example:
	///
	///      .insert(8)
	///      .tunnel { link in
	///         link.chain(intToString) //convert int to string
	///		 }
	///      .chain(multiplyInt)
	///
	/// In the example above `insert` results in an `Int` into the chain and that int is passed along to `intToString` which transform the value into a `String`.
	/// After the `tunnel` context has finished, the original value `8` (an `Int`) is passed to `multiplyInt`
	///
	/// - Parameters:
	///   - defineBlock: a block which creates a subchain to be limited.
	/// - Returns: a `ProcessLink` whose execution result `R` is discarded.
	public func tunnel<R>(file: StaticString = #file, line: UInt = #line, _ defineBlock: (ProcessLink<B>) -> ProcessLink<R>) -> ProcessLink<B> {
		var storedB: B? = nil
		
		let openingLink = self.chain { (b:B) -> B in
			storedB = b
			return b
		}
		
		let lastLink = defineBlock(openingLink)
		
		let returnLink = lastLink.chain { (_:R) -> B in
			guard let storedB = storedB else {
				preconditionFailure("should not be nil: storedB")
			}
			return storedB
		}
		
		return returnLink
	}
	
	/// Yields self to a new definition block. Within the block the caller may invoke chaining methods on block multiple times, thus achieving parallel chains. Example:
	///
	///     link.branch { stem in
	///       stem.chain(func1)
	///           .chain(func2)
	///
	///       stem.chain(func3)
	///           .chain(func4)
	///     }
	///
	/// In the preceding example, when `link` is executed it will start the links containing `func1` and `func3` in parallel.
	/// `func2` will execute when `func1` is finished. Likewise `func4` will execute when `func3` is finished.
	///
	/// - Parameter defineBlock: the block to which this `ProcessLink` yields itself.
	public func branch(_ defineBlock: (ProcessLink<B>) -> Void) {
		defineBlock(self)
	}
	
	/// Yields self to a new definition block. Within the block the caller may invoke chaining methods on block multiple times, thus achieving parallel chains. Example:
	///
	///     link.branch { stem in
	///       let a = stem.chain(func1)
	///                   .chain(func2)
	///
	///       let b = stem.chain(func3)
	///                   .chain(func4)
	///
	///		  return (a + b) // operator for .conjoin
	///				   .chain(combine)
	///     }
	///
	/// In the preceding example, when `link` is executed it will start the links containing `func1` and `func3` in parallel.
	/// `func2` will execute when `func1` is finished. Likewise `func4` will execute when `func3` is finished.
	///
	/// - Parameter defineBlock: the block to which this `ProcessLink` yields itself.
	/// - Returns: The link which is returned from defineBlock
	public func branch<C>(_ defineBlock: (ProcessLink<B>) -> ProcessLink<C>) -> ProcessLink<C> {
		return defineBlock(self)
	}
	
	/// `conjoin` is a compliment to `branch`.
	/// Within the context of a `branch` it is natural and expected to create parallel execution chains.
	/// If the process definition wishes at some point to combine the results of these execution chains, then `conjoin` should be used.
	/// `conjoin` returns a `ProcessLink` which waits for both the receiver and the argument `ProcessLink`s have created results. Those results are combined into a tuple `(B,C)` which is passed to the child links of the returned `ProcessLink`
	///
	/// - Parameter other: the `ProcessLink` to join with
	/// - Returns: A `ProcessLink` which combines the receiver and the arguments results.
	public func conjoin<C>(_ other: ProcessLink<C>) -> ProcessLink<(B,C)> {
		return self.joinPoint().conjoin(other.joinPoint())
	}
	
	/// operator syntax for `conjoin` function
	public static func +<C>(lhs: ProcessLink<B>, rhs: ProcessLink<C>) -> ProcessLink<(B,C)> {
		return lhs.conjoin(rhs)
	}
}

extension ProcessLink : ErrorHandling {
	
	/// Establishes a new error handler for this link and all descendant links.
	///
	/// - Parameter errorHandler: a function which takes an Error and an `Any` context object. The context object is usual the object which was being acted upon when the error occurred.
	/// - Returns: A `ProcessLink` which has `errorHandler` installed
	public func setErrorHandler(_ errorHandler: @escaping (Error, ErrorContext) -> Void ) -> ProcessLink<B> {
		self.errorHandler = errorHandler
		return self
	}
}

// function mutation

fileprivate func objcErrorCallbackToSwift(_ function: @escaping (@escaping (Error?)->Void ) -> Void) -> (@escaping (FailableResult<Void>) -> Void) -> Void {
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

fileprivate func objcErrorCallbackToSwift<C>(_ function: @escaping (@escaping (C?, Error?)->Void ) -> Void) -> (@escaping (FailableResult<C>) -> Void) -> Void {
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

fileprivate func populateVoid<T>(failableResult: FailableResult<Void>, with t: T) -> FailableResult<T> {
	switch failableResult {
	case let .failure(error):
		return .failure(error)
	case .success():
		return .success(t)
	}
}

fileprivate func elevate<T>(_ function: @escaping (T) -> (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
	return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
		objcErrorCallbackToSwift(function(t))({ result in
			callback(populateVoid(failableResult: result, with: t))
		})
	}
}

fileprivate func elevate<T>(_ function: @escaping (T, @escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
	return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
		objcErrorCallbackToSwift(function =<< t)({ result in
			callback(populateVoid(failableResult: result, with: t))
		})
	}
}

fileprivate func elevate<T>(_ function: @escaping (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
	return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
		objcErrorCallbackToSwift(function)({ result in
			callback(populateVoid(failableResult: result, with: t))
		})
	}
}

fileprivate func elevate<T, C>(_ function: @escaping (T, @escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<C>) -> Void) -> Void {
	return { (t: T, callback: @escaping (FailableResult<C>) -> Void) -> Void in
		objcErrorCallbackToSwift(bind(function, t))(callback)
	}
}

fileprivate func elevate<C>(_ function: @escaping (@escaping (C?, Error?) -> Void) -> Void) -> (@escaping (FailableResult<C>) -> Void) -> Void {
	return { (callback: @escaping (FailableResult<C>) -> Void) -> Void in
		objcErrorCallbackToSwift(function)(callback)
	}
}

fileprivate func elevate<T, C>(_ function: @escaping (T) -> (@escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<C>) -> Void) -> Void {
	return { (t: T, callback: @escaping (FailableResult<C>) -> Void) -> Void in
		objcErrorCallbackToSwift(function(t))(callback)
	}
}

extension ProcessLink : Chainable {
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> () throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) in
			try function(b)()
			callback(b)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> ((() -> Void)?) throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) in
			try function(b)(){
				callback(b)
			}
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (@escaping () -> Void) throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) in
			try function(b)(){
				callback(b)
			}
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) in
			try function(b)
			callback(b)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, (() -> Void)?) throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) throws in
			try function(b,callback =<< b)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, @escaping () -> Void) throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) throws in
			try function(b,callback =<< b)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping ((() -> Void)?) throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) throws in
			try function(callback =<< b)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (@escaping () -> Void) throws -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (B) -> Void) throws in
			try function(callback =<< b)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function:  @escaping (B) throws -> C ) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (C) -> Void) in
			try callback(function(b))
		}
	}

	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function:  @escaping (B, ((C) -> Void)?) throws -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (C) -> Void) throws in
			try function(b,callback)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (((Error?) -> Void)?) -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (FailableResult<B>) -> Void) in
			elevate(function)(b,callback)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			elevate(function)(b,callback)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, ((Error?) -> Void)?) -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			elevate(function)(b,callback)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, @escaping (Error?) -> Void) -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			elevate(function)(b,callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<C>)->Void) in
			elevate(function)(b, callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<C>)->Void) in
			elevate(function)(b, callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (C) -> Void) throws -> Void in
			try function(b)(callback)
		}
	}

	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> () throws -> C) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (C) -> Void) in
			try callback(function(b)())
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (FailableResult<C>) -> Void) in
			elevate(function)(b, callback)
		}
	}

	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (@escaping (Error?) -> Void) -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			elevate(function)(b,callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (@escaping (C) -> Void) throws -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(callback)
		}
	}

	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (((C?, Error?) -> Void)?) -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<C>)->Void) in
			elevate(function)(callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (@escaping (C?, Error?) -> Void) -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<C>)->Void) in
			elevate(function)(callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (((C) -> Void)?) throws -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(callback)
		}
	}
	
	@discardableResult public
	func chain(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (((Error?) -> Void)?) -> Void) -> ProcessLink<B> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<B>) -> Void) in
			elevate(function)(b,callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (FailableResult<C>)->Void) in
			elevate(function)(b, callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (((C) -> Void)?) throws -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b:B, callback: @escaping (C) -> Void) throws -> Void in
			try function(b)(callback)
		}
	}
	
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, @escaping (C) -> Void) throws -> Void) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (FailableResult<C>) -> Void) in
			do {
				try function(b) { (c: C) -> Void in
					callback(.success(c))
				}
			} catch {
				callback(.failure(error))
			}
		}
	}
}

extension ProcessLink : ChainableFailable {
	
	@discardableResult public
	func chain<C,Failable>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B, ((Failable) -> Void)?) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (FailableResult<C>) -> Void) in
			function(b) { (failable: Failable) -> Void in
				callback(FailableResult(failable))
			}
		}
	}
	
	@discardableResult public
	func chain<C,Failable>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (@escaping (Failable) -> Void) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (FailableResult<C>) -> Void) in
			function(b)( { (failable: Failable) -> Void in
				callback(FailableResult(failable))
			})
		}
	}
	
	@discardableResult public
	func chain<C,Failable>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (B) -> (((Failable) -> Void)?) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (FailableResult<C>) -> Void) in
			function(b)( { (failable: Failable) -> Void in
				callback(FailableResult(failable))
			})
		}
	}
	
	@discardableResult public
	func chain<C,Failable>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ function: @escaping (@escaping (Failable) -> Void) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(function)) { (b: B, callback: @escaping (FailableResult<C>) -> Void) in
			function( { (failable: Failable) -> Void in
				callback(FailableResult(failable))
			})
		}
	}
}

#if swift(>=4.0)
extension ProcessLink {
	// keypath form
	@discardableResult public
	func chain<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ keyPath: KeyPath<B,C>) -> ProcessLink<C> {
		return self.chain(file: file, line: line, functionDescription: functionDescription ?? tname(keyPath)) { (b: B) -> C in
			return b[keyPath: keyPath]
		}
	}
}
#endif

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
	public func setBlockPerformer(_ blockPerformer: AsyncBlockPerformer) -> ProcessLink<B> {
		self.blockPerformer = blockPerformer // set the performer for sub chains, not for this link
		return self
	}
}

extension ProcessLink where B : Collection, B.IndexDistance == Int {
	
	/// When the inbound type is a `Collection` with `Int` indexes (most are), then you may call `map` to asynchronously map over the elements of B in parallel, transforming them with `transform` subchain.
	///
	/// - Parameter transform: the transformation subchain defining block which converts `B.Iterator.Element` to `C`
	/// - Returns: a `ProcessLink` which will yield an array of `C`s to it's child links.
	public func map<C>(withLimit limit: Int? = nil, _ transform: @escaping (ProcessLink<B.Iterator.Element>) -> ProcessLink<C>) -> ProcessLink<[C]> {
		var rootLink: ProcessLink<B>! = nil
		
		let returnSemaphore = DispatchSemaphore(value: 1)
		var returnValue: [C]?
		
		returnSemaphore.wait()
		
		rootLink = self.chain { (collection: B, callback: @escaping () -> Void) -> Void in
			let group = DispatchGroup()
			for _ in collection {
				group.enter()
			}
			group.notify(queue: .global()) {
				assert(rootLink.createdLinks.count == collection.count)
				callback()
			}
			
			collection.asyncMap(on: self.blockPerformer, transform: { (element:B.Iterator.Element, completion:@escaping (C) -> Void) in
				transform(rootLink.insert(element))
					.chain(completion)
				group.leave()
			}, completion: {(c:[C]) in
				returnValue = c
				returnSemaphore.signal()
			})
		}
		
		if let limit = limit {
			rootLink.createdLinksAsyncSemaphore = ProcessLink.semaphore(for: self, withValue: limit)
		}
		
		let finallyLink = ProcessLink<Void>(function: { (_, callback) in callback(.success(Void())) },
		                                    errorHandler: self.errorHandler,
		                                    blockPerformer: self.blockPerformer,
		                                    path: self.path+["map"],
		                                    functionFile: #file,
		                                    functionLine: #line)
		
		rootLink.finalLink = finallyLink
		
		return finallyLink.chain { (_:Void, callback: ([C]) -> Void) -> Void in
			returnSemaphore.wait()
			guard let returnValue = returnValue else {
				preconditionFailure("returnValue should not be nil")
			}
			returnSemaphore.signal()
			callback(returnValue)
		}
	}
	
	/// When the inbound type is a `Collection` with `Int` indexes (most are), then you may call `filter` to asynchronously filter the elements of B in parallel, using `filter` subchain
	///
	/// - Parameter filter: the filter subchain which produces a Bool
	/// - Returns: a `ProcessLink` which will yield to it's child links an array containing those `B.Iterator.Element`s which `filter` approved.
	public func filter(withLimit limit: Int? = nil, _ filter: @escaping (ProcessLink<B.Iterator.Element>) -> ProcessLink<Bool>) -> ProcessLink<[B.Iterator.Element]> {
		return self.map(withLimit: limit, { elem -> ProcessLink<B.Element?> in
			elem.branch { stem in
				return (stem + filter(stem))
						.chain { (elem: B.Element, include: Bool) -> B.Element? in
							include ? elem : nil
						}
			}
		}).chain { optionalList -> [B.Iterator.Element] in
			optionalList.flatMap {$0}
		}
	}
	
	///  When the inbound type is a `Collection` with `Int` indexes (most are), then you may call `each`
	/// Each accepts a define block which creates a subchain which will be invoked once per element of the sequence.
	/// The `ProcessLink` which is given as argument to the define block will pass to its child links the element of the sequence which is currently being processed.
	///
	/// - Parameter defineBlock: a block which creates a subchain for each element of the sequence
	/// - Returns: a ProcessLink which will pass the nonfailing elements of `B` to its child links
	@discardableResult public func each(withLimit limit: Int? = nil, _ defineBlock: @escaping (ProcessLink<B.Iterator.Element>) -> Void) -> ProcessLink<[B.Element]> {
		return self.map(withLimit: limit) { elem in
			elem.tunnel { link -> ProcessLink<B.Iterator.Element> in
				defineBlock(link)
				return link // this shouldn't be necessary
			}
		}
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
	@discardableResult public func optionally<X>(_ defineBlock: @escaping (ProcessLink<B.WrappedType>) -> ProcessLink<X>) -> ProcessLink<Void> {
		
		let returnLink = ProcessLink<Void>(function: {_, block in block(.success(Void()))},
		                                         errorHandler: self.errorHandler,
		                                         blockPerformer: self.blockPerformer,
		                                         path: self.path + ["optionally"],
		                                         functionFile: #file,
		                                         functionLine: #line)
		
		var immediateChain: ProcessLink<B>! = nil
		
		immediateChain = self.chain { (b: B, callback: @escaping ()->Void) in
			if let unwrapped = b.getWrapped() {
				
				let immediateChainFinalLink = ProcessLink<Void>(function: {_, block in block(.success(Void()))},
				                                                  errorHandler: self.errorHandler,
				                                                  blockPerformer: self.blockPerformer,
				                                                  path: self.path + ["optionally"],
				                                                  functionFile: #file,
				                                                  functionLine: #line)
				
				let unwrappedContext = immediateChainFinalLink.insert(unwrapped)
				let lastLinkOfPostivePath = defineBlock(unwrappedContext)
				lastLinkOfPostivePath.finalLink = returnLink
				
				immediateChain.finalLink = immediateChainFinalLink
				callback()
			} else {
				immediateChain.finalLink = returnLink
				callback()
			}
		}
		
		return returnLink
	}
}

fileprivate let limitPathsToSemaphoresLock = NSLock()
fileprivate var limitPathsToSemaphores: [String:DispatchSemaphore] = [:]

extension ProcessLink  {
	fileprivate static func semaphore<X>(for link: ProcessLink<X>, withValue value: Int) -> DispatchSemaphore {
		let pathString = link.path.joined()
		
		limitPathsToSemaphoresLock.lock()
		let semaphore = limitPathsToSemaphores[pathString] ?? DispatchSemaphore(value: value)
		limitPathsToSemaphores[pathString] = semaphore
		limitPathsToSemaphoresLock.unlock()
		return semaphore
	}
	
	/// `limit` defines a subchain with special runtime protections. The links within the `limit` subchain are guaranteed to have at most `maxParallel` parallel executions. `limit` is particularly useful in the context of a fully parallel process when part of the process must access a limited resource pool such as CPU execution contexts or network resources.
	/// This method returns a `ProcessLink` whose execution result `J` is the result of the final link of the subchain. This permits the chain to proceed naturally after limit. For example:
	///
	///      .limit(5) { link in
	///         link.chain(resourceLimitedIntGenerator)
	///		}
	///     .chain(multiplyInt)
	///
	/// In the example above `resourceLimitedIntGenerator` results in an `Int` and that int is passed along to `multipyInt` after the `limit` context has finished.
	///
	/// - Parameters:
	///   - maxParallel: the maximum number of parallel executions permitted for the subchains defined by `defineBlock`
	///   - defineBlock: a block which creates a subchain to be limited.
	/// - Returns: a `ProcessLink` whose execution result `J` is the result of the final link of the subchain.
	@discardableResult public func limit<J>(_ maxParallel: Int, _ defineBlock: (ProcessLink<B>) -> ProcessLink<J>) -> ProcessLink<J> {
		
		let semaphore = ProcessLink.semaphore(for: self, withValue: maxParallel)
		
		let openingLink = self.chain { (b:B) -> B in
			semaphore.wait()
			return b
		}
		var semaphoreReleasedNormally = false
		let _ = openingLink.finally{ link in
			link.chain { () -> Void in
				if !semaphoreReleasedNormally {
					semaphore.signal()
				}
			}
		}
		
		let lastLink = defineBlock(openingLink)
		
		let returnLink = lastLink.chain { (j:J) -> J in
			semaphoreReleasedNormally = true
			semaphore.signal()
			return j
		}
		
		
		return returnLink
	}
}
