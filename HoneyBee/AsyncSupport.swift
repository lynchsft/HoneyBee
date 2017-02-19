//
//  AsyncSupport.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/5/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

extension Collection where IndexDistance == Int {
	
	/*** \c completion is called from \c queue */
	func asyncMap<B>(on queue: DispatchQueue = DispatchQueue.global(qos: .background), transform: @escaping (Iterator.Element) -> B, completion: @escaping ([B]) -> Void) {
		self.asyncMap(on: queue, transform: { (element, callback) in
			callback(transform(element))
		}, completion: completion)
	}
	
	/*** \c completion is called from \c queue */
	func asyncMap<B>(on queue: DispatchQueue = DispatchQueue.global(qos: .background), transform: @escaping (Iterator.Element, (B) -> Void) -> Void, completion: @escaping ([B]) -> Void) {
		let integrationSerialQueue = DispatchQueue(label: "asyncMapSerialQueue")
		let group = DispatchGroup()
		var results:[B?] = Array(repeating: .none, count: self.count)
		
		for (index, element) in self.enumerated() {
			let workItem = DispatchWorkItem(block: {
				transform(element) { result in
					integrationSerialQueue.async {
						results[index] = result
						group.leave()
					}
				}
			})
			group.enter()
			queue.async(group: group, execute: workItem)
		}
		
		group.notify(queue: queue, execute: {
			completion(results.map {
				guard let b = $0 else {
					preconditionFailure("asyncMap failed to fully populate the result set")
				}
				return b
			})
		})
	}
}

extension Sequence {
	
	/*** \c completion is called from \c queue */
	func asyncFilter(on queue: DispatchQueue = DispatchQueue.global(qos: .background), transform: @escaping (Iterator.Element) -> Bool, completion: @escaping ([Iterator.Element]) -> Void  ) {
		return self.asyncFilter(on:queue, transform: { (element, callback) in
			callback(transform(element))
		}, completion: completion)
	}
	
	/*** \c completion is called from \c queue */
	func asyncFilter(on queue: DispatchQueue = DispatchQueue.global(qos: .background), transform: @escaping (Iterator.Element, (Bool) -> Void) -> Void, completion: @escaping ([Iterator.Element]) -> Void  ) {
		
		let serialQueue = DispatchQueue(label: "asyncFilterSerialQueue")
		let group = DispatchGroup()
		var results:[Iterator.Element] = []
		
		for element in self {
			let workItem = DispatchWorkItem(block: {
				transform(element) { include in
					serialQueue.async {
						if include {
							results.append(element)
						}
						group.leave()
					}
				}
			})
			group.enter()
			concurrentQueue.async(group: group, execute: workItem)
		}
		
		group.notify(queue: concurrentQueue, execute: {
			completion(results)
		})
	}
}

extension NSArray {
	@objc func asyncMap(transform: @escaping (NSObject)-> NSObject, completion: @escaping (NSArray) -> Void ) {
		self.asyncMap(transformBlock: { (element, callback) in
			callback(transform(element))
		}, completion: completion)
	}
	
	@objc func asyncMap(transformBlock: @escaping (NSObject, (NSObject) -> Void)-> Void, completion: @escaping (NSArray) -> Void ) {
		guard let array = self as? Array<NSObject> else {
			preconditionFailure("Using this API with an NSArray which contains other than NSObject subclasses is not allowed. Use the generic swift API instead.")
		}
		array.asyncMap(transform: transformBlock, completion: { (results) in
			completion(results as NSArray)
		})
	}
}
