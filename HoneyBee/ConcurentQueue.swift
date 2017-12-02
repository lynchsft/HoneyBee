//
//  ConcurentQueu.swift
//  HoneyBee
//
//  Created by Alex Lynch on 11/12/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

struct ConcurrentQueue<T> {
	struct State<T> {
		fileprivate var array = Array<T>()
		fileprivate var drain: ((T) -> Void)?
	}
	
	private var lockedState = AtomicValue(value: State<T>())
	
	var count: Int {
		return lockedState.access { state in
			state.array.count
		}
	}
	
	func push(_ value: T) {
		lockedState.access { state in
			if let drain = state.drain {
				drain(value)
			} else {
				state.array.append(value)
			}
		}
	}
	
	func drain(_ receiver: @escaping (T) -> Void) {
		lockedState.access { state in
			precondition(state.drain == nil, "Can only call drain once.")
			state.drain = receiver
			while state.array.count > 0 {
				receiver(state.array.removeFirst())
			}
		}
	}
}
