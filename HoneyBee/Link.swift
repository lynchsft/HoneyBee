//
//  Link.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/7/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation


/**
`Link` is the primary interface for HoneyBee processes.
A link represents a single asynchronous function, as well as its execution context.
The execution context includes:

1. A `AsyncBlockPerformer` execution context
2. An error handling function for when things go wrong
3. A list of child `Link`s to execute using the result of this link.

A single link's execution process is as follows:

1. Link is executed with the execution argument.
2. This method's function is called with argument. If the function errors, then the error is given to this link's registered error handler along with an optional `ErrorContext`
3. (If the function does not error) The result value B is captured.
4. This link's child links are individually, in parallel executed in this link's `AsyncBlockPerformer`
5. When _all_ of the child links have completed their execution, then this link signals that it has completed execution, via callback.
*/



private class NonErroringExecutableWrapper: Executable<Never> {
    private let executeWrapper: (Any, @escaping () -> Void) -> Void
    init<E: Error>(executable: Executable<E>) {
        self.executeWrapper = executable.execute
    }

    override func execute(argument: Any, completion: @escaping () -> Void) {
        self.executeWrapper(argument, completion)
    }

    override func ancestorFailed(_ context: ErrorContext<Never>) {
        preconditionFailure()
    }
}

extension Link where E == Never {
    /// Primary chain form. All other forms translate into this form.
    ///
    /// - Parameter function: will be executed as a child link of this `Link`. Receives `B` (the result of this `Link` and generates `C`.
    /// - Returns: The child link which has been added to this `Link`'s child list. Children are executed in parallel. See `Link`'s description.
    @discardableResult
    public func chain<C, OtherE: Error>(file: StaticString = #file,
                                                             line: UInt = #line,
                                                             functionDescription: String? = nil,
                                                             _ function: @escaping (B, @escaping (Result<C, OtherE>) -> Void) -> Void) -> Link<C, OtherE, P> {
        let wrapperFunction = {(a: Any, callback: @escaping (Result<C, OtherE>) -> Void) -> Void in
            guard let b = a as? B else {
                let message = "a is not of type B"
                HoneyBee.internalFailureResponse.evaluate(false, message)
                return
            }
            function(b, callback)
        }
        var trace = self.trace
        let fileString = String(describing: file)
        if fileString.contains("HoneyBee/Link.swift") ||
           fileString.contains("HoneyBee/FunctionWrappers.swift") {
            // omit
        } else {
            trace.append(.init(action: (functionDescription ?? tname(function)), file: file, line: line))
        }
        let newLink = Link<C, OtherE, P>(function: wrapperFunction,
                                     blockPerformer: self.blockPerformer,
                                     trace: trace)

        self.createdLinks.push(NonErroringExecutableWrapper(executable: newLink))
        return newLink
    }

    /// Primary chain form. All other forms translate into this form.
   ///
   /// - Parameter function: will be executed as a child link of this `Link`. Receives `B` (the result of this `Link` and generates `C`.
   /// - Returns: The child link which has been added to this `Link`'s child list. Children are executed in parallel. See `Link`'s description.
   @discardableResult
   public func chain<C>(file: StaticString = #file,
                                                            line: UInt = #line,
                                                            functionDescription: String? = nil,
                                                            _ function: @escaping (B, @escaping (Result<C, Never>) -> Void) -> Void) -> Link<C, Never, P> {
       let wrapperFunction = {(a: Any, callback: @escaping (Result<C, E>) -> Void) -> Void in
           guard let b = a as? B else {
               let message = "a is not of type B"
               HoneyBee.internalFailureResponse.evaluate(false, message)
               return
           }
           function(b, callback)
       }
       var trace = self.trace
       let fileString = String(describing: file)
       if fileString.contains("HoneyBee/Link.swift") ||
          fileString.contains("HoneyBee/FunctionWrappers.swift") {
           // omit
       } else {
           trace.append(.init(action: (functionDescription ?? tname(function)), file: file, line: line))
       }
       let newLink = Link<C, E, P>(function: wrapperFunction,
                                    blockPerformer: self.blockPerformer,
                                    trace: trace)

       if let existingFailure = self.ancestorFailureBox.getValue() {
           newLink.ancestorFailed(existingFailure)
       } else {
           self.createdLinks.push(newLink)
       }
       return newLink
   }
}

@dynamicMemberLookup
final public class Link<B, E: Error, P: AsyncBlockPerformer> : Executable<E>  {
	
	fileprivate var createdLinks = ConcurrentQueue<Executable<E>>()
	fileprivate var createdLinksAsyncSemaphore: DispatchSemaphore?
	fileprivate let finalLinkBox = AtomicValue<Link<B, E, P>?>(value: nil)
	let activeLinkCounter: AtomicInt = 0
	
	fileprivate let function: (Any, @escaping (Result<B, E>) -> Void) -> Void

    // Ancestor failure
    fileprivate var ancestorFailureBox = ConcurrentBox<ErrorContext<E>>()
    
	/// The queue which is passed on to sub chains
	fileprivate let blockPerformer: P
	
	// Debug info
	
    var trace: AsyncTrace
    
    fileprivate var functionFile: StaticString {
        self.trace.last.file
    }
    fileprivate var functionLine: UInt {
        self.trace.last.line
    }
	
	init(function:  @escaping (Any, @escaping (Result<B, E>) -> Void) -> Void, blockPerformer: P, trace: AsyncTrace) {
		self.function = function
		self.blockPerformer = blockPerformer
		self.trace = trace
	}
	
	fileprivate func debug(_ message: String) {
		if let debugString = self.debugString(for: message) {
			print(debugString)
		}
	}
	
	fileprivate func debugString(for message: String) -> String? {
		if self.debugInstance {
			return "\(type(of: self)) \(Unmanaged.passUnretained(self).toOpaque()) \(self.functionFile):\(self.functionLine):: \(message)"
		} else {
			return nil
		}
	}

