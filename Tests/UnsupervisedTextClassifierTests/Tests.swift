//
//  Tests.swift
//  UnsupervisedTextClassifierTests
//
//  Created by Javier Fuentes on 28-03-21.
//
//
import XCTest
import LASwift

@testable import UnsupervisedTextClassifier

class Tests: XCTestCase {
    
    struct TestArticle: Article {
        var text: String?
        var keywords: [String]?
//            var filterKeywords: Set<String>?
        var url: URL?
    }

    func testExtractKeywords() {
        XCTAssertEqual(UnsupervisedTextClassifier.extractKeywords(text: "What it's really like steering the world's biggest ships"), ["biggest", "world", "ships"])
    }

    func testLoadTexts() {
        let articles = sampleHeadlines.map({TestArticle.init(text: $0, keywords: Array(UnsupervisedTextClassifier.extractKeywords(text: $0)))})
        XCTAssertEqual(Cluster(articles: articles).matrix.rows, sampleHeadlines.count)
    }
    
    func testStatsPublisher() throws {
        let articles = sampleHeadlines.map({TestArticle.init(text: $0, keywords: Array(UnsupervisedTextClassifier.extractKeywords(text: $0)))})
        let stats = try awaitPublisher(UnsupervisedTextClassifier.statsPublisher(result: Cluster(articles: articles)))
        
        XCTAssertNotNil(stats.colsAvg)
        XCTAssertNotNil(stats.colsSum)
        XCTAssertNotNil(stats.q)
    }
    
    
    func testCorrelationMatrixPublisher() throws {
        let articles = sampleHeadlines.map({TestArticle.init(text: $0, keywords: Array(UnsupervisedTextClassifier.extractKeywords(text: $0)))})
        let cluster = try awaitPublisher(UnsupervisedTextClassifier.statsPublisher(result: Cluster(articles: articles)))
        let corrMatrix = try awaitPublisher(UnsupervisedTextClassifier.correlationMatrixPublisher(result: cluster))
        
        XCTAssertNotNil(corrMatrix.correlation)
    }
    
    func testSegmentResults() throws {
        let articles = sampleHeadlines.map({TestArticle.init(text: $0, keywords: Array(UnsupervisedTextClassifier.extractKeywords(text: $0)))})
        let cluster = Cluster(articles: articles)
        
        let results = try awaitPublisher(cluster.publisher.collect())
        XCTAssertNotNil(results.first)
        XCTAssertNotNil(results.first?.resultGroup.first)
    }
    
    

    func testPerformanceKeywordExtraction() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            for _ in 0..<450 {
                _ = UnsupervisedTextClassifier.extractKeywords(text: "UN officials condemn Myanmar junta after 100-plus civilians killed in one day")
                _ = UnsupervisedTextClassifier.extractKeywords(text: "What it's really like steering the world's biggest ships")
            }
        }
    }

    
    func testQ95() throws {

        let sampleMatrix = Matrix([
            [1,0,1,1,1],
            [1,1,0,0,1],
            [0,1,1,0,1],
            [1,0,1,0,0],
            [0,0,1,0,0]
        ])

        let vector = UnsupervisedTextClassifier.colSum(matrix: sampleMatrix)

        XCTAssertEqual(UnsupervisedTextClassifier.qPercentile(vector: vector, probability: 0.95), 3.8)


    }

    
    func testCov() throws {
        let sampleMatrix = Matrix([
            [1,0,1,1,1],
            [1,1,0,0,1],
            [0,1,1,0,1],
            [1,0,1,0,0],
            [0,0,1,0,0]
        ])

        
        let colsAvg1 = UnsupervisedTextClassifier.colAvg(vect: sampleMatrix[col: 0])
        let colsAvg2 = UnsupervisedTextClassifier.colAvg(vect: sampleMatrix[col: 1])

        
        let cov = UnsupervisedTextClassifier.cov(vect1: sampleMatrix[col: 0],
                                                 vect2: sampleMatrix[col: 1],
                                                 vect1Avg: colsAvg1,
                                                 vect2Avg: colsAvg2)
//        let cov = UnsupervisedTextClassifier.cov(matrix: sampleMatrix, pos: (0, 1), colsAvg: colsAvg)
        XCTAssertEqual(colsAvg1, 0.6)
        XCTAssertEqual(colsAvg2, 0.4)
        XCTAssertEqual(cov, -0.05000000000000002)
    }
    
    

    func testStd() throws {
        let sampleMatrix = Matrix([
            [1,0,1,1,1],
            [1,1,0,0,1],
            [0,1,1,0,1],
            [1,0,1,0,0],
            [0,0,1,0,0]
        ])

        let colsAvg = UnsupervisedTextClassifier.colAvg(vect: sampleMatrix[col: 0])
        let std = UnsupervisedTextClassifier.std(vect: sampleMatrix[col: 0], vectAvg: colsAvg)

        XCTAssertEqual(std, 0.48989794855663565)
    }

    func testPearson() throws {
        let sampleMatrix = Matrix([
            [1,0,1,1,1],
            [1,1,0,0,1],
            [0,1,1,0,1],
            [1,0,1,0,0],
            [0,0,1,0,0]
        ])
        
        let colsAvg1 = UnsupervisedTextClassifier.colAvg(vect: sampleMatrix[col: 0])
        let colsAvg2 = UnsupervisedTextClassifier.colAvg(vect: sampleMatrix[col: 1])

        
        let pearson = UnsupervisedTextClassifier.pearson(vect1: sampleMatrix[col: 0],
                                                 vect2: sampleMatrix[col: 1],
                                                 vect1Avg: colsAvg1,
                                                 vect2Avg: colsAvg2)
        XCTAssertEqual(pearson, -0.20833333333333337)
    }

    

}

import Combine

extension XCTestCase {
    func awaitPublisher<T: Publisher>(_ publisher: T, timeout: TimeInterval = 10, line: UInt = #line, file: StaticString = #file) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        
        let cancellable = publisher.sink { completion in
            
            switch completion {
            case .failure(let error):
                result = .failure(error)
            case .finished:
                break
            }
            expectation.fulfill()
            
        } receiveValue: { value in
            result = .success(value)
        }
        
        waitForExpectations(timeout: timeout) { _ in
            cancellable.cancel()
        }
        
        
        let unwrappedResult = try XCTUnwrap(result, "Awaited publisher did not produce any output", file: file, line: line)

        
        return try unwrappedResult.get()
    }
}
