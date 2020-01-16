//
//  ConcurrentBox.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/15/20.
//  Copyright © 2020 IAM Apps. All rights reserved.
//

import Foundation

class ConcurrentBox<T> {
    private let valueLock = NSLock()
    private var value: T?
    private var valueCallback: ((T) -> Void)?

    private lazy var hasSetValue: AtomicBool = false
    private lazy var hasSetBlock: AtomicBool = false

    func setValue(_ t: T) {
        HoneyBee.internalFailureResponse.evaluate(!self.hasSetValue.setTrue(), "Value set more than once")
        self.valueLock.lock()
        defer {
            self.valueLock.unlock()
        }

        self.value = t

        if let valueCallback = self.valueCallback {
            valueCallback(t)
        }
    }

    func yieldValue(_ block: @escaping (T) -> Void) {
        HoneyBee.internalFailureResponse.evaluate(!self.hasSetBlock.setTrue(), "Block set more than once")
       self.valueLock.lock()
        defer {
            self.valueLock.unlock()
        }
        // this needs to be atomic
        if let value = value {
            block(value)
        } else {
            self.valueCallback = block
        }
    }

}
