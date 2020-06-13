//
//  Executable.swift
//  HoneyBee
//
//  Created by Alex Lynch on 10/24/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

/// Super type of executable types.
public class Executable<E: Error> {
	func execute(argument: Any, completion: @escaping () -> Void) -> Void {}
    func ancestorFailed(_ context: ErrorContext<E>) {}
	
	var debugInstance = false
}
