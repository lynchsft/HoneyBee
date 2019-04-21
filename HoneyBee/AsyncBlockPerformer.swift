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

public struct MainDispatchQueue: AsyncBlockPerformer {
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.main.async(execute: block)
	}
}

public struct DefaultDispatchQueue: AsyncBlockPerformer {
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global().async(execute: block)
	}
}

public struct BackgroundDispatchQueue: AsyncBlockPerformer {
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async(execute: block)
	}
}

public struct UtilityDispatchQueue: AsyncBlockPerformer {
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .utility).async(execute: block)
	}
}

public struct UserInitiatedDispatchQueue: AsyncBlockPerformer {
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .userInitiated).async(execute: block)
	}
}

public struct UserInteractiveDispatchQueue: AsyncBlockPerformer {
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .userInteractive).async(execute: block)
	}
}
