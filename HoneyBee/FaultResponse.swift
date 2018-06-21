//
//  FaultResponse.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/1/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// Enum describing possible reponses to a failed invariant.
///
/// - suppress: No action is taken.
/// - warn: Print a warning message to the console
/// - assert: Invoke `assertionFailure` with failure message
/// - fail: Invoke `preconditonFailure` with failure message
/// - custom: Invoke a custom handler with the falure message
public enum FaultResponse {
	/// No action is taken.
	case suppress
	/// Print a warning message to the console
	case warn
	/// Invoke `assertionFailure` with failure message
	case assert
	/// Invoke `preconditonFailure` with failure message
	case fail
	/// Invoke a custom handler with the falure message
	case custom(handler: (String)->Void)
	
	public func evaluate(_ flag: Bool, _ message: @autoclosure ()->String) {
		if flag == false {
			switch self {
			case .suppress :
				break
			case .warn:
				let realizedMessage = message()
				print("HoneyBee Warning: \(realizedMessage)")
			case .assert:
				let realizedMessage = message()
				assertionFailure(realizedMessage)
			case .fail:
				let realizedMessage = message()
				preconditionFailure(realizedMessage)
			case .custom(let handler):
				let realizedMessage = message()
				handler(realizedMessage)
			}
		}
	}
}
