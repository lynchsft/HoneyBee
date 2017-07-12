//
//  ErrorHandling.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/5/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation


public protocol ErrorHandling {
	associatedtype A
	associatedtype B
	
	func setErrorHandler(_ errorHandler: @escaping (Error, Any) -> Void ) -> ProcessLink<A, B>
}
