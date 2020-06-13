//
//  HoneyBee.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// The `HoneyBee` struct is the starting point for all HoneyBee processes. See `start(on:)` for more details.
public struct HoneyBee {
	
	/// `start()` defines and executes a HoneyBee recipe. For example:
	///
	///     HoneyBee.start { root in
	///         root.handlingErrrors(with: funcE)
	///             .chain(funcA)
	///             .chain(funcB)
	///     }
	///
	/// The above example declares a HoneyBee recipe with error handling provided by `funcE` and a serial execution of `funcA` then `funcB`.
	/// For more possible HoneyBee declaration patterns see `Link`
	///
	/// - Parameters:
	///   - file: used for debugging
	///   - line: used for debugging
	///   - defineBlock: the define block is where you declare your process chain. The value passed into `defineBlock` is a `SafeLink`.
	public static func start(file: StaticString = #file, line: UInt = #line, _ defineBlock: @escaping (Link<Void, Never, DefaultDispatchQueue>) -> Void) {
		self.start(on: DefaultDispatchQueue(), file: file, line: line, defineBlock)
	}
	
	/// `start()` defines and executes a HoneyBee recipe. For example:
	///
	///     HoneyBee.start { root in
	///         root.handlingErrrors(with: funcE)
	///             .chain(funcA)
	///             .chain(funcB)
	///     }
	///
	/// The above example declares a HoneyBee recipe with error handling provided by `funcE` and a serial execution of `funcA` then `funcB`.
	/// For more possible HoneyBee declaration patterns see `Link`
	///
	/// - Parameters:
	///   - blockPerformer: The block performer to begin the process in.
	///   - file: used for debugging
	///   - line: used for debugging
	///   - defineBlock: the define block is where you declare your process chain. The value passed into `defineBlock` is a `SafeLink`.
	public static func start<P: AsyncBlockPerformer>(on blockPerformer: P, file: StaticString = #file, line: UInt = #line, _ defineBlock: @escaping (Link<Void, Never, P>) -> Void) {
		let safeLink = self.start(on: blockPerformer, file: file, line: line)
		
		blockPerformer.asyncPerform {
			defineBlock(safeLink)
		}
	}
	
	/// `start()` defines and executes a HoneyBee recipe. For example:
	///
	///     HoneyBee.start()
	///             .handlingErrrors(with: funcE)
	///             .chain(funcA)
	///             .chain(funcB)
	///
	/// The above example declares a HoneyBee recipe with error handling provided by `funcE` and a serial execution of `funcA` then `funcB`.
	/// For more possible HoneyBee declaration patterns see `Link`
	///
	/// - Parameters:
	///   - file: used for debugging
	///   - line: used for debugging
	/// - Returns: a `SafeLink` to being declaring your recipe.
	public static func start(file: StaticString = #file, line: UInt = #line) -> Link<Void, Never, DefaultDispatchQueue> {
		return self.start(on: DefaultDispatchQueue(), file: file, line: line)
	}
	
	/// `start()` defines and executes a HoneyBee recipe. For example:
	///
	///     HoneyBee.start()
	///             .handlingErrrors(with: funcE)
	///             .chain(funcA)
	///             .chain(funcB)
	///
	/// The above example declares a HoneyBee recipe with error handling provided by `funcE` and a serial execution of `funcA` then `funcB`.
	/// For more possible HoneyBee declaration patterns see `Link`
	///
	/// - Parameters:
	///   - blockPerformer: The block performer to begin the process in.
	///   - file: used for debugging
	///   - line: used for debugging
	/// - Returns: a `SafeLink` to being declaring your recipe.
	public static func start<P: AsyncBlockPerformer>(on blockPerformer: P, file: StaticString = #file, line: UInt = #line) -> Link<Void, Never, P> {
        let trace = AsyncTrace(first: .init(action: "start", file: file, line: line))
		
		let link = Link<Void, Never, P>(function: { (_, callback) in
			callback(.success(Void()))
		},
		   blockPerformer: blockPerformer,
		   trace: trace)
		
		blockPerformer.asyncPerform {
			link.execute(argument: Void(), completion: { })
		}

		return link
	}

	private static let functionUnderCallResponseLock = AtomicValue(value: FaultResponse.fail)
	private static let functionOvercallResponseLock = AtomicValue(value: FaultResponse.warn)
	private static let internalFailureResponseLock = AtomicValue(value: FaultResponse.fail)
	private static let mismatchedConjoinResponseLock = AtomicValue(value: FaultResponse.warn)
	