    /// Primary chain form. All other forms translate into this form.
    ///
    /// - Parameter function: will be executed as a child link of this `Link`. Receives `B` (the result of this `Link` and generates `C`.
    /// - Returns: The child link which has been added to this `Link`'s child list. Children are executed in parallel. See `Link`'s description.
    @discardableResult
    public func chain<C>(file: StaticString = #file,
                         line: UInt = #line,
                         functionDescription: String? = nil,
                         _ function: @escaping (B, @escaping (Result<C, E>) -> Void) -> Void) -> Link<C, E, P> {
        let wrapperFunction = {(a: Any, callback: @escaping (Result<C, E>) -> Void) -> Void in
            guard let b = a as? B else {
                let message = "a is not of type B"
                HoneyBee.internalFailureResponse.evaluate(false, message)
                return
            }
            function(b, callback)
        }
        var trace = self.trace
        let fileString = String(describing: file)
        if fileString.contains("HoneyBee/Link.swift") ||
           fileString.contains("HoneyBee/FunctionWrappers.swift") {
            // omit
        } else {
            trace.append(.init(action: (functionDescription ?? tname(function)), file: file, line: line))
        }
        let newLink = Link<C, E, P>(function: wrapperFunction,
                                     blockPerformer: self.blockPerformer,
                                     trace: trace)

        if let existingFailure = self.ancestorFailureBox.getValue() {
            newLink.ancestorFailed(existingFailure)
        } else {
            self.createdLinks.push(newLink)
        }
        return newLink
    }

    /// Primary chain form. All other forms translate into this form.
    ///
    /// - Parameter function: will be executed as a child link of this `Link`. Receives `B` (the result of this `Link` and generates `C`.
    /// - Returns: The child link which has been added to this `Link`'s child list. Children are executed in parallel. See `Link`'s description.
    @discardableResult
    public func chain<C>(file: StaticString = #file,
                         line: UInt = #line,
                         functionDescription: String? = nil,
                         _ function: @escaping (B, @escaping (Result<C, Never>) -> Void) -> Void) -> Link<C, E, P> {
        let wrapperFunction = {(a: Any, callback: @escaping (Result<C, E>) -> Void) -> Void in
            guard let b = a as? B else {
                let message = "a is not of type B"
                HoneyBee.internalFailureResponse.evaluate(false, message)
                return
            }
            function(b) { result in
                switch result {
                case .success(let c):
                    callback(.success(c))
                case .failure(_): // Never
                    preconditionFailure()
                }
            }
        }
        var trace = self.trace
        let fileString = String(describing: file)
        if fileString.contains("HoneyBee/Link.swift") ||
           fileString.contains("HoneyBee/FunctionWrappers.swift") {
            // omit
        } else {
            trace.append(.init(action: (functionDescription ?? tname(function)), file: file, line: line))
        }
        let newLink = Link<C, E, P>(function: wrapperFunction,
                                     blockPerformer: self.blockPerformer,
                                     trace: trace)

        if let existingFailure = self.ancestorFailureBox.getValue() {
            newLink.ancestorFailed(existingFailure)
        } else {
            self.createdLinks.push(newLink)
        }
        return newLink
    }

    /// Primary chain form. All other forms translate into this form.
    ///
    /// - Parameter function: will be executed as a child link of this `Link`. Receives `B` (the result of this `Link` and generates `C`.
    /// - Returns: The child link which has been added to this `Link`'s child list. Children are executed in parallel. See `Link`'s description.
    @discardableResult
    public func chain<C, OtherE: Error>(file: StaticString = #file,
                                                             line: UInt = #line,
                                                             functionDescription: String? = nil,
                                                             _ function: @escaping (B, @escaping (Result<C, OtherE>) -> Void) -> Void) -> Link<C, Error, P> {
        let wrapperFunction = {(a: Any, callback: @escaping (Result<C, Error>) -> Void) -> Void in
            guard let b = a as? B else {
                let message = "a is not of type B"
                HoneyBee.internalFailureResponse.evaluate(false, message)
                return
            }
            function(b) { result in
                switch result {
                case .success(let c):
                    callback(.success(c))
                case .failure(_): // Never
                    preconditionFailure()
                }
            }
        }
        var trace = self.trace
        let fileString = String(describing: file)
        if fileString.contains("HoneyBee/Link.swift") ||
           fileString.contains("HoneyBee/FunctionWrappers.swift") {
            // omit
        } else {
            trace.append(.init(action: (functionDescription ?? tname(function)), file: file, line: line))
        }
        let newLink = Link<C, Error, P>(function: wrapperFunction,
                                     blockPerformer: self.blockPerformer,
                                     trace: trace)

        if let existingFailure = self.ancestorFailureBox.getValue() {
            newLink.ancestorFailed(existingFailure as! ErrorContext<Error>)
        } else {
            self.createdLinks.push(newLink as! Self)
        }
        return newLink
    }

	/**
	 `finally` creates a subchain which will be executed whether or not the proceeding chain errors.
	 In the case that no error occurs in the proceeding chain, finally is executed after the final link of the chain, as though it had been directly appended there.
	 In the case that an error, the subchain defined by `finally` will be executed after the error handler has finished.

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
	 - Returns: a `Link` with the same execution context as self, but with a finally chain registered.
	*/
    @discardableResult
	public func finally(file: StaticString = #file, line: UInt = #line, _ defineBlock: (Link<B, E, P>) -> Void ) -> Link<B, E, P> {
		if let oldFinalLink = self.finalLinkBox.get() {
			let _ = oldFinalLink.finally(file: file, line: line, defineBlock)
		} else {
			var bb:B? = nil
			
			var trace = self.trace
			trace.append(.init(action: "finally", file: file, line: line))
			let newFinalLink = Link<B, E, P>(function: { (_: Any, completion: (Result<B, E>)->Void) in
				completion(.success(bb!))
			},
			   blockPerformer: self.blockPerformer,
			   trace: trace)
			
            self.chain { (b:B) -> Void in
				bb = b
            }
			self.finalLinkBox.set(value: newFinalLink)
			
			defineBlock(newFinalLink)
		}
		return self
	}
	
	fileprivate func joinPoint() -> JoinPoint<B, E, P> {
		let link = JoinPoint<B, E, P>(blockPerformer: self.blockPerformer,
								trace: self.trace)
        self.createdLinks.push(link)
		return link
	}
	
