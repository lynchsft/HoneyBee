//
//  AsyncCurryTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 4/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import XCTest
import Foundation
import HoneyBee

class AsyncCurryTests: XCTestCase {
	
	private var filename: String {
		return  URL(fileURLWithPath: #file).lastPathComponent
	}
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testErrorContext() {
		let explode = expectation(description: "Chain should explode")
        let successfulResult = expectation(description: "Successful result")
        let unsuccessfulResult = expectation(description: "Unsuccessful result")
		
		func handleError(_ context: ErrorContext<NSError>) {
//			print(context.trace.toString())
            XCTAssertEqual(context.trace.componentCount, 6)
			explode.fulfill()
		}
		
		let hb = HoneyBee.start() // 1
        
        let r1 = increment(3 >> hb) // 2
        let r2 = increment(r1) // 3
        let r3 = increment(r2) // 4
        let r4 = increment(r3) // 5

        XCTAssertEqual(r4, 7 >> hb)

        r4.onResult { (result: Result<Int, Never>) in
            switch result {
            case .success(_):
                successfulResult.fulfill()
            case .failure(_):
                XCTFail()
            }
        }

        let testingFunctions = TestingFunctions() >> r4.drop
        let error = testingFunctions.explode() // 6
        error.onResult { (result: Result<Int, ErrorContext<NSError>>) in
            switch result {
            case .success(_):
                XCTFail()
            case let .failure(context):
                unsuccessfulResult.fulfill()
                handleError(context)
            }
        }
		
		waitForExpectations(timeout: 3)
	}
	
	func testErrorContext2() {
		let source = [1, 2, 3, 4, 5]
		let errorCount = source.count + 1
		let expect = expectation(description: "Chain should expload \(errorCount) times.")
		expect.expectedFulfillmentCount = errorCount
		
		let finalExpect = expectation(description: "Chain should finalize")
		
		func shortError(_ context: ErrorContext<NSError>) { // this one handles the error thrown by reduce(map) itself
//			print(context.trace.toString())
            XCTAssertEqual(context.trace.componentCount, 4)
			expect.fulfill()
		}
		
		func longError(_ context: ErrorContext<NSError>) { // this one handles the errors thrown by `explode`.
//			print(context.trace.toString())
            XCTAssertEqual(context.trace.componentCount, 7)
			expect.fulfill()
		}
		
		do {
			let hb = HoneyBee.start().finally { // 1
				finalExpect.fulfill($0)
			}

            let source = source >> hb // not documented
			
            let sum = source.map { // 2
                    increment($0)
                }
                .expect(NSError.self) // 3
                .reduce(with: 0) { // 4
                    let value = $0.chain(+) // 5
                    let plus1 = increment(value) // 6
                    let testingFuncs = TestingFunctions() >> plus1.drop
                    let error = testingFuncs.explode() +> plus1 // 7

                    error.onError(longError)
                    return error
				}
            sum.onError(shortError)
            sum.drop.chain(fail) // shouldn't run so no index
		}
		
		waitForExpectations(timeout: 6)
	}
	
	func testErrorContext3() {
		let expect = expectation(description: "Chainshould complete")
		
		func handleError(_ context: ErrorContext<NSError>) {
//			print(context.trace.toString())
            XCTAssertEqual(context.trace.componentCount, 6)
            XCTAssertFalse(context.trace.toString().contains("unknown"))
			expect.fulfill()
		}
		
		let hb = HoneyBee.start() // 1
		
		let source = [1, 2, 3]
		let sum = hb.insert(source) // 2
			.map { // 3
                increment($0)
			}.reduce(with: 0) { // 4
				$0.chain(+)
			}
		
        let plus1 = increment(sum) // 5
        XCTAssertEqual(plus1, 10 >> hb)
        let testingFuncs = TestingFunctions() >> plus1.drop
        testingFuncs.explode()  // 6
            .onError(handleError)
		
		waitForExpectations(timeout: 3)
	}
	
	func testErrorContext4() {
		let source = [1, 2, 3, 4, 5]
		let errorCount = source.count + 1
		let expect = expectation(description: "Chain should expload \(errorCount) times.")
		expect.expectedFulfillmentCount = errorCount
		
		let finalExpect = expectation(description: "Chain should finalize")
		
		func shortError(_ context: ErrorContext<NSError>) { // this one handles the error thrown by map itsself
//			print(context.trace.toString())
            XCTAssertEqual(context.trace.componentCount, 3)
			expect.fulfill()
		}
		
		func longError(_ context: ErrorContext<NSError>) { // this one handles the errors thrown by `explode`.
//			print(context.trace.toString())
            XCTAssertEqual(context.trace.componentCount, 5)
			expect.fulfill()
		}
		
		do {
			let hb = HoneyBee.start().finally { // 1
				finalExpect.fulfill($0)
			}

            let source = source >> hb
            let errorExpectingSource = source.expect(NSError.self) // 2
			let mapping = errorExpectingSource
                .map { (int: Link<Int, NSError, DefaultDispatchQueue>) -> Link<Int, NSError, DefaultDispatchQueue> in // 3
                    let bigger = increment(int) // 4

                    let testingFuncs = TestingFunctions() >> bigger.drop
                    let explode = testingFuncs.explode() +> bigger // 5
                    explode.onError(longError)
                    return explode
			}

            mapping.drop.chain(fail) // shouldn't run, so no index
            mapping.onError(shortError)
		}
		
		waitForExpectations(timeout: 3)
	}
}
