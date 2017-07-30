//
//  ChainableFailable.swift
//  HoneyBee
//
//  Created by Alex Lynch on 7/29/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

protocol ChainableFailable : Chainable {
	///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
	@discardableResult func chain<C,Failable>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (Failable) -> Void) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C
	
	///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
	@discardableResult func chain<C,Failable>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((Failable) -> Void)?) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C
	
	///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
	@discardableResult func chain<C,Failable>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (Failable) -> Void) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C
	
	///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
	@discardableResult func chain<C,Failable>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((Failable) -> Void)?) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C
	
	///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink
	@discardableResult func chain<C,Failable>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping ((Failable) -> Void) -> Void) -> ProcessLink<C> where Failable : FailableResultProtocol, Failable.Wrapped == C
}
