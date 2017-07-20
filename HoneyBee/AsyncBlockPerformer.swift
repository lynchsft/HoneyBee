//
//  AsyncBlockPerformer.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/20/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation
import CoreData

public protocol AsyncBlockPerformer {
	func asyncPerform(_ block: @escaping () -> Void)
}

extension DispatchQueue : AsyncBlockPerformer {
	public func asyncPerform(_ block: @escaping () -> Void) {
		self.async(execute: block)
	}
}

extension NSManagedObjectContext : AsyncBlockPerformer {
	public func asyncPerform(_ block: @escaping () -> Void) {
		self.perform(block)
	}
}
