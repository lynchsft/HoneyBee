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
	
	public func get() -> T {
		return self.access { $0 }
	}
	
	public func set(value: T) {
		self.access { $0 = value }
	}
}

class AtomicBool : AtomicValue<Bool>, ExpressibleByBooleanLiteral {
	
	private struct DeinitGuarantee {
		let faultResponse: FaultResponse
		let value: Bool
		let file: StaticString
		let line: UInt
		let message: String?
	}
	
	private var deinitGuarantee: DeinitGuarantee?
	
	
	required init(booleanLiteral: Bool) {
		super.init(value: booleanLiteral)
	}
	
	deinit {
		if let deinitGuarantee = self.deinitGuarantee {
			let actualValue = self.get()
			let locationString = "\(deinitGuarantee.file):\(deinitGuarantee.line)"
			let fullMessage = (deinitGuarantee.message ?? "<\(type(of: self)) \(Unmanaged.passUnretained(self).toOpaque())>: was \(actualValue) at deinit. Requested \(deinitGuarantee.value) at ")+locationString
			deinitGuarantee.faultResponse.evaluate(actualValue == deinitGuarantee.value, fullMessage)
			
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
	
	func guaranteeTrueAtDeinit(faultResponse: FaultResponse = .assert, file: StaticString = #file, line: UInt = #line, message: String? = nil) {
		self.deinitGuarantee = .init(faultResponse: faultResponse, value: true, file: file, line: line, message: message)
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
	
	@discardableResult
	func increment(by value: Int = 1) -> Int {
		return self.update(with: +, by: value)
	}
	
	@discardableResult
	func decrement(by value: Int = 1) -> Int {
		return self.update(with: -, by: value)
	}
	
	private func update(with updator: (Int, Int)->Int, by value: Int) -> Int {
		return self.access { i in
			i = updator(i,value)
			return i
		}
	}
	
	func notify(execute block: @escaping () -> Void) {
		if let existingNotifyBlock = self.notifyBlock {
			self.notifyBlock = {
				existingNotifyBlock()
				block()
			}
		} else {
			self.notifyBlock = block
		}
	}
	
	func guaranteeValueAtDeinit(_ int: Int) {
		self.valueAtDeinit = int
	}
}
