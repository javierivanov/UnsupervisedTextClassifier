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





    func testExtractKeywords() {
        XCTAssertEqual(UnsupervisedTextClassifier.extractKeywords(text: "What it's really like steering the world's biggest ships"), ["biggest", "world", "ships"])
    }

    func testLoadTexts() {
        struct TestArticle: Article {
            var text: String?
            var keywords: [String]?
//            var filterKeywords: Set<String>?
            var url: URL?
        }
        let articles = sampleHeadlines.map({TestArticle.init(text: $0, keywords: Array(UnsupervisedTextClassifier.extractKeywords(text: $0)))})
        XCTAssertEqual(Cluster(articles: articles).matrix.rows, sampleHeadlines.count)
    }
    
//    func testProcessResults() {
//        struct TestArticle: Article {
//            var text: String?
//            var keywords: [String]?
////            var filterKeywords: Set<String>?
//            var url: URL?
//        }
//        let articles = sampleHeadlines.map({TestArticle.init(text: $0, keywords: Array(UnsupervisedTextClassifier.extractKeywords(text: $0)))})
//        
//    }
    
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//            for _ in 0..<450 {
//                _ = UnsupervisedTextClassifier.extractKeywords(text: "UN officials condemn Myanmar junta after 100-plus civilians killed in one day")
//                _ = UnsupervisedTextClassifier.extractKeywords(text: "What it's really like steering the world's biggest ships")
//            }
//        }
//    }

