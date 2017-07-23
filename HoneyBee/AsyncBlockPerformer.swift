//
//  AsyncBlockPerformer.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/20/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation
import CoreData

/// Protocol describing an entity which is able to perform Void->Void blocks asynchronously.
public protocol AsyncBlockPerformer {
	/// Perform supplied block asynchronously
	///
	/// - Parameter block: block to perform asynchronously
	func asyncPerform(_ block: @escaping () -> Void)
}


extension DispatchQueue : AsyncBlockPerformer {
	/// Perform supplied block asynchronously
	///
	/// - Parameter block: block to perform asynchronously
	public func asyncPerform(_ block: @escaping () -> Void) {
		self.async(execute: block)
	}
}

extension NSManagedObjectContext : AsyncBlockPerformer {
	/// Perform supplied block asynchronously
	///
	/// - Parameter block: block to perform asynchronously
	public func asyncPerform(_ block: @escaping () -> Void) {
		self.perform(block)
	}
}
