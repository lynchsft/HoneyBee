//
//  AsyncBlockPerformer.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/20/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

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

#if canImport(CoreData)
import CoreData
extension NSManagedObjectContext : AsyncBlockPerformer {
	/// Perform supplied block asynchronously
	///
	/// - Parameter block: block to perform asynchronously
	public func asyncPerform(_ block: @escaping () -> Void) {
		self.perform(block)
	}
}
#endif

/// An uninhabited type conforming to `AsyncBlockPerformer` which dispatches to `DispatchQueue.main`
public struct MainDispatchQueue: AsyncBlockPerformer {
    /// Creates a new instance
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.main.async(execute: block)
	}
}

/// An uninhabited type conforming to `AsyncBlockPerformer` which dispatches to `DispatchQueue.global()`
public struct DefaultDispatchQueue: AsyncBlockPerformer {
    /// Creates a new instance
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global().async(execute: block)
	}
}

/// An uninhabited type conforming to `AsyncBlockPerformer` which dispatches to `DispatchQueue.global(qos: .background)`
public struct BackgroundDispatchQueue: AsyncBlockPerformer {
    /// Creates a new instance
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .background).async(execute: block)
	}
}

/// An uninhabited type conforming to `AsyncBlockPerformer` which dispatches to `DispatchQueue.global(qos: .utility)`
public struct UtilityDispatchQueue: AsyncBlockPerformer {
    /// Creates a new instance
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .utility).async(execute: block)
	}
}

/// An uninhabited type conforming to `AsyncBlockPerformer` which dispatches to `DispatchQueue.global(qos: .userInitiated)`
public struct UserInitiatedDispatchQueue: AsyncBlockPerformer {
    /// Creates a new instance
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .userInitiated).async(execute: block)
	}
}

/// An uninhabited type conforming to `AsyncBlockPerformer` which dispatches to `DispatchQueue.global(qos: .userInteractive)`
public struct UserInteractiveDispatchQueue: AsyncBlockPerformer {
    /// Creates a new instance
	public init(){}
	public func asyncPerform(_ block: @escaping () -> Void) {
		DispatchQueue.global(qos: .userInteractive).async(execute: block)
	}
}
