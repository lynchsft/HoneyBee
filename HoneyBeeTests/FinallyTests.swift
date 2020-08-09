//
//  FinallyTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 12/2/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee

class FinallyTests: XCTestCase {
    let funcContainer = TestingFunctions()
	
    override func setUp() {
		super.setUp()
		
		HoneyBee.functionOvercallResponse = .fail
		HoneyBee.functionUndercallResponse = .fail
		HoneyBee.internalFailureResponse = .fail
		HoneyBee.mismatchedConjoinResponse = .fail
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testFinallyOrdering() {
		var counter = 0 // do not make this Atomic. HoneyBee should perform the entire chane below serailly (though not liearlly of course).
		let incrementCounter = { counter += 1 }
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
				.finally { link in
					link.chain { XCTAssert(counter == 4, "counter should be 4: was actually \(counter)") }
						.chain(incrementCounter)
				}.finally { link in
					link.chain { XCTAssert(counter == 5, "counter should be 5: was actually \(counter)") }
						.chain(finishExpectation.fulfill)
				}
				.chain{ XCTAssert(counter == 0, "counter should be 0") }
				.finally { link in
					link.chain { XCTAssert(counter == 3, "counter should be 3: was actually \(counter)") }
						.chain(incrementCounter)
				}
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 1, "counter should be 1") }
				.finally { link in
					link.chain { XCTAssert(counter == 2, "counter should be 2: was actually \(counter)") }
						.chain(incrementCounter)
				}
				.chain(incrementCounter)
		
		waitForExpectations(timeout: 3)
	}
	
	func testFinallyContent() {
		
		let unreachableExpectation = expectation(description: "Should not reach the end of the chain")
		unreachableExpectation.isInverted = true
		let reachableExpectation = expectation(description: "Should reach this finally")
		let errorExpectation = expectation(description: "chain should error")

        do { // finally only runs when the receiver link is deallocated
            let hb = HoneyBee.start()

            let asynContainer = self.funcContainer >> hb

            let string = asynContainer.constantString()
                            .finally { link in
                                link.chain(assertEquals =<< "lamb")
                                    .chain(reachableExpectation.fulfill)
                            }
            let joinedContainer = string +> asynContainer
            let b = joinedContainer.explode()

            let c = b.finally { link in
                                link.drop
                                    .chain(unreachableExpectation.fulfill)
                            }

            c.onError { (_:Error) in errorExpectation.fulfill() }
        }
		
		waitForExpectations(timeout: 1)
	}
	
	func testFinallyError() {
		var counter = 0
		let incrementCounter = { counter += 1 }
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		func handleError(_ error: Error) {} // we cause an error on purpose
		
		HoneyBee.start()
				.finally { link in
					link.chain { () -> Void in XCTAssert(counter == 2, "counter should be 2") ; finishExpectation.fulfill() }
				}
				.chain{ XCTAssert(counter == 0, "counter should be 0") }
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 1, "counter should be 1") }
				.chain(incrementCounter)
				.chain({ throw NSError(domain: "An expected error", code: -1, userInfo: nil) })
				.chain(incrementCounter)
                .onError(handleError)

		
		waitForExpectations(timeout: 3)
	}
	
	func testFinallyWithRetry() {
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let finallyExpectation = expectation(description: "Should reach the finally")
		
		do { // finally only runs when the receiver link is deallocated
            let hb = HoneyBee.start(on: DispatchQueue.main)

            let a =	hb.finally { link in
                        link.chain(finallyExpectation.fulfill)
            }.expect(Error.self)

            let b = a.retry(1) { link in
                        self.funcContainer.constantInt(link)
                    }
                    .chain(self.funcContainer.multiplyInt).drop

            b.chain(finishExpectation.fulfill)
                    .onError(fail)
        }
		
		waitForExpectations(timeout: 2)
	}
}
