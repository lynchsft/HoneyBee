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

    lazy private(set) var ingest = async2(self.ingest)
    func ingest(data: Data, time: Date, completion: @escaping (Error?) -> Void ) {
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

class CodeCoverageTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRemoteObjectExample() {
        let completion = self.expectation(description: "Chain should complete")
        
        let hb = HoneyBee.start()

        let remote = RemoteObject() >> hb
        
        let data = remote.fetchData("fooId3")
        let time = remote.synchronize()
        
        let injested = remote.ingest(data)(time)

        let finished = (ingested +> remote).deleteSelf()

        finished.onError(fail)

        completion.fulfill(finished)
        
        self.waitForExpectations(timeout: 3)
    }

    func testRemoteObjectExample2() {
        let completion = self.expectation(description: "Chain should complete")

        let hb = HoneyBee.start()

        let r = RemoteObject()
        let remote = r >> hb

        let data = remote.syncFetchData("fooId3")
                    <+ remote.syncFetchData("fooId3" >> hb)
                    <+ r.syncFetchData(hb)("fooId3")
                    <+ r.syncFetchData(hb)("fooId3" >> hb)
                    <+ r.syncFetchData("fooId3")(hb)

        let time = remote.synchronize()
                    <+ r.synchronize(hb)

        let injested = remote.syncInjest(data)(time)
                        <+ r.syncInjest(hb)(data)(time)
                        <+ r.syncInjest(hb)(Data())(Date())
                        <+ r.syncInjest(data)(time)
                        <+ r.syncInjest(Data())(Date())(hb)
                        <+ remote.syncInjest(Data())(time)

        let finished = (ingested +> remote).deleteSelf()

        completion.fulfill(finished)
        finished.onError(fail)

        self.waitForExpectations(timeout: 3)
    }

    func testRemoteObjectExample3() {
        let completion = self.expectation(description: "Chain should complete")

        let hb = HoneyBee.start()
        let utility = hb >> UtilityDispatchQueue()

        let r1 = RemoteObject()
        let remote1 = r1 >> hb
        let remote2 = RemoteObject() >> hb

        let united = RemoteObject.unite(remote1)(remote2)("example")
                     <+ RemoteObject.unite(hb)(remote1)(remote2)("example")
                     <+ RemoteObject.unite(r1)(remote2)("example")


        let actioned = (united >> utility).complexAction(3)("bar")(false)
                       <+ (united >> utility).complexAction(3 >> utility)("bar")(false)

        let actionedRemote1 = actioned >> hb +> remote1 

        let finished = RemoteObject.devide("example")(actionedRemote1)(remote2)
                    <+ RemoteObject.devide(hb)("example")(actionedRemote1)(remote2)
                    <+ RemoteObject.devide("example" >> hb)(actionedRemote1)(remote2)

        completion.fulfill(finished)
        finished.onError(fail)

        self.waitForExpectations(timeout: 3)
    }

}