	override func execute(argument: Any, completion: @escaping () -> Void) {
		self.blockPerformer.asyncPerform {
			self.executeFunction(with: argument, completion: completion)
		}
	}
	
    override func ancestorFailed(_ context: ErrorContext<E>) {
		self.propagateFailureToDecendants(context)
	}
	
	public subscript(_ block: @escaping (B)->Void) -> Link<Void, E, P> {
        self.chain { (b:B, callback: @escaping FunctionWrapperCompletion<Void,Never>) in
            elevate(block =<< b)(callback)
        }
	}
	
	public subscript<R>(_ block: @escaping (B)->R) -> Link<R, E, P> {
        self.chain { (b:B, callback: @escaping FunctionWrapperCompletion<R,Never>) in
            elevate(block =<< b)(callback)
        }
	}
    
    
    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, TripleArgFunction<X,Y,Z,R,E>>) -> AsyncTripleArgFunction<X,Y,Z,R,E,P> {
        let dropped = self.drop
        return AsyncTripleArgFunction(link: dropped) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: TripleArgFunction<X,Y,Z,R,E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(dropped)(x)(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, DoubleArgFunction<Y,Z,R,E>>) -> AsyncDoubleArgFunction<Y,Z,R,E,P> {
        let dropped = self.drop
        return AsyncDoubleArgFunction(link: dropped) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: DoubleArgFunction<Y,Z,R,E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(dropped)(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, SingleArgFunction<Z,R,E>>) -> AsyncSingleArgFunction<Z,R,E,P> {
        let dropped = self.drop
        return AsyncSingleArgFunction(link: dropped) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: SingleArgFunction<Z,R,E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(dropped)(z).onResult(completion)
            }
        }
    }
    
    public subscript<R>(dynamicMember keyPath: KeyPath<B, ZeroArgFunction<R, E>>) -> AsyncZeroArgFunction<R,E,P> {
        let dropped = self.drop
        return AsyncZeroArgFunction(link: dropped) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: ZeroArgFunction<R, E>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(dropped).onResult(completion)
            }
        }
    }

    public subscript<X,Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundTripleArgFunction<X,Y,Z,R,E,P>>) -> AsyncTripleArgFunction<X,Y,Z,R,E,P> {
        let dropped = self.drop
        return AsyncTripleArgFunction(link: dropped) { (x: Link<X, E, P>, y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (triple: BoundTripleArgFunction<X,Y,Z,R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                triple(dropped)(x)(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Y,Z,R>(dynamicMember keyPath: KeyPath<B, BoundDoubleArgFunction<Y,Z,R,E,P>>) -> AsyncDoubleArgFunction<Y,Z,R,E,P> {
        let dropped = self.drop
        return AsyncDoubleArgFunction(link: dropped) { (y: Link<Y, E, P>, z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (double: BoundDoubleArgFunction<Y,Z,R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                double(dropped)(y)(z).onResult(completion)
            }
        }
    }

    public subscript<Z,R>(dynamicMember keyPath: KeyPath<B, BoundSingleArgFunction<Z,R,E,P>>) -> AsyncSingleArgFunction<Z,R,E,P> {
        let dropped = self.drop
        return AsyncSingleArgFunction(link: dropped) { (z: Link<Z, E, P>) -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (single: BoundSingleArgFunction<Z,R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                single(dropped)(z).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, BoundZeroArgFunction<R,E,P>>) -> AsyncZeroArgFunction<R,E,P> {
        let dropped = self.drop
        return AsyncZeroArgFunction(link: dropped) { () -> Link<R, E, P> in
            self[dynamicMember: keyPath].chain { (zero: BoundZeroArgFunction<R,E,P>, completion: @escaping FunctionWrapperCompletion<R,E>) in
                zero(dropped).onResult(completion)
            }
        }
    }

    public subscript<R>(dynamicMember keyPath: KeyPath<B, R>) -> Link<R, E, P> {
        self.chain(functionDescription: tname(keyPath)) { (b: B, completion: @escaping FunctionWrapperCompletion<R,E>) in
            completion(.success(b[keyPath: keyPath]))
        }
    }
}

extension Link {
	
	static func exectute(finally: Link<B, E, P>?, completion: @escaping () -> Void) {
		if let finalLink = finally {
			finalLink.execute(argument: (), completion: completion)
		} else {
			completion()
		}
	}
	
    private func processError(_ error: E, with argument: Any, completion: @escaping ()->Void) {
		self.blockPerformer.asyncPerform {
			let errorContext = ErrorContext(subject: argument, error: error, trace: self.trace)

			// why not execute finally link here? Finally links are registered on `self`.
			// If self errors, there is no downward chain to finally back from.
			self.propagateFailureToDecendants(errorContext)
			completion()
		}
	}
	
	private func processSuccess(result: B, completion: @escaping () -> Void) {
		let linkBox = self.finalLinkBox
		self.activeLinkCounter.notify {
			Link.exectute(finally: linkBox.get(), completion: completion)
		}
	
		self.activeLinkCounter.guaranteeValueAtDeinit(0)
	
		self.createdLinks.drain { [weak self] createdLink in
			if let this = self {
				this.activeLinkCounter.increment()
				this.createdLinksAsyncSemaphore?.wait()
				this.blockPerformer.asyncPerform {
					createdLink.execute(argument: result, completion: guarantee(faultResponse: HoneyBee.internalFailureResponse) {
						this.createdLinksAsyncSemaphore?.signal()
						this.activeLinkCounter.decrement()
					})
				}
			} else {
				HoneyBee.internalFailureResponse.evaluate(false, "Lost self reference")
			}
		}
	}
	
	private func processResult(_ result: Result<B, E>, with argument: Any, completion: @escaping () -> Void) {
		switch result {
		case .success(let result) :
			self.processSuccess(result: result, completion: completion)
		case .failure(let error):
			self.processError(error, with: argument, completion: completion)
		}
	}
	
	fileprivate func executeFunction(with argument: Any, completion: @escaping () -> Void) {
		let callbackInvoked:AtomicBool = false
		let file = self.functionFile
		let line = self.functionLine
		callbackInvoked.guaranteeTrueAtDeinit(faultResponse: HoneyBee.functionUndercallResponse, file: file, line: line, message: "This function didn't callback: ")
		
		self.function(argument) { (result: Result<B, E>) in
			guard callbackInvoked.setTrue() == false else {
				HoneyBee.functionOvercallResponse.evaluate(false, "HoneyBee Warning: This function called back more than once: \(file):\(line)")
				return // protect ourselves against clients invoking the callback more than once
			}
			
			self.processResult(result, with: argument, completion: completion)
		}
	}
	
    fileprivate func propagateFailureToDecendants(_ context: ErrorContext<E>) {
        self.ancestorFailureBox.setValue(context)
		self.createdLinks.drain { child in
            child.ancestorFailed(context)
		}
		self.finalLinkBox.get()?.ancestorFailed(context)
	}
}

extension Link {
    // Result special form
//    @discardableResult
//    public func onResult(file: StaticString = #file,  line: UInt = #line, _ completion: @escaping  (Result<B, ErrorContext<E>>) -> Void) -> Link<B, E, P> {
//        self.chain { (b: B, callback: @escaping (Result<Void, E>) -> Void) in
//            completion(.success(b))
//            callback(.success(Void()))
//        }
//        self.ancestorFailureBox.yieldValue(file: file, line: line) { context in
//            completion(.failure(context))
//        }
//        return self
//    }

    @discardableResult
    public func onResult(file: StaticString = #file, line: UInt = #line, _ completion: @escaping  (Result<B, E>) -> Void) -> Link<B, E, P> {
        self.chain { (b: B, callback: @escaping (Result<Void, E>) -> Void) in
            completion(.success(b))
            callback(.success(Void()))
        }
        self.ancestorFailureBox.yieldValue(file: file, line: line) { context in
            completion(.failure(context.error))
        }
        return self
    }

    @discardableResult
    public func onResult(file: StaticString = #file, line: UInt = #line, _ completion: @escaping  (Result<B, ErrorContext<E>>) -> Void) -> Link<B, E, P> {
        self.chain { (b: B, callback: @escaping (Result<Void, E>) -> Void) in
            completion(.success(b))
            callback(.success(Void()))
        }
        self.ancestorFailureBox.yieldValue(file: file, line: line) { context in
            completion(.failure(context))
        }
        return self
    }

    @discardableResult
    public func onCompletion(file: StaticString = #file,  line: UInt = #line, _ completion: @escaping  (ErrorContext<E>?) -> Void) -> Link<B, E, P> {
        self.chain { (b: B, callback: @escaping (Result<Void, E>) -> Void) in
            completion(nil)
            callback(.success(Void()))
        }
        self.ancestorFailureBox.yieldValue(file: file, line: line) { context in
            completion(context)
        }
        return self
    }

    @discardableResult
    public func onCompletion(file: StaticString = #file, line: UInt = #line, _ completion: @escaping  (E?) -> Void) -> Link<B, E, P> {
        self.chain { (b: B, callback: @escaping (Result<Void, E>) -> Void) in
            completion(nil)
            callback(.success(Void()))
        }
        self.ancestorFailureBox.yieldValue(file: file, line: line) { context in
            completion(context.error)
        }
        return self
    }

    @discardableResult
    public func onError(file: StaticString = #file, line: UInt = #line, _ completion: @escaping (ErrorContext<E>) -> Void) -> Link<B, E, P> {
        self.ancestorFailureBox.yieldValue(file: file, line: line) { context in
            completion(context)
        }
        return self
    }

    @discardableResult
    public func onError(file: StaticString = #file, line: UInt = #line, _ completion: @escaping (E) -> Void) -> Link<B, E, P> {
        self.ancestorFailureBox.yieldValue(file: file, line: line) { context in
            completion(context.error)
        }
        return self
    }
}

extension Link {
	// special forms

    @discardableResult
    public func chain<R>(_ function: @escaping (B)->R) -> Link<R,E,P> {
        self.chain { (b, completion: @escaping (Result<R, Never>) -> Void) in
            completion(.success(function(b)))
        }
    }
	
	/// `insert` inserts a value of any type into the chain data flow.
	///
	/// - Parameter c: Any value
	/// - Returns: a `Link` whose child links will receive `c` as their function argument.
	public func insert<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ c: C) -> Link<C, E, P> {
        self.chain(file: file, line:line, functionDescription: functionDescription ?? "insert") { (_:B, callback: @escaping (Result<C,Never>) -> Void) in
            callback(.success(c))
        }
	}
	
	/// `drop` ignores "drops" the inbound value and returns a `Link` whose value is `Void`
	///
	/// - Returns: a `Link` whose child links will receive `Void` as their function argument.
	public var drop: Link<Void, E, P> {
		return self.insert(Void())
	}
	
	/// `tunnel` defines a subchain with whose value is ultimately discarded. The links within the `tunnel` subchain run sequentially before the link which is the return value of `tunnel`. `tunnel` returns a `Link` whose execution result `B` is the result the receiver link. Thus the value `B` "hides" or "goes under ground" while the subchain processes and "pops back up" when it is completed.
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
	/// - Returns: a `Link` whose execution result `R` is discarded.
    public func tunnel<R, OtherE: Error, OtherP: AsyncBlockPerformer>(file: StaticString = #file, line: UInt = #line, _ defineBlock: (Link<B, E, P>) -> Link<R, OtherE, OtherP>) -> Link<B, OtherE, P> {
		var storedB: B? = nil
		
		let openingLink = self.chain { (b:B) -> B in
			storedB = b
			return b
		}
		
		let lastLink = defineBlock(openingLink)
		
		let returnLink = lastLink.move(to: self.blockPerformer).chain { (_:R) -> B in
			guard let storedB = storedB else {
				let message = "Lost self reference"
				HoneyBee.internalFailureResponse.evaluate(false, message)
				preconditionFailure(message)
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
	/// - Parameter defineBlock: the block to which this `Link` yields itself.
	public func branch(_ defineBlock: (Link<B, E, P>) -> Void) {
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
	///		   return (a + b) // operator for .conjoin
	///     }
	///		.chain(combine)
	///
	/// In the preceding example, when `link` is executed it will start the links containing `func1` and `func3` in parallel.
	/// `func2` will execute when `func1` is finished. Likewise `func4` will execute when `func3` is finished.
	///
	/// - Parameter defineBlock: the block to which this `Link` yields itself.
	/// - Returns: The link which is returned from defineBlock
	@discardableResult
    public func branch<C, OtherE: Error, OtherP: AsyncBlockPerformer>(_ defineBlock: (Link<B, E, P>) -> Link<C, OtherE, OtherP>) -> Link<C, OtherE, OtherP> {
		return defineBlock(self)
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
	///		   return (a + b) // operator for .conjoin
	///     }
	///		.chain(combine)
	///
	/// In the preceding example, when `link` is executed it will start the links containing `func1` and `func3` in parallel.
	/// `func2` will execute when `func1` is finished. Likewise `func4` will execute when `func3` is finished.
	///
	/// - Parameter defineBlock: the block to which this `Link` yields itself.
	/// - Returns: The link which is returned from defineBlock
	@discardableResult
	public func branch<C>(_ defineBlock: (Link<B, E, P>) -> Link<C, E, P>) -> Link<C, E, P> {
		return defineBlock(self)
	}
	
	/// `conjoin` is a compliment to `branch`.
	/// Within the context of a `branch` it is natural and expected to create parallel execution chains.
	/// If the process definition wishes at some point to combine the results of these execution chains, then `conjoin` should be used.
	/// `conjoin` returns a `Link` which waits for both the receiver and the argument `Link`s created results. Those results are combined into a tuple `(B,C)` which is passed to the child links of the returned `Link`
	///
	/// - Parameter other: the `Link` to join with
	/// - Returns: A `Link` which combines the receiver and the arguments results.
	public func conjoin<C>(_ other: Link<C, E, P>) -> Link<(B,C), E, P> {
		return self.joinPoint().conjoin(other.joinPoint())
	}
	
	/// `conjoin` is a compliment to `branch`.
	/// Within the context of a `branch` it is natural and expected to create parallel execution chains.
	/// If the process definition wishes at some point to combine the results of these execution chains, then `conjoin` should be used.
	/// `conjoin` returns a `Link` which waits for both the receiver and the argument `Link`s created results. Those results are combined into a tuple `(X, Y, C)` which is passed to the child links of the returned `Link`
	///
	/// - Parameter other: the `Link` to join with
	/// - Returns: A `Link` which combines the receiver and the arguments results.
	public func conjoin<X,Y,C>(other: Link<C, E, P>) -> Link<(X,Y,C), E, P> where B == (X,Y) {
        self.conjoin(other).chain { (compoundTuple, completion: @escaping FunctionWrapperCompletion<(X,Y,C), E>) in
            completion(.success((compoundTuple.0.0, compoundTuple.0.1, compoundTuple.1)))
        }
	}
	
	/// `conjoin` is a compliment to `branch`.
	/// Within the context of a `branch` it is natural and expected to create parallel execution chains.
	/// If the process definition wishes at some point to combine the results of these execution chains, then `conjoin` should be used.
	/// `conjoin` returns a `Link` which waits for both the receiver and the argument `Link`s created results. Those results are combined into a tuple `(X, Y, Z, C)` which is passed to the child links of the returned `Link`
	///
	/// - Parameter other: the `Link` to join with
	/// - Returns: A `Link` which combines the receiver and the arguments results.
	public func conjoin<X,Y,Z,C>(other: Link<C, E, P>) -> Link<(X,Y,Z,C), E, P> where B == (X,Y,Z) {
        self.conjoin(other).chain { (compoundTuple, completion: @escaping FunctionWrapperCompletion<(X,Y,Z,C), E>) in
            completion(.success((compoundTuple.0.0, compoundTuple.0.1, compoundTuple.0.2, compoundTuple.1)))
		}
	}
}

/// operator syntax for `conjoin` function
public func +<B, C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<(B,C), CommonE, CommonP> {
	lhs.conjoin(rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y), CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<(X,Y,C), CommonE, CommonP> {
	lhs.conjoin(other: rhs)
}

/// operator syntax for `conjoin` function
public func +<X,Y,Z,C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<(X,Y,Z), CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<(X,Y,Z,C), CommonE, CommonP> {
	lhs.conjoin(other: rhs)
}

/// operator syntax for `join left` behavior
///
/// - Parameters:
///   - lhs: Link whose value to propagate
///   - rhs: Link whose value to drop
/// - Returns: a Link which contains the value of the left-hand Link
public func <+<B, C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<B, CommonE, CommonP> {
    lhs.conjoin(rhs).chain { (b_c, completion: @escaping (Result<B, CommonE>)->Void) in
        completion(.success(b_c.0))
    }
}

/// operator syntax for `join right` behavior
///
/// - Parameters:
///   - lhs: Link whose value to drop
///   - rhs: Link whose value to propagate
/// - Returns: a Link which contains the value of the left-hand Link
public func +><B, C, CommonE: Error, CommonP: AsyncBlockPerformer>(lhs: Link<B, CommonE, CommonP>, rhs: Link<C, CommonE, CommonP>) -> Link<C, CommonE, CommonP> {
	lhs.conjoin(rhs).chain { (b_c, completion: @escaping (Result<C, CommonE>)->Void) in
        completion(.success(b_c.1))
    }
}

public func >><B, CommonE: Error, PerformerB: AsyncBlockPerformer, PerformerC: AsyncBlockPerformer>(lhs: Link<B, CommonE, PerformerB>, rhs: Link<Void, CommonE, PerformerC>) -> Link<B, CommonE, PerformerC> {
    lhs.move(to: rhs.getBlockPerformer()) <+ rhs
}

public func >><B, E: Error, PerformerB: AsyncBlockPerformer, PerformerC: AsyncBlockPerformer>(lhs: Link<B, E, PerformerB>, rhs: PerformerC) -> Link<B, E, PerformerC> {
    lhs.move(to: rhs)
}

public func >><E: Error, PerformerB: AsyncBlockPerformer, PerformerC: AsyncBlockPerformer>(lhs: Link<Void, E, PerformerB>, rhs: PerformerC) -> Link<Void, E, PerformerC> {
    lhs.move(to: rhs)
}

public func >><B, E: Error, PerformerC: AsyncBlockPerformer>(lhs: @autoclosure @escaping () -> B, rhs: Link<Void, E, PerformerC>) -> Link<B, E, PerformerC> {
    rhs.chain { (_, completion: @escaping (Result<B,E>)->Void) in
        elevate(lhs)(completion)
    }
}


extension Link {
	// AsyncBlockperformer management
	
	/// Set the execution queue for all descendant links. N.B. *this does not change the execution queue for the receiver's function.*
	/// Example
	///
	///     HoneyBee.start(on: .main) { root in
	///        root.setErrorHandlder(handleError)
    ///            .chain(funcA)
	///            .setBlockPerformer(DispatchQueue.global())
	///            .chain(funcB)
	///     }
	///
	/// In the preceding example, `funcA` will run on `DispatchQueue.main` and `funcB` will run on `DispatchQueue.global()`
	///
	/// - Parameter queue: the new `DispatchQueue` for child links
	/// - Returns: the receiver
	@available(swift, obsoleted: 5.0, renamed: "move(to:)")
	public func setBlockPerformer<OtherP: AsyncBlockPerformer>(file: StaticString = #file, line: UInt = #line, _ otherPerformer: OtherP) -> Link<B, E, OtherP> {
		return self.move(to: otherPerformer, file: file, line: line)
	}
	
	/// Returns a new link with the given AsyncBlockperformer. N.B. *this does not change the execution queue for the receiver's function.*
	/// Example
	///
	///     HoneyBee.start(on: .main) { root in
	///        root.setErrorHandlder(handleError)
	///            .chain(funcA)
	///            .move(to: DispatchQueue.global())
	///            .chain(funcB)
	///     }
	///
	/// In the preceding example, `funcA` will run on `DispatchQueue.main` and `funcB` will run on `DispatchQueue.global()`
	///
	/// - Parameter otherPerformer: the new `AsyncBlockPerformer` for child link
	/// - Returns: the receiver
	public func move<OtherP: AsyncBlockPerformer>(to otherPerformer: OtherP, file: StaticString = #file, line: UInt = #line) -> Link<B, E, OtherP> {
		let wrapperFunction = {(a: Any, callback: @escaping (Result<B, E>) -> Void) -> Void in
			guard let b = a as? B else {
				let message = "a is not of type B"
				HoneyBee.internalFailureResponse.evaluate(false, message)
				return
			}
			callback(.success(b))
		}
		var trace = self.trace
		trace.append(.init(action: "switch to \(String(describing: OtherP.self))", file: file, line: line))
		let link = Link<B, E, OtherP>(function: wrapperFunction,
										  blockPerformer: otherPerformer,
										  trace: trace)
		self.createdLinks.push(link)
		return link
	}
}

extension Link where E == Never {
    public func expect<OtherE: Error>(_ other: OtherE.Type, file: StaticString = #file, line: UInt = #line) -> Link<B,OtherE,P>{
        self.chain(file: file, line: line, functionDescription: "expect \(OtherE.self)") { (b, completion) in
            completion(.success(b))
        }
    }
}


extension Link where B : Collection, E: FailureRateAwareError {

	/// When the inbound type is a `Collection`, you may call `map` to asynchronously map over the elements of B in parallel, transforming them with `transform` subchain.
	///
	/// - Parameter transform: the transformation subchain defining block which converts `B.Iterator.Element` to `C`
	/// - Returns: a `Link` which will yield an array of `C`s to it's child links.
    public func map<C>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, limit: Int? = nil, acceptableFailure: FailureRate = .none, _ transform: @escaping (Link<B.Iterator.Element, E, P>) -> Link<C, E, P>) -> Link<[C], E, P> {

        self.chain(file: file, line: line, functionDescription: functionDescription ?? "map") { (collection: B, callback: @escaping (Result<[C], E>) -> Void) in
			var results:[C?] = Array(repeating: .none, count: collection.count)

			let rootLink = self.insert(file: file, line: line, functionDescription: functionDescription ?? "map", Void())
			if let limit = limit {
				rootLink.createdLinksAsyncSemaphore = Link.semaphore(for: rootLink, withValue: limit)
			}

			let _ = rootLink.finally { link in
					link.chain { () -> Void in
						let finalResults = results.compactMap { $0 }
						let failures = results.count - finalResults.count

                        if let excceedError: E = acceptableFailure.checkExceeded(byFailures: failures, in: results.count) {
                            callback(.failure(excceedError))
                        } else {
                            callback(.success(finalResults))
                        }
					}
				}

			let integrationSerialQueue = DispatchQueue(label: "HoneyBee-Map-IntegrationQueue")

			for (index, element) in collection.enumerated() {
                transform(element >> rootLink)
                    .move(to: integrationSerialQueue)
                    .chain { (result:C) -> Void in
                        results[index] = result
                    }

			}
		}
	}
//
//	/// When the inbound type is a `Collection`, you may call `filter` to asynchronously filter the elements of B in parallel, using `filter` subchain
//	///
//	/// - Parameter filter: the filter subchain which produces a Bool
//	/// - Returns: a `Link` which will yield to it's child links an array containing those `B.Iterator.Element`s which `filter` approved.
    public func filter(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, limit: Int? = nil, acceptableFailure: FailureRate = .none, _ filter: @escaping (Link<B.Iterator.Element, E, P>) -> Link<Bool, E, P>) -> Link<[B.Iterator.Element],E, P> {
		return self.map(file: file, line: line, functionDescription: functionDescription ?? "filter", limit: limit, acceptableFailure: acceptableFailure, { elem -> Link<B.Element?, E, P> in
			elem.branch { stem in
				return (stem + filter(stem))
						.chain { (elem: B.Element, include: Bool) -> B.Element? in
							include ? elem : nil
						}
			}
		}).chain { (optionalList: [B.Iterator.Element?]) -> [B.Iterator.Element] in
			optionalList.compactMap {$0}
		}
	}

	/// When the inbound type is a `Collection`, you may call `each`
	/// Each accepts a define block which creates a subchain which will be invoked once per element of the sequence.
	/// The `Link` which is given as argument to the define block will pass to its child links the element of the collection which is currently being processed.
	///
	/// - Parameter defineBlock: a block which creates a subchain for each element of the Collection
    /// - Returns: a Link which will pass the collection `B` to its child links
    @discardableResult
    public func each(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, limit: Int? = nil, acceptableFailure: FailureRate = .none, _ defineBlock: @escaping (Link<B.Element, E, P>) -> Void) -> Link<B, E, P> {
        self.tunnel { collection in
            self.map(file: file, line: line, functionDescription: functionDescription ?? "each", limit: limit, acceptableFailure: acceptableFailure) { elem -> Link<B.Element, E, P> in
                defineBlock(elem)
                return elem
            }
        }
	}

	/// When the inbound type is a `Collection`, you may call `each`
	/// Each accepts a define block which creates a subchain which will be invoked once per element of the sequence.
	/// The `Link` which is given as argument to the define block will pass to its child links the element of the collection which is currently being processed.
	///
	/// - Parameter defineBlock: a block which creates a subchain for each element of the Collection
	/// - Returns: a Link which will pass an Array of the nonfailing elements of `B` to its child links
	@discardableResult
    public func each<R>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, limit: Int? = nil, acceptableFailure: FailureRate = .none, _ defineBlock: @escaping (Link<B.Element, E, P>) -> Link<R, E, P>) -> Link<[B.Element], E, P> {
		self.map(file: file, line: line, functionDescription: functionDescription ?? "each", limit: limit, acceptableFailure: acceptableFailure) { elem in
			elem.tunnel { link in
				defineBlock(link)
			}
		}
	}
//
//	///  When the inbound type is a `Collection`, you may call `reduce`
//	///  Reduce accepts a define block which creates a subchain which will be executed *sequentially*,
//	///  once per element of the sequence. The result of each successive execution of the subchain will
//	///  be forwarded to the next pass of the subchain. The result of the final execution of the subchain
//	///  will be forwarded to the returned link.
//	///
//	/// - Parameters:
//	///   - t: the value to reduce onto. In many cases this value can be called an "accumulator"
//	///   - acceptableFailure: the acceptable failure rate
//	///   - defineBlock: a block which creates a subchain for each element of the Collection
//	/// - Returns: a Link which will pass the result of the reduce to its child links.
    public func reduce<T>(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, with t: T, acceptableFailure: FailureRate = .none, _ defineBlock: @escaping (Link<(T,B.Element), E, P>) -> Link<T, E, P>) -> Link<T, E, P> {
        let atomicT = AtomicValue(value: t)

        return self.each(file: file, line: line, functionDescription: functionDescription ?? "reduce", limit: 1, acceptableFailure: acceptableFailure) { (elem: Link<B.Element, E, P>) in
            defineBlock(elem.drop.chain(atomicT.get) + elem)
				.chain { (newT: T) in
                    atomicT.set(value: newT)
				}
		}
		.chain { (_:[B.Element]) -> T in
            atomicT.get()
		}
	}

	/// When the inbound type is a `Collection`, you may call `reduce`
	/// Reduce accepts a define block which creates a subchain which will be executed *in parallel*,
	/// with up to N/2 other subchains. Each subchain combines two `B.Element`s into one `B.Element`.
	/// The result of each combination is again combined until a single value remains. This value
	/// is forwarded to the returned link.
	///
	/// - Parameter defineBlock: a block which creates a subchain to combined two elements of the Collection
	/// - Returns: a Link which will pass the final combined result of the reduce to its child links.
    public func reduce(file: StaticString = #file, line: UInt = #line, functionDescription: String? = nil, _ defineBlock: @escaping (Link<(B.Element,B.Element), E, P>) -> Link<B.Element, E, P>) -> Link<B.Element, E, P> {

		var elemLinks = Array<Link<B.Element, E, P>>()

        return self.each(file: file, line: line, functionDescription: functionDescription ?? "reduce") { (elemLink: Link<B.Element, E, P>)  in
            elemLinks.append(elemLink)
        }.chain { (_:B, completion: @escaping (Result<B.Element, E>) -> Void) in
			let reportedFailure: AtomicBool = false
			let reportedSuccess: AtomicBool = false
			func applyFinally(to link: Link<B.Element, E, P>) {
				if link.finalLinkBox.get() == nil {
					let _ = link.finally { link in
						link.chain { (_:B.Element) -> Void in
							if !reportedSuccess.get() {
								reportedFailure.access { reported in
									if reported == false {
                                        completion(.failure(E.failureRateExceeded(FailureRate.none)))
										reported = true
									}
								}
							}
						}
					}
				}
			}
			while elemLinks.count >= 2 {
				let e1 = elemLinks.removeFirst()
				let e2 = elemLinks.removeFirst()
				applyFinally(to: e1)
				applyFinally(to: e2)

				let e12 = defineBlock(e1+e2)
				elemLinks.append(e12)
			}

			let lastLink = elemLinks.removeFirst()
			lastLink.chain { (b: B.Element) -> Void in
				reportedSuccess.setTrue()
				completion(.success(b))
			}
		}
	}
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

//extension Link where B : OptionalProtocol {
//	/// When `B` is an `Optional` you may call `optionally`. The supplied define block creates a subchain which will be run if the Optional value is non-nil. The `Link` given to the define block yields a non-optional value of `B.WrappedType` to its child links
//	/// This function returns a `Link` with a `B` result value, because the subchain defined by optionally will not be executed if `B` is `nil`.
//	///
//	/// - Parameter defineBlock: a block which creates a subchain to run if B is non-nil
//	/// - Returns: a `Link<B>`
//	@discardableResult
//    public func optionally<X>(_ defineBlock: @escaping (Link<B.WrappedType, E, P>) -> Link<X, E, P>) -> Link<B, E, P> {
//        let dropped = self.drop
//        self.chain { (b: B, completion: @escaping (Result<B,E>) -> Void) in
//			if let unwrapped = b.getWrapped() {
//                defineBlock(dropped.insert(unwrapped)).insert(b).chain(completion)
//			} else {
//                completion(.success(b))
//			}
//		}
//	}
//
//    /// When `B` is an `Optional` you may call `map`. The supplied define block creates a subchain which will be run if the Optional value is non-nil. The `Link` given to the define block yields a non-optional value of `B.WrappedType` to its child links
//    /// This function returns a `Link` with a` X?` result value, because the subchain defined by optionally will not be executed if `B` is `nil`.
//    ///
//    /// - Parameter defineBlock: a block which creates a subchain to run if B is non-nil
//    /// - Returns: a `Link` with a void value type.
//    @discardableResult
//    public func map<X>(_ defineBlock: @escaping (Link<B.WrappedType, E, P>) -> Link<X, E, P>) -> Link<X?, E, P> {
//        let dropped = self.drop
//        return self.chain { (b: B, completion: @escaping (Result<X?, E>) -> Void) in
//            if let unwrapped = b.getWrapped() {
//                defineBlock(dropped.insert(unwrapped)).chain(completion)
//            } else {
//                completion(.success(nil))
//            }
//        }
//    }
//}

fileprivate let limitPathsToSemaphoresLock = NSLock()
fileprivate var limitPathsToSemaphores: [String:DispatchSemaphore] = [:]

extension Link  {
	fileprivate static func semaphore<X, SomeError, SomePerformer>(for link: Link<X, SomeError, SomePerformer>, withValue value: Int) -> DispatchSemaphore {
		let pathString = link.trace.toString()
		
		limitPathsToSemaphoresLock.lock()
		let semaphore = limitPathsToSemaphores[pathString] ?? DispatchSemaphore(value: value)
		limitPathsToSemaphores[pathString] = semaphore
		limitPathsToSemaphoresLock.unlock()
		return semaphore
	}
	
	/// `limit` defines a subchain with special runtime protections. The links within the `limit` subchain are guaranteed to have at most `maxParallel` parallel executions. `limit` is particularly useful in the context of a fully parallel process when part of the process must access a limited resource pool such as CPU execution contexts or network resources.
	/// This method returns a `Link` whose execution result `J` is the result of the final link of the subchain. This permits the chain to proceed naturally after limit. For example:
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
	/// - Returns: a `Link` whose execution result `J` is the result of the final link of the subchain.
	@discardableResult
    public func limit<J, OtherE: Error, OtherP: AsyncBlockPerformer>(_ maxParallel: Int, _ defineBlock: (Link<B, E, P>) -> Link<J, OtherE, OtherP>) -> Link<J, OtherE, OtherP> {
		let semaphore = Link.semaphore(for: self, withValue: maxParallel)
		
		let openingLink = self.chain { (b:B) -> B in
			semaphore.wait()
			return b
		}
		var semaphoreReleasedNormally = false
		let _ = openingLink.finally{ link in
			link.chain { (_:B) -> Void in
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
	
	/// `limit` defines a subchain with special runtime protections. The links within the `limit` subchain are guaranteed to have at most `maxParallel` parallel executions. `limit` is particularly useful in the context of a fully parallel process when part of the process must access a limited resource pool such as CPU execution contexts or network resources.
	///
	/// - Parameters:
	///   - maxParallel:  the maximum number of parallel executions permitted for the subchains defined by `defineBlock`
	///   - defineBlock: a block which creates a subchain to be limited.
	public func limit(_ maxParallel: Int, _ defineBlock: (Link<B, E, P>) -> Void) -> Void {
		let semaphore = Link.semaphore(for: self, withValue: maxParallel)
		
		let openingLink = self.chain { (b:B) -> B in
			semaphore.wait()
			return b
		}
		let _ = openingLink.finally{ link in
			link.chain { (_:B) -> Void in
				semaphore.signal()
			}
		}
		
		defineBlock(openingLink)
	}
}

extension Link {
	private enum RetryError : Error {
		case generalError
	}
	/// `retry` defines a subchain with special runtime properties. The defined subchain will execute a maximum of `maxTimes + 1` times in an attempt to reach a non-error result.
	/// If each of the `maxTimes + 1` attempts result in error, the error from the last-attempted pass will be send to the registered error handler.
	/// If any of the attempts succeeds, the result `R` will be forwarded to the link which is returned from this function. For example:
	///
	///      .retry(2) { link in
	///         link.chain(transientlyFailingIntGenerator)
	///		}
	///     .chain(multiplyInt)
	///
	/// In the example above `transientlyFailingIntGenerator` is a function which can fail in non-fatal ways.
	/// When it succeeds, the result is an `Int` and that int is passed to `multiplyInt` after the `retry`.
	///
	/// - Parameters:
	///   - maxTimes: the maximum number of times to reattempt the subchain. Thus the subchain is executed at most `maxTimes + 1`
	///   - defineBlock: a block which creates a subchain to be retried.
	/// - Returns: a `Link` whose execution result `R` is the result of the final link of the subchain.
	@discardableResult
	public func retry<R>(_ maxTimes: Int, _ defineBlock: @escaping (Link<B, E, P>) -> Link<R, E, P>) -> Link<R, Error, P> {
		precondition(maxTimes > 0, "retry requiers maxTimes > 0")
		
		let retryTimes:AtomicInt = 0
		
		var result: R? = nil
		
		return self.chain { [weak self] (_: B, completion: @escaping (Result<R, Error>)->Void) -> Void in
		
			func invokeDefineBlock() {
				if let this = self {
					
						let recorededError = AtomicValue<Error?>(value: nil)
						let passThroughLink = this.chain { return $0 }
					
						let _ = passThroughLink.finally { link in
							link.chain { (_:B) -> Void in
								retryTimes.access { times in
									if let result = result {
										completion(.success(result))
									} else {
										if times < maxTimes {
											invokeDefineBlock()
											times += 1
										} else {
											if let recorededError = recorededError.get() {
												completion(.failure(recorededError))
											} else {
												// otherwise the recipie set a custom error handler inside the retry... which is fine.
												completion(.failure(RetryError.generalError))
											}
										}
									}
								}
							}
						}
					
                        defineBlock(passThroughLink).chain { (r: R, callback: @escaping (Result<Void,Never>)->Void) in
							result = r
                            callback(.success(Void()))
                        }.onError(recorededError.set(value:))
				} else {
					let message = "Lost self reference in retry"
					HoneyBee.internalFailureResponse.evaluate(false, message)
					return
				}
			}
			
			invokeDefineBlock()
		}
	}
}

extension Link {
	internal func getBlockPerformer() -> P {
		return self.blockPerformer
	}
}
