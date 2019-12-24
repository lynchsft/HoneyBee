//
//  UploadPipeline.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 12/23/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import XCTest
@testable import HoneyBee

class UploadPipeline: XCTestCase {

    private let exportLimit = 1
    private let uploadLimit = 4
    private let uploadCount = 2

    private let concurrentExportCounter: AtomicInt = 0
    private let concurrentUploadCounter: AtomicInt = 0

    private var managedObjectContext: UtilityDispatchQueue!
    private var totalExpectation: XCTestExpectation!
    private var singleUploadCompletionExpectation: XCTestExpectation!
    private var singleUploadSuccessExpectation: XCTestExpectation!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.managedObjectContext = UtilityDispatchQueue()
        // A faux ManagedObjectContext

        self.totalExpectation = self.expectation(description: "Final completion called")
        self.singleUploadCompletionExpectation = self.expectation(description: "Single upload completion called")
        self.singleUploadCompletionExpectation.expectedFulfillmentCount = self.uploadCount
        self.singleUploadSuccessExpectation = self.expectation(description: "Single upload success called")
        self.singleUploadSuccessExpectation.expectedFulfillmentCount = self.uploadCount
    }

    override func tearDown() {
        XCTAssertEqual(self.concurrentExportCounter.get(), 0)
        self.concurrentExportCounter.set(value: 0)
        XCTAssertEqual(self.concurrentUploadCounter.get(), 0)
        self.concurrentUploadCounter.set(value: 0)
    }

    struct Media {
        let ref: String
    }

    /// An enum describing specific problems that the algorithm might encounter.
    enum UploadingError : Error {
      case invalidResponse
      case tooManyFailures
    }


    private lazy var export = (async1(self.export) as SingleArgFunction<String, Media>).on(DefaultDispatchQueue.self)
    private func export(_ mediaRef: String, completion: @escaping (Media?, Error?) -> Void) {
        XCTAssert(concurrentExportCounter.increment() < exportLimit+1)
        DispatchQueue.global().async {
            // transcoding stuff
            self.concurrentExportCounter.decrement()
            completion(Media(ref: mediaRef), nil)
        }
    }


    private lazy var upload = (async1(self.upload) as SingleArgFunction<Media, Void>).on(UtilityDispatchQueue.self)
    private func upload(_ media: Media, completion: @escaping (Error?) -> Void) {
        XCTAssert(concurrentUploadCounter.increment() < uploadLimit+1)
        DispatchQueue.global().async {
            // network stuff
            self.concurrentUploadCounter.decrement()
            completion(nil)
        }
    }

    /// Called if anything goes wrong in the upload
    private func errorHandler(_ error: Error) {
        // do the right thing
        XCTAssert(Thread.isMainThread)
        XCTFail("Error encountered: \(error)")
    }


    private lazy var singleUploadCompletion = async1(self.singleUploadCompletion).on(MainDispatchQueue.self)
    /// Called once per mediaRef, after either a successful or unsuccessful upload
    private func singleUploadCompletion(_ mediaRef: String) {
        // update a progress indicator
        XCTAssert(Thread.isMainThread)
        self.singleUploadCompletionExpectation.fulfill()
    }


    private lazy var singleUploadSuccess = async1(self.singleUploadSuccess).on(MainDispatchQueue.self)
    /// Called once per successful upload
    private func singleUploadSuccess(_ media: Media) {
        // do celebratory things
        XCTAssert(Thread.isMainThread)
        self.singleUploadSuccessExpectation.fulfill()
    }

    
    private lazy var totalProcessSuccessA = async0(self.totalProcessSuccess).on(MainDispatchQueue.self)
    /// Called if the entire batch was considered to be uploaded successfully.
    private func totalProcessSuccess() {
        // declare victory
        XCTAssert(Thread.isMainThread)
        self.totalExpectation.fulfill()
    }

    func testHoneyBee2() {
        let mediaReferences = (1...uploadCount).map { "ref\($0)" }

        let a = HoneyBee.start(on: DispatchQueue.main)
                .handlingErrors(with: errorHandler)
                .insert(mediaReferences)

        let b = a.move(to: DispatchQueue.global())
                .each(limit: uploadLimit, acceptableFailure: .ratio(0.5)) { elem in
                    elem.finally { link in
                        link.move(to: DispatchQueue.main)
                            .chain(self.singleUploadCompletion)
                    }
                    .limit(self.exportLimit) { link in
                        link.chain(self.export)
                    }
                    .move(to: self.managedObjectContext)
                    .retry(1) { link in
                        link.chain(self.upload) // subject to transient failure
                    }
                    .move(to: DispatchQueue.main)
                    .chain(self.singleUploadSuccess)
                    .move(to: DispatchQueue.global())
                }.drop

                b.move(to: DispatchQueue.main)
                .chain(totalProcessSuccess)

        self.waitForExpectations(timeout: 15)
    }


    func testHoneyBee3() {
        let mediaReferences = (1...uploadCount).map { "ref\($0)" }

        let mainQ = HoneyBee.start(on: MainDispatchQueue())
                            .handlingErrors(with: errorHandler)

        let backgroundQ = mainQ >> DefaultDispatchQueue()

        let asyncReferences = mediaReferences >> backgroundQ

        let uploadComplete = asyncReferences.each(limit: uploadLimit, acceptableFailure: .ratio(0.5)) { reference -> Link<Void, MainDispatchQueue> in
            let completingRef = reference.finally { reference in
                self.singleUploadCompletion(reference >> mainQ)
            }

            let media = completingRef.limit(self.exportLimit) { reference in
                self.export(reference) >> self.managedObjectContext
                // the export is compute bound so limit it further
            }

            let uploaded = media.retry(1) { media in
                self.upload(media) +> media
                // the upload is subject to transient failure
            }

            return self.singleUploadSuccess(uploaded >> mainQ)
        }.drop

        self.totalProcessSuccessA(uploadComplete >> mainQ)

        self.waitForExpectations(timeout: 15)
    }
}
