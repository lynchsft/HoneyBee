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
    private let uploadCount = 20
    private let uploadRetries = 1
    private let acceptableFailureRate = 0.5

    private let concurrentExportCounter: AtomicInt = 0
    private let concurrentUploadCounter: AtomicInt = 0

    private var managedObjectContext: BackgroundDispatchQueue!
    private var totalExpectation: XCTestExpectation!
    private var singleUploadCompletionExpectation: XCTestExpectation!
    private var singleUploadSuccessExpectation: XCTestExpectation!

    var mediaReferences: Array<String> { (1...self.uploadCount).map { "ref\($0)" } }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.managedObjectContext = BackgroundDispatchQueue()
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


    private lazy var export = (async1(self.export) as SingleArgFunction<String, Media, Error>).on(UtilityDispatchQueue.self)
    private func export(_ mediaRef: String, completion: @escaping (Media?, Error?) -> Void) {
        XCTAssert(concurrentExportCounter.increment() < exportLimit+1)
        DispatchQueue.global().async {
            // transcoding stuff
            self.concurrentExportCounter.decrement()
            completion(Media(ref: mediaRef), nil)
        }
    }


    private lazy var upload = (async1(self.upload) as SingleArgFunction<Media, Void, Error>).on(BackgroundDispatchQueue.self)
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

    func testHoneyBee0() {

        /// A semaphore to prevent flooding the NIC
        let outerLimit = DispatchSemaphore(value: self.uploadLimit)
        /// A semaphore to prevent thrashing the processor
        let exportLimit = DispatchSemaphore(value: self.exportLimit)

        /// How many of the uploads fully completed.
        var uploadSuccesses = 0

        // start in the background
        DispatchQueue.global().async {
            /// Dispatch group to keep track of when the entire process is finished
            let fullProcessDispatchGroup: AtomicInt = 0
            fullProcessDispatchGroup.guaranteeValueAtDeinit(0)

            // this notify block is called when the full process has completed.
            fullProcessDispatchGroup.notify {
                DispatchQueue.main.async {
                    let successRate = Double(uploadSuccesses) / Double(self.mediaReferences.count)
                    if successRate > self.acceptableFailureRate {
                        self.totalProcessSuccess()
                    } else {
                        self.errorHandler(UploadingError.tooManyFailures)
                    }
                }
            }

            for mediaRef in self.mediaReferences {
                // alert the group that we're starting a process
                fullProcessDispatchGroup.increment()
                // wait until it's safe to start uploading
                outerLimit.wait()

                /// common cleanup operations needed later
                func finalizeMediaRef() {
                    self.singleUploadCompletion(mediaRef)
                    fullProcessDispatchGroup.decrement()
                    outerLimit.signal()
                }

                // wait until it's safe to start exporting
                exportLimit.wait()
                self.export(mediaRef) { (media, error) in
                    // allow another export to begin
                    exportLimit.signal()
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorHandler(error)
                            finalizeMediaRef()
                        }
                    } else {
                        guard let media = media else {
                            DispatchQueue.main.async {
                                self.errorHandler(UploadingError.invalidResponse)
                                finalizeMediaRef()
                            }
                            return
                        }
                        // the export was successful

                        var uploadAttempts = 0
                        /// define the upload process and its retry behavior
                        func doUpload() {
                            // respect Media's threading requirements
                            self.managedObjectContext.asyncPerform {
                                self.upload(media) { error in
                                    if let error = error {
                                        if uploadAttempts < self.uploadRetries {
                                            uploadAttempts += 1
                                            doUpload() // retry
                                        } else {
                                            DispatchQueue.main.async {
                                                // too many upload failures
                                                self.errorHandler(error)
                                                finalizeMediaRef()
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            uploadSuccesses += 1
                                            self.singleUploadSuccess(media)
                                            finalizeMediaRef()
                                        }
                                    }
                                }
                            }
                        }
                        // kick off the first upload
                        doUpload()
                    }
                }
            }
        }

        self.waitForExpectations(timeout: 1500)
    }

    func testHoneyBee2() {

        let a = HoneyBee.start(on: DispatchQueue.main)
                        .insert(mediaReferences)

        let b = a.move(to: DispatchQueue.global())
                .each(limit: uploadLimit, acceptableFailure: .ratio(self.acceptableFailureRate)) { elem in
                    let a2 = elem.finally { link in
                        link.move(to: DispatchQueue.main)
                            .chain(self.singleUploadCompletion)
                    }

                    let b2 = a2.limit(self.exportLimit) { link in
                        link.move(to: UtilityDispatchQueue())
                            .chain { (ref: String, completion: @escaping (Result<Media, Error>) -> Void) in
                                self.export(ref) { (media: Media?, error: Error?) in
                                    if let error = error {
                                        completion(.failure(error))
                                    } else if let media = media {
                                        completion(.success(media))
                                    } else {
                                        preconditionFailure()
                                    }
                                }
                            }
                    }

                    let c2 = b2.move(to: self.managedObjectContext)
                        .retry(self.uploadRetries) { link in
                            link.move(to: BackgroundDispatchQueue())
                                .chain { (media: Media, completion: @escaping (Result<Media, Error>) -> Void) in
                                    self.upload(media) { error in // subject to transient failure
                                        if let error = error {
                                            completion(.failure(error))
                                        } else {
                                            completion(.success(media))
                                        }
                                    }
                            }
                    }

                    let d2 = c2.move(to: DispatchQueue.main)
                        .chain { (media: Media, completion: @escaping (Result<Media, Error>) -> Void) in
                            self.singleUploadSuccess(media)
                            completion(.success(media))
                        }
                    d2.onResult { result in
                        failIfError(result)
                    }
            }.drop

        b.move(to: DispatchQueue.main)
         .chain(totalProcessSuccess)

        self.waitForExpectations(timeout: 15)
    }


    func testHoneyBee3() {

        let mainQ = HoneyBee.start(on: MainDispatchQueue())

        let exportQ = mainQ >> UtilityDispatchQueue()

        let asyncReferences = self.mediaReferences >> exportQ

        let uploadComplete = asyncReferences.each(limit: uploadLimit,
                                                  acceptableFailure: .ratio(self.acceptableFailureRate)) { reference in
            reference.finally { reference in
                self.singleUploadCompletion(reference >> mainQ)
            }

            let media = reference.limit(self.exportLimit) { reference in
                self.export(reference) >> self.managedObjectContext
                // the export is compute bound so limit it further
            }

            let uploaded:Link<Media, Error, BackgroundDispatchQueue> = media.retry(self.uploadRetries) { media in
                self.upload(media) +> media
                // the upload is subject to transient failure so retry it
            }

            self.singleUploadSuccess(uploaded >> mainQ)
                    .onError(self.errorHandler)
        }.drop

        self.totalProcessSuccessA(uploadComplete >> mainQ)

        self.waitForExpectations(timeout: 15)
    }
}