	/// A `FaultResponse` which will be invoked if a chained function does not invoke its callback. See `Link`.
	/// Defaults to .fail
	public static var functionUndercallResponse: FaultResponse {
		get { return self.functionUnderCallResponseLock.get() }
		set { self.functionUnderCallResponseLock.set(value: newValue) }
	}
	
	/// A `FaultResponse` which will be invoked if a chained function invokes its callback more than once. See `Link`.
	/// Defaults to .warn
	public static var functionOvercallResponse: FaultResponse {
		get { return self.functionOvercallResponseLock.get() }
		set { self.functionOvercallResponseLock.set(value: newValue) }
	}
	
	/// A `FaultResponse` which will be invoked if HoneyBee detects an internal failure.
	/// Defaults to .fail
	public static var internalFailureResponse: FaultResponse {
		get { return self.internalFailureResponseLock.get() }
		set { self.internalFailureResponseLock.set(value: newValue) }
	}
	
	/// A `FaultResponse` which will be invoked if HoneyBee detects a `conjoin` operation between two links with different `AsyncBlockPerformer`s.
	/// Defaults to .warn
	public static var mismatchedConjoinResponse: FaultResponse {
		get { return self.mismatchedConjoinResponseLock.get() }
		set { self.mismatchedConjoinResponseLock.set(value: newValue) }
	}
	
	/// Utility function to retreive the block performer of a given link.
	/// This method is useful to implementors of custom link behaviors.
	/// - Returns: the `AsyncBlockPerformer` of the given link.
    public static func getBlockPerformer<X, E: Error, P: AsyncBlockPerformer>(of link: Link<X, E, P>) -> P {
		return link.getBlockPerformer()
	}
	
}


extension HoneyBee {
	public static func async<R, P>(on blockPerformer: P,
										   callback: @escaping (R) -> Void,
										   file: StaticString = #file,
										   line: UInt = #line,
										   _ defineBlock: @escaping (Link<Void, Never, P>) -> Link<R, Never, P>) -> Void
    where P: AsyncBlockPerformer {
		
		self.start(on: blockPerformer, file: file, line: line) { context in
			let result = defineBlock(context)
            result.chain { elevate(callback =<< $0)($1) }
		}
	}
	
	public static func async<R, E, P>(on blockPerformer: P,
										   completion: @escaping (Result<R, E>) -> Void,
										   file: StaticString = #file,
										   line: UInt = #line,
										   _ defineBlock: @escaping (Link<Void, Never, P>) -> Link<R, E, P>) -> Void
    where E: Error, P: AsyncBlockPerformer {
		
		let context = self.start(on: blockPerformer, file: file, line: line)
        defineBlock(context).onResult(completion)
	}
	
//	public static func async<R, E, P>(on blockPerformer: P,
//										   completion: @escaping (Result<R, ErrorContext<E>>) -> Void,
//										   file: StaticString = #file,
//										   line: UInt = #line,
//										   _ defineBlock: @escaping (Link<Void, Never, P>) -> Link<R, E, P>) -> Void
//        where E: Error, P: AsyncBlockPerformer {
//			
//			let context = self.start(on: blockPerformer, file: file, line: line)
//            defineBlock(context).onResult(completion)
//	}
	
	public static func async<R>(callback: @escaping (R) -> Void,
								file: StaticString = #file,
								line: UInt = #line,
								_ defineBlock: @escaping (Link<Void, Never, DefaultDispatchQueue>) -> Link<R, Never, DefaultDispatchQueue>) -> Void {
		
		self.async(on: DefaultDispatchQueue(), callback: callback, file: file, line: line, defineBlock)
	}
	
	public static func async<R, E>(completion: @escaping (Result<R, E>) -> Void,
								file: StaticString = #file,
								line: UInt = #line,
								_ defineBlock: @escaping (Link<Void, Never, DefaultDispatchQueue>) -> Link<R, E, DefaultDispatchQueue>) -> Void
    where E: Error {
		
		self.async(on: DefaultDispatchQueue(), completion: completion, file: file, line: line, defineBlock)
	}
	
//	public static func async<R, E>(completion: @escaping (Result<R, ErrorContext<E>>) -> Void,
//								file: StaticString = #file,
//								line: UInt = #line,
//								_ defineBlock: @escaping (Link<Void, Never, DefaultDispatchQueue>) -> Link<R, E, DefaultDispatchQueue>) -> Void
//    where E: Error {
//			
//		self.async(on: DefaultDispatchQueue(), completion: completion, file: file, line: line, defineBlock)
//	}
}
