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
	///         root.setErrorHandler(funcE)
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
	///   - defineBlock: the define block is where you declare your process chain. The value passed into `defineBlock` is a `RootLink`.
	public static func start(on blockPerformer: AsyncBlockPerformer = DispatchQueue.global(), file: StaticString = #file, line: UInt = #line, _ defineBlock: @escaping (RootLink) -> Void) {
		let root = RootLink(blockPerformer: blockPerformer, path: ["start: \(file):\(line)"])
		blockPerformer.asyncPerform {
			defineBlock(root)
		}
	}
	
	/// `start()` defines and executes a HoneyBee recipe. For example:
	///
	///     HoneyBee.start()
	///             .setErrorHandler(funcE)
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
	/// - Returns: a `RootLink` to being declaring your recipe.
	public static func start(on blockPerformer: AsyncBlockPerformer = DispatchQueue.global(), file: StaticString = #file, line: UInt = #line) -> RootLink {
		return RootLink(blockPerformer: blockPerformer, path: ["start: \(file):\(line)"])
	}
	
	
	/// A `FaultResponse` which will be invoked if a chained function does not invoke its callback. See `Link`.
	/// Defaults to .fail
	public static var functionUndercallResponse = FaultResponse.fail
	/// A `FaultResponse` which will be invoked if a chained function invokes its callback more than once. See `Link`.
	/// Defaults to .warn
	public static var functionOvercallResponse = FaultResponse.warn
}