//
//    func nottotestPerformance() throws {
//        //self.measure {
//
//            print("Running loadTexts")
//        let out: (textsMap: [[String]], keywords: [String]) = UnsupervisedTextClassifier.loadTexts(texts: sampleHeadlines)
//            print("Done Running loadTexts")
//        let matrix = UnsupervisedTextClassifier.buildMatrix(textsMap: out.textsMap, keywords: out.keywords)
//            print("matrix.cols: \(matrix.cols) matrix.rows: \(matrix.rows)")
//        let colsSum = UnsupervisedTextClassifier.colSum(matrix: matrix)
//            print("colsSum.reduce: \(colsSum.reduce(0, +))")
//        let colsAvg = UnsupervisedTextClassifier.colsAvg(vector: colsSum, n: matrix.rows)
//            print("colsAvg.reduce: \(colsAvg.reduce(0, +))")
//
//            let x = 80 / Double(colsSum.count)
//        let q = UnsupervisedTextClassifier.qPercentile(vector: colsSum, percentile: 1.0 - x)
//            print("q: \(q)")
//            let idxs = colsSum.enumerated().filter {$0.element >= q}.map {$0.offset}
//
//        let newColsSum = UnsupervisedTextClassifier.filterCols(vector: colsSum, cols: idxs)
//        let newColsAvg = UnsupervisedTextClassifier.filterCols(vector: colsAvg, cols: idxs)
//
//        let (newMatrix, newKeywords) = UnsupervisedTextClassifier.filterCols(matrix: matrix, cols: idxs, keywords: out.keywords)
//
//            print("Larger than zer0\(newMatrix.map{$0.filter({$0 > 0})})")
//
//
//            print("newKeywords.count: \(newKeywords.count)")
//            print("newKeywords: \(newKeywords.sorted())")
//
//
//        let corrMatrix = UnsupervisedTextClassifier.corrMatrix(matrix: newMatrix, colsAvg: newColsAvg, colsSum: newColsSum)
//            print("Final Count \(corrMatrix.count)")
//            let sorted = corrMatrix.sorted(by: {a, b in a.0 > b.0})
//            let norms = UnsupervisedTextClassifier().computeNorm(matrix: newMatrix)
//
//
//            for i in 0...10 {
//                let (x, (a, b)) = sorted[i]
//                print("\(x), \(newKeywords[a]), \(newKeywords[b])")
//                let targetMatrix = UnsupervisedTextClassifier.filterRows(matrix: newMatrix, cols: (a, b))
//                let targetVector = UnsupervisedTextClassifier.avgMatrixToVector(matrix: targetMatrix)
//                print(targetVector)
//
//                let results = UnsupervisedTextClassifier().cosineSimilarity(matrix: newMatrix, vector: targetVector, norm_rows: norms)
//
//                results.enumerated().sorted(by: {a,b in a.element < b.element})[0...10].map { result in
//                    print(result.element, sampleHeadlines[result.offset])
//                }
//                print("-----")
//            }
//            print("#####")
//        //}
//    }
//
//
//    func testBuildMatrix() throws {
//
//        let textsMap: [[String]] = [
//            ["sample", "text", "no"],
//            ["another", "text", "sample", "no"],
//            ["no", "yes"],
//        ]
//
//        let keywords = Array(arrayLiteral: "sample", "text", "another", "no", "yes").sorted()
//
//
//
//        let matrix = UnsupervisedTextClassifier.buildMatrix(textsMap: textsMap, keywords: keywords)
//
//        let result = matrix.reduce(Array(repeating: 0.0, count: 5), { result, next in
//            var newResult = result
//            for (k,v) in next.enumerated() {
//                newResult[k] += v
//            }
//            return newResult
//        })
//
//        XCTAssertEqual(result.sorted(), Array(arrayLiteral: 2.0, 3.0, 2.0, 1.0, 1.0).sorted())
//    }
//
//
//    func testQ95() throws {
//
//        let sampleMatrix = Matrix([
//            [1,0,1,1,1],
//            [1,1,0,0,1],
//            [0,1,1,0,1],
//            [1,0,1,0,0],
//            [0,0,1,0,0]
//        ])
//
//        let vector = UnsupervisedTextClassifier.colSum(matrix: sampleMatrix)
//
//        XCTAssertEqual(UnsupervisedTextClassifier.q95(vector: vector), 3.8)
//
//
//    }
//
//    func testCov() throws {
//        let sampleMatrix = Matrix([
//            [1,0,1,1,1],
//            [1,1,0,0,1],
//            [0,1,1,0,1],
//            [1,0,1,0,0],
//            [0,0,1,0,0]
//        ])
//
//        let colsSum = UnsupervisedTextClassifier.colSum(matrix: sampleMatrix)
//        let colsAvg = UnsupervisedTextClassifier.colsAvg(vector: colsSum, n: sampleMatrix.rows)
//
//        let cov = UnsupervisedTextClassifier.cov(matrix: sampleMatrix, pos: (0, 1), colsAvg: colsAvg)
//
//        XCTAssertLessThanOrEqual(abs(cov - -0.05), 0.01)
//    }
//
//    func testStd() throws {
//        let sampleMatrix = Matrix([
//            [1,0,1,1,1],
//            [1,1,0,0,1],
//            [0,1,1,0,1],
//            [1,0,1,0,0],
//            [0,0,1,0,0]
//        ])
//
//        //std(matrix: Matrix, colsAvg: Vector, col: Int)
//
//        let colsSum = UnsupervisedTextClassifier.colSum(matrix: sampleMatrix)
//        let colsAvg = UnsupervisedTextClassifier.colsAvg(vector: colsSum, n: sampleMatrix.rows)
//        let res = UnsupervisedTextClassifier.std(matrix: sampleMatrix, colsAvg: colsAvg, col: 0)
//
//
//        XCTAssertLessThanOrEqual(abs(res - 0.547723), 0.00001)
//    }
//
//
//    func testPearson() throws {
//        let sampleMatrix = Matrix([
//            [1,0,1,1,1],
//            [1,1,0,0,1],
//            [0,1,1,0,1],
//            [1,0,1,0,0],
//            [0,0,1,0,0]
//        ])
//
//        //std(matrix: Matrix, colsAvg: Vector, col: Int)
//
//        let colsSum = UnsupervisedTextClassifier.colSum(matrix: sampleMatrix)
//        let colsAvg = UnsupervisedTextClassifier.colsAvg(vector: colsSum, n: sampleMatrix.rows)
//        let pearson1 = UnsupervisedTextClassifier.pearson(matrix: sampleMatrix, colsAvg: colsAvg, pos: (0, 1))
//        XCTAssertLessThanOrEqual(abs(pearson1 - -0.166667), 0.0001)
//
//        let pearson2 = UnsupervisedTextClassifier.pearson(matrix: sampleMatrix, colsAvg: colsAvg, pos: (0, 3))
//        XCTAssertLessThanOrEqual(abs(pearson2 - 0.408248), 0.0001)
//    }
//
//    func testCorr() throws {
//        let sampleMatrix = Matrix([
//            [1,0,1,1,1],
//            [1,1,0,0,1],
//            [0,1,1,0,1],
//            [1,0,1,0,0],
//            [0,0,1,0,0]
//        ])
//        let colsSum = UnsupervisedTextClassifier.colSum(matrix: sampleMatrix)
//        let colsAvg = UnsupervisedTextClassifier.colsAvg(vector: colsSum, n: sampleMatrix.rows)
//
//        let corr = UnsupervisedTextClassifier.corrMatrix(matrix: sampleMatrix, colsAvg: colsAvg, colsSum: colsSum)
//
//        XCTAssertLessThanOrEqual(abs(corr[1].0 - -0.408248), 0.0001)
//    }

}
