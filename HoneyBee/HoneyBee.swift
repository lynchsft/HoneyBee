//
//  HoneyBee.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

public struct HoneyBee {
	public static func start(on queue: DispatchQueue = DispatchQueue.global(), file: StaticString = #file, line: UInt = #line, _ defineBlock: @escaping (ProcessLink<Void, Void>) -> Void) {
		let root = ProcessLink<Void, Void>(function: {a, block in block(a)}, queue: queue, path: ["start: \(file):\(line)"])
		queue.async {
			defineBlock(root)
			root.execute(argument: Void(), completion: {success in })
		}
	}
}
