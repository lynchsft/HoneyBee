//
//  FailableResult.swift
//  HoneyBee
//
//  Created by Alex Lynch on 1/16/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

public enum FailableResult<T> {
	case success(T)
	case failure(Swift.Error)
}
