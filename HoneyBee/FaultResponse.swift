//
//  FaultResponse.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/1/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

enum FaultResponse {
	case suppress
	case warn
	case assert
	case fail
	
	func evaluate(_ flag: Bool, _ message: String) {
		if flag == false {
			switch self {
			case .suppress :
				break
			case .warn:
				print("HoneyBee Warning: \(message)")
			case .assert:
				assertionFailure(message)
			case .fail:
				preconditionFailure(message)
			}
		}
	}
}
