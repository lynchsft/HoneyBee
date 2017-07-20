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
	
	/// `start()` defines and executes a HoneyBee process. For example:
	///
	///     HoneyBee.start { root in
	///         root.errorHandler(funcE)
	///             .chain(funcA)
	///             .chain(funcB)
	///     }
	///
	/// The above example declares a HoneyBee process with error handling provided by `funcE` and a serial execution of `funcA` then `funcB`.
	/// For more possible HoneyBee declaration patterns see `ProcessLink`
	///
	/// - Parameters:
	///   - queue: The execution queue to begin the process in.
	///   - file: used for debugging
	///   - line: used for debugging
	///   - defineBlock: the define block is where you declare your process chain. The value passed into `defineBlock` is a `RootLink`.
	public static func start(on blockPerformer: AsyncBlockPerformer = DispatchQueue.global(), file: StaticString = #file, line: UInt = #line, _ defineBlock: @escaping (RootLink<Void>) -> Void) {
		let root = RootLink<Void>(blockPerformer: blockPerformer, path: ["start: \(file):\(line)"])
		blockPerformer.asyncPerform {
			defineBlock(root)
			root.execute(argument: Void(), completion: {success in })
		}
	}
}
