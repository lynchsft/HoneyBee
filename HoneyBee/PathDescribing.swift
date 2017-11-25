//
//  PathDescribing.swift
//  HoneyBee
//
//  Created by Alex Lynch on 5/1/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation


/// A protocol that to support documenting complex string paths.
protocol PathDescribing : CustomDebugStringConvertible {
	/// the path to the implementor must be non-zero in length
	/// that is, if the implementor is a root node, there should be one element in the path array
	var path: [String] {get}
}

extension PathDescribing  {
	/// joins the path components with \\n
	public var debugDescription: String {
		return self.path.joined(separator: "\n")
	}
}
