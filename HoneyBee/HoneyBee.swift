//
//  HoneyBee.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

public struct HoneyBee {
	public static func start(on queue: DispatchQueue = DispatchQueue.global(), _ defineBlock: @escaping (ProcessLink<Void, Void>) -> Void) {
		// access control
		guard let bundleID = Bundle.main.bundleIdentifier else {
			preconditionFailure("Bundle ID must be present")
		}
		
		guard let value = Bundle.main.infoDictionary?["HoneyBeeLicenseKey"] else {
			preconditionFailure("No HoneyBeeLicenseKey found in main bundle info plist")
		}
		
		var candidates:[String] = []
		
		if let string = value as? String {
			candidates.append(string)
		}
		if let array = value as? [String] {
			candidates.append(contentsOf: array)
		}
		
		let combined = bundleID.components(separatedBy: ".").joined()
		let altered = String(combined.characters.map({
			let s = String($0)
			return ["a","e","i","o","u"].contains(s) ? s.uppercased() : s
		}).joined().characters.reversed()).sha256()
		
		if candidates.first(where: { $0 == altered }) == nil {
			preconditionFailure("Invalid HoneyBeeLicenseKey")
		}
		
		// the real work
		let root = ProcessLink<Void, Void>(function: {a, block in block(a)}, queue: queue)
		queue.async {
			defineBlock(root)
			root.execute(argument: Void(), completion: {})
		}
	}
	
	@available(*, deprecated)
	public static func start<A>(with arg: A, on queue: DispatchQueue = DispatchQueue.global(), _ defineBlock: @escaping (ProcessLink<Void, A>) -> Void) {
		self.start(on: queue) { ctx in
			let link = ctx.chain { arg }
			defineBlock(link)
		}
	}
}
