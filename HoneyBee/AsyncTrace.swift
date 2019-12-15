//
//  AsyncTrace.swift
//  HoneyBee
//
//  Created by Alex Lynch on 5/14/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

public struct AsyncTrace: CustomDebugStringConvertible {
	var trace = Array<AsyncTraceComponent>()
    
    init(first comp: AsyncTraceComponent) {
        self.append(comp)
    }
	
	mutating func append(_ comp: AsyncTraceComponent) {
		self.trace.append(comp)
	}
	
	public func toString() -> String {
		var out = ""
		for comp in self.trace {
			out.append(comp.description)
			out.append("\n")
		}
		return out
	}
	
	func join(_ other: AsyncTrace) -> AsyncTrace {
        var newTrace = AsyncTrace(first: self.last) // will be overwritten
		var matchingBeginingsCount = 0
		for (index, myComp) in self.trace.enumerated() {
			guard other.trace.count > index else {
				break
			}
			if myComp == other.trace[index] {
				matchingBeginingsCount = index+1
			} else {
				break
			}
		}
		newTrace.trace = self.trace + [.join] + other.trace[matchingBeginingsCount...]
		return newTrace
	}
	
	var last: AsyncTraceComponent {
        get {
            self.trace.last!
        }
        set {
            self.trace.removeLast()
            self.trace.append(newValue)
        }
	}
    
    public var lastFile: StaticString {
        self.last.file
    }
    
    public var lastLine: UInt {
        self.last.line
    }
	
	public var debugDescription: String {
		return self.toString()
	}
    
    mutating func redocumentLast(action: String, file: StaticString, line: UInt) {
        self.last.redocument(action: action, file: file, line: line)
    }
}

// REFERENCE SEMANTICS are imporant for this type
public class AsyncTraceComponent: CustomStringConvertible, CustomDebugStringConvertible, Equatable {
	public static func == (lhs: AsyncTraceComponent, rhs: AsyncTraceComponent) -> Bool {
		return lhs.action == rhs.action &&
		String(describing: lhs.file) == String(describing: rhs.file) &&
		lhs.line == rhs.line
	}
	
    var action: String
    var file: StaticString
	var line: UInt
    
    init(action: String, file: StaticString, line: UInt) {
        self.action = action
        self.file = file
        self.line = line
    }
	
	fileprivate static let join = AsyncTraceComponent(action: "", file: "", line: UInt.max)
	
    func redocument(action: String, file: StaticString, line: UInt) {
        self.action = action
        self.file = file
        self.line = line
    }
    
	public var description: String {
		if line == AsyncTraceComponent.join.line {
			return "+"
		} else {
			let url = URL(fileURLWithPath: String(describing: self.file))
			let components = url.pathComponents
			let count = components.count
			let rejoined = URL(fileURLWithPath: components[count-2])
							.appendingPathComponent(components[count-1])
							.relativePath
			return "\(rejoined):\(self.line) \(self.action)"
		}
	}
	
	public var debugDescription: String {
		return self.description
	}
}