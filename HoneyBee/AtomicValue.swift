//
//  AtomicValue.swift
//  HoneyBee
//
//  Created by Alex Lynch on 11/12/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

class AtomicValue<T> {
	private let lock = NSLock()
	private var internalValue: T
	
	public init(value: T) {
		self.internalValue = value
	}
	
	@discardableResult
	public func access<Result>(_ block: (inout T) throws -> Result) rethrows -> Result {
		self.lock.lock()
		defer {
			self.lock.unlock()
		}
		return try block(&self.internalValue)
	}
}

class AtomicBool : AtomicValue<Bool>, ExpressibleByBooleanLiteral {
	
	private var deinitValue: Bool?
	
	required init(booleanLiteral: Bool) {
		super.init(value: booleanLiteral)
	}
	
	deinit {
		if let expectedValue = self.deinitValue {
			let actualValue = self.get()
			precondition(actualValue == expectedValue, "<\(type(of: self)) \(Unmanaged.passUnretained(self).toOpaque()): was \(actualValue) at deinit>")
		}
	}
	
	/// returns prior value
	@discardableResult
	func setTrue() -> Bool {
		return self.access { b in
			let oldB = b
			b = true
			return oldB
		}
	}
	
	/// returns prior value
	@discardableResult
	func setFalse() -> Bool {
		return self.access { b in
			let oldB = b
			b = false
			return oldB
		}
	}
	
	func get() -> Bool {
		return self.access { $0 }
	}
	
	func assertTrueAtDeinit() {
		self.deinitValue = true
	}
}

class AtomicInt : AtomicValue<Int>, ExpressibleByIntegerLiteral {
	
	private var notifyBlock: (() -> Void)?
	private var valueAtDeinit: Int?
	
	required init(integerLiteral: Int) {
		super.init(value: integerLiteral)
	}
	
	deinit {
		if let valueAtDeinit = self.valueAtDeinit {
			let value = self.get()
			precondition(value == valueAtDeinit, "<\(type(of: self)) \(Unmanaged.passUnretained(self).toOpaque()): was \(valueAtDeinit) at deinit>")
		}
		
		if let notify = self.notifyBlock {
			notify()
		}
	}
	
	@discardableResult func increment(by value: Int = 1) -> Int {
		return self.update(with: +, by: value)
	}
	
	@discardableResult func decrement(by value: Int = 1) -> Int {
		return self.update(with: -, by: value)
	}
	
	private func update(with updator: (Int, Int)->Int, by value: Int) -> Int {
		return self.access { i in
			i = updator(i,value)
			return i
		}
	}
	
	func notify(execute block: @escaping () -> Void) {
		precondition(self.notifyBlock == nil, "Can only call notify(at:) once")
		self.notifyBlock = block
	}
	
	func get() -> Int {
		return self.access { $0 }
	}
	
	func assertValueAtDeinit(_ int: Int) {
		self.valueAtDeinit = int
	}
}
