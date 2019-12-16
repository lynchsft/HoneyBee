//
//  CodeCoverageTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 12/16/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee

fileprivate class RemoteObject {
    
    lazy private(set) var syncInjest = async2(self.syncInjest)
    func syncInjest(data: Data, time: Date) -> Void {
        
    }

    lazy private(set) var injest = async2(self.injest)
    func injest(data: Data, time: Date, completion: @escaping (Error?) -> Void ) {
        completion(nil)
    }
    
    lazy private(set) var syncFetchSelf = async1(self.syncFetchSelf)
    func syncFetchSelf(ref: String) throws -> Data? {
        return nil
    }
    
    lazy private(set) var fetchSelf = async1(self.fetchSelf) as SingleArgFunction<String, Data>
    func fetchSelf(ref: String, completion: @escaping (Data?, Error?) -> Void ) {
        completion(Data(), nil)
    }
    
    lazy private(set) var deleteSelf = async0(self.deleteSelf)
    func deleteSelf(completion: @escaping (Error?) -> Void ) {
        
    }

    lazy private(set) var a_sync = async0(self.sync)
    func sync() -> Date {
        Date()
    }
}

extension XCTestExpectation {
    var fulfill: ZeroArgFunction<Void> { async0(self.fulfill) }
}

class CodeCoverageTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRemoteObjectExample() {
        let completion = self.expectation(description: "Chain should complete")
        
        let remote = HoneyBee.start().handlingErrors(with: fail).insert(RemoteObject())
        
        let data = remote.fetchSelf(ref: "foo")
        let time = remote.a_sync()
        
        let finished = remote.injest(data: data)(time: time)
        
        completion.fulfill(finished)
        
        self.waitForExpectations(timeout: 3)
    }

}
