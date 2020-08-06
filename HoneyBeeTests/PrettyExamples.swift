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
		func handleError(_ error: Result<Void, Error>) {}
		func fetchNewMovieTitle(completion: (String?, Error?) -> Void) {}
		func fetchReviews(for movieTitle: String, completion: (Result<[String], Error>) -> Void) {}
		func averageReviews(_ reviews: [String]) throws -> Int { return reviews.count }
		func fetchComments(for movieTitle: String, completion: (([String]?, Error?) -> Void)?) {}
		func updateUI(withAverageReview: Int, commentsCount: Int) {}
		
		let hb = HoneyBee.start()

        let title = async0(fetchNewMovieTitle)(hb)

        let reviews = async1(fetchReviews)(title)
        let aveReview = async1(averageReviews)(reviews)

        let comments = async1(fetchComments)(title)
        let commentCount = comments.count

        let mainQ = (hb >> MainDispatchQueue()).expect(Error.self)

        let result = async2(updateUI)(commentCount >> mainQ)(aveReview >> mainQ)
        result.onResult(handleError)
	}
	
	func example2() {
		func handleError(_ error: Error) {}
		func fetchNewMovieTitle(completion: (String?, Error?) -> Void) {}
		func fetchReviews(for movieTitle: String, completion: (Result<[String], Error>) -> Void) {}
		func isNonTrivial(_ int: Int, completion: (Bool) -> Void) {}
		func updateUI(withTotalWordsInNonTrivialReviews: Int) {}
		
		let hb = HoneyBee.start(on: DispatchQueue.main)
        let title = async0(fetchNewMovieTitle)(hb)
        let reviews = async1(fetchReviews)(title)

        let safeReviews = reviews.handleError(handleError)

        let totalWordsInNonTrivialReviews =
                safeReviews.map { elem in // parallel map
					elem.chain(\.count)	// Keypath access
				}
				.filter { elem in // parallel filtering
					async1(isNonTrivial)(elem)
				}
				.reduce { pair in // parallel "pyramid" reduce
					pair.chain(+) // operator acess
				}

        async1(updateUI)(totalWordsInNonTrivialReviews)
	}
	

    // PyramidOfDoom {
    struct Image {}
    private var loadWebResource: SingleArgFunction<String,Data, Error> { async1(self.loadWebResource) }
    private func loadWebResource(named name: String, completion: (Data?, Error?) -> Void) {}

    private var decodeImage: DoubleArgFunction<Data, Data, Image, Error> { async2(self.decodeImage) }
    private func decodeImage(dataProfile: Data, image: Data) throws -> Image { return Image() }

    private var dewarpAndCleanupImage: SingleArgFunction<Image, Image, Error> { async1(self.dewarpAndCleanupImage) }
    private func dewarpAndCleanupImage(_ image: Image, completion: (Image?, Error?) -> Void) {}
	
	func processImageData(completion: @escaping (Result<Image, Error>) -> Void) {
		HoneyBee.async(completion: completion) { hb in
            let dataProfile = self.loadWebResource("dataprofile.txt")(hb)
            let imageData = self.loadWebResource("imagedata.dat")(hb)
			
            let image = self.decodeImage(dataProfile)(imageData)
            let cleanedImage = self.dewarpAndCleanupImage(image)
			
			return cleanedImage
		}
	}

    func processImageData2(completion: @escaping (Result<Image, ErrorContext<Error>>) -> Void) {
        let hb = HoneyBee.start()

        let dataProfile = loadWebResource("dataprofile.txt" >> hb)
        let imageData = loadWebResource("imagedata.dat" >> hb)

        let image = decodeImage(dataProfile)(imageData)
        let cleanedImage = dewarpAndCleanupImage(image)

        cleanedImage.onResult(completion)
    }
}

