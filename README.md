# Unsupervised Text Classifier

This project is a simple text classifier based on Pearson correlation and F1 score for similarity selection.
It makes use of the Combine Framework provided by the Apple SDK.

## Usage:

`import UnsupervisedTextClassifier`

### Article Protocol

A protocol Article is provided to interoperate with the package functions. It can be used as shown:

```
protocol Article: Codable {
    var text: String? {get set}
    var keywords: [String]? {get set}
    var url: URL? {get set}
}

```

```
struct TestArticle: Article {
    var text: String?
    var keywords: [String]?
    var url: URL?
    var optionalFields: ....
}
```

### Cluster Definition

The Cluster struct:

```
struct Cluster {
    init(articles: [Article], maxSimilarity: Double = 0.5)
    var publisher: AnyPublisher<SegmentResultGroup, Never>
}
```

The Cluster struct publishes the `SegmentResultGroup` which contains the groupped Articles.

#### Articles ingestion example

```swift
@Published var segmentResults: [SegmentResultGroup] = []

let sampleHeadlines = ["How many people can I have a drink with? And other questions",
                       "Full interview: Hillary Clinton, January 17",
                       "Covid lockdown eases: Celebrations as pub gardens and shops reopen",
                       "Chauvin Trial Judge Denies Request For Jury Sequestration After Police Shooting",
                       "Psaki says Biden 'does not spend his time tweeting conspiracy theories' after a GOP senator criticized the president's social-media use",
                       "Police release bodycam footage from officer involved shooting in Minnesota"]

let articles = sampleHeadlines.map { headline in
    let keywords: Set<String> = UnsupervisedTextClassifier.extractKeywords(text: headline)
    return TestArticle(text: headline, keywords: Array(keywords))
}

let cluster = Cluster(articles: articles)

cluster
    .publisher
    .collect()
    .assign(to: &$segmentResults)

```

### SegmentResultGroup Definition

Each `SegmentResultGroup` represents a cluster with similar elements based on keywords matching.

```swift
struct ResultGroup: Identifiable {
    public var similarity: Double
    public var article: Article
    public var row: Int
}

public struct CorrelationResult {
    public var score: Double
    public var tokens: (a: Int, b: Int)
}

struct SegmentResultGroup: Identifiable {
    public var correlation: CorrelationResult
    public var resultGroup: [ResultGroup]
}

```
