//
//  PrettyExamples.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 1/7/18.
//  Copyright © 2018 IAM Apps. All rights reserved.
//

import Foundation
import HoneyBee

struct PrettyExamples {
	
	func example1() {
		func handleError(_ error: Error) {}
		func fetchNewMovieTitle(completion: (String?, Error?) -> Void) {}
		func fetchReviews(for movieTitle: String, completion: (Result<[String], Error>) -> Void) {}
		func averageReviews(_ reviews: [String]) throws -> Int { return reviews.count }
		func fetchComments(for movieTitle: String, completion: (([String]?, Error?) -> Void)?) {}
		func countComments(_ comments: [String]) -> Int { return comments.count }
		func updateUI(withAverageReview: Int, commentsCount: Int) {}
		
		HoneyBee.start()
				.handlingErrors(with: handleError)
				.chain(fetchNewMovieTitle)
				.branch { stem in
					stem.chain(fetchReviews)
						.chain(averageReviews)
					+
					stem.chain(fetchComments)
						.chain(countComments)
				}
				.move(to: DispatchQueue.main)
				.chain(updateUI)
	}
	
	func example2() {
		func handleError(_ error: Error) {}
		func fetchNewMovieTitle(completion: (String?, Error?) -> Void) {}
		func fetchReviews(for movieTitle: String, completion: (Result<[String], Error>) -> Void) {}
		func isNonTrivial(_ int: Int, completion: (Bool) -> Void) {}
		func updateUI(withTotalWordsInNonTrivialReviews: Int) {}
		
		HoneyBee.start(on: DispatchQueue.main)
				.handlingErrors(with:handleError)
				.chain(fetchNewMovieTitle)
				.chain(fetchReviews)
				.map { elem in // parallel map
					elem.chain(\.count)	// Keypath access
				}
				.filter { elem in // parallel filtering
					elem.chain(isNonTrivial)
				}
				.reduce { pair in // parallel "pyramid" reduce
					pair.chain(+) // operator acess
				}
				.chain(updateUI)
	}
	

    // PyramidOfDoom {
    struct Image {}
    private var loadWebResource: SingleArgFunction<String,Data> { async1(self.loadWebResource) }
    private func loadWebResource(named name: String, completion: (Data?, Error?) -> Void) {}

    private var decodeImage: DoubleArgFunction<Data, Data, Image> { async2(self.decodeImage) }
    private func decodeImage(dataProfile: Data, image: Data) throws -> Image { return Image() }

    private var dewarpAndCleanupImage: SingleArgFunction<Image, Image> { async1(self.dewarpAndCleanupImage) }
    private func dewarpAndCleanupImage(_ image: Image, completion: (Image?, Error?) -> Void) {}

	func processImageData(completionBlock: @escaping (Image?, Error?) -> Void) {

		let a = HoneyBee.start()
				.handlingErrors { completionBlock(nil, $0) }

		let b = a.branch { stem -> Link<(Data,Data), DefaultDispatchQueue> in
                    stem.chain(loadWebResource(named: completion:) =<< "dataprofile.txt")
					+
                    stem.chain(loadWebResource(named: completion:) =<< "imagedata.dat")
				}

				b.chain(decodeImage)
				.chain(dewarpAndCleanupImage)
				.chain{ completionBlock($0, nil) }
	}
	
	func processImageDataCurried(completion: @escaping (Result<Image, ErrorContext>) -> Void) {
		HoneyBee.async(completion: completion) { hb in
            let dataProfile = self.loadWebResource(named: "dataprofile.txt")(hb)
            let imageData = self.loadWebResource(named: "imagedata.dat")(hb)
			
            let image = self.decodeImage(dataProfile: dataProfile)(image: imageData)
            let cleanedImage = self.dewarpAndCleanupImage(image)
			
			return cleanedImage
		}
	}

    func processImageDataCurried2(completion: @escaping (Result<Image, ErrorContext>) -> Void) {
        let errorHandler = { completion(.failure($0)) }
        let success = async1(){ completion(.success($0)) }

        let hb = HoneyBee.start().handlingErrors(with: errorHandler)

        let dataProfile = loadWebResource(named: "dataprofile.txt" >> hb)
        let imageData = loadWebResource(namd: "imagedata.dat" >> hb)

        let image = decodeImage(dataProfile: dataProfile)(image: imageData)
        let cleanedImage = dewarpAndCleanupImage(image)

        success(cleanedImage)
    }
}

