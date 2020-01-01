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
    
    lazy private(set) var syncInjest = async2(self.syncInjest).on(DefaultDispatchQueue.self)
    func syncInjest(data: Data, time: Date) -> Void {
        
    }

    lazy private(set) var injest = async2(self.injest)
    func injest(data: Data, time: Date, completion: @escaping (Error?) -> Void ) {
        completion(nil)
    }
    
    lazy private(set) var syncFetchData = async1(self.syncFetchData).on(DefaultDispatchQueue.self)
    func syncFetchData(ref: String) throws -> Data {
        return Data()
    }
    
    lazy private(set) var fetchData = async1(self.fetchData) as SingleArgFunction<String, Data>
    func fetchData(ref: String, completion: @escaping (Data?, Error?) -> Void ) {
        completion(Data(), nil)
    }
    
    lazy private(set) var deleteSelf = async0(self.deleteSelf)
    func deleteSelf(completion: @escaping (Error?) -> Void ) {
        completion(nil)
    }

    lazy private(set) var synchronize = async0(self.sync).on(DefaultDispatchQueue.self)
    func sync() -> Date {
        Date()
    }

    static var unite: TripleArgFunction<RemoteObject, RemoteObject, String, RemoteObject> { async3(unite) }
    class func unite(a: RemoteObject, with b: RemoteObject, bindingName: String, completion: @escaping (Result<RemoteObject, Error>) -> Void) {
        completion(.success(b))
    }

    lazy private(set) var complexAction = async3(self.complexAction).on(UtilityDispatchQueue.self)
    func complexAction(int: Int, string: String, bool: Bool) {

    }

    static var devide: BoundTripleArgFunction<String, RemoteObject, RemoteObject, Void, DefaultDispatchQueue> {
        async3(devide).on(DefaultDispatchQueue.self)
    }
    class func devide(bindingNamed string: String, containing a: RemoteObject, and b: RemoteObject, completion: @escaping (Error?)-> Void) {
        completion(nil)
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
        
        let hb = HoneyBee.start().handlingErrors(with: fail)

        let remote = RemoteObject() >> hb
        
        let data = remote.fetchData(ref: "fooId3")
        let time = remote.synchronize()
        
        let injested = remote.injest(data: data)(time: time)

        let finished = (injested +> remote).deleteSelf()
        
        completion.fulfill(finished)
        
        self.waitForExpectations(timeout: 3)
    }

    func testRemoteObjectExample2() {
        let completion = self.expectation(description: "Chain should complete")

        let hb = HoneyBee.start().handlingErrors(with: fail)

        let r = RemoteObject()
        let remote = r >> hb

        let data = remote.syncFetchData(ref: "fooId3")
                    <+ remote.syncFetchData(ref: "fooId3" >> hb)
                    <+ r.syncFetchData(hb)(ref: "fooId3")
                    <+ r.syncFetchData(hb)(ref: "fooId3" >> hb)
                    <+ r.syncFetchData(ref: "fooId3")(hb)

        let time = remote.synchronize()
                    <+ r.synchronize(hb)

        let injested = remote.syncInjest(data: data)(time: time)
                        <+ r.syncInjest(hb)(data: data)(time: time)
                        <+ r.syncInjest(hb)(data: Data())(time: Date())
                        <+ r.syncInjest(data: data)(time: time)
                        <+ r.syncInjest(data: Data())(time: Date())(hb)
                        <+ remote.syncInjest(data: Data())(time: time)

        let finished = (injested +> remote).deleteSelf()

        completion.fulfill(finished)

        self.waitForExpectations(timeout: 3)
    }

    func testRemoteObjectExample3() {
        let completion = self.expectation(description: "Chain should complete")

        let hb = HoneyBee.start().handlingErrors(with: fail)
        let utility = hb >> UtilityDispatchQueue()

        let r1 = RemoteObject()
        let remote1 = r1 >> hb
        let remote2 = RemoteObject() >> hb

        let united = RemoteObject.unite(a: remote1)(b: remote2)(name: "example")
                     <+ RemoteObject.unite(hb)(a: remote1)(b: remote2)(name: "example")
                     <+ RemoteObject.unite(a: r1)(b: remote2)(name: "example")


        let actioned = (united >> utility).complexAction(3)("bar")(false)
                       <+ (united >> utility).complexAction(3 >> utility)("bar")(false)

        let actionedRemote1 = actioned >> hb +> remote1 

        let finished = RemoteObject.devide(name: "example")(a: actionedRemote1)(b: remote2)
                    <+ RemoteObject.devide(hb)(name: "example")(a: actionedRemote1)(b: remote2)
                    <+ RemoteObject.devide(name: "example" >> hb)(a: actionedRemote1)(b: remote2)

        completion.fulfill(finished)

        self.waitForExpectations(timeout: 3)
    }

}
