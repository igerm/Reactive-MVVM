import Foundation

// MARK: - Response
public struct Response<R: Codable & Hashable>: Codable, Hashable {

    public let code: Int64
    public let status, copyright, attributionText, attributionHTML: String
    public let etag: String
    public let data: DataContainer<R>

    public init(
        code: Int64,
        status: String,
        copyright: String,
        attributionText: String,
        attributionHTML: String,
        etag: String,
        data: DataContainer<R>
    ) {
        self.code = code
        self.status = status
        self.copyright = copyright
        self.attributionText = attributionText
        self.attributionHTML = attributionHTML
        self.data = data
        self.etag = etag
    }
}

// MARK: - Page information for a response
public struct DataContainer<R: Codable & Hashable>: Codable, Hashable {

    public let offset, limit, total, count: Int64
    public let results: [R]

    public init(offset: Int64, limit: Int64, total: Int64, count: Int64, results: [R]) {
        self.offset = offset
        self.limit = limit
        self.total = total
        self.count = count
        self.results = results
    }
}

// MARK: - Thumbnail
public struct Thumbnail: Codable, Hashable {

    public let path, fileExtension: String

    public var url: URL? { URL(string: path+"."+fileExtension) }

    public enum CodingKeys: String, CodingKey {
        case path
        case fileExtension = "extension"
    }

    public init(path: String, fileExtension: String) {
        self.path = path
        self.fileExtension = fileExtension
    }

    public static var empty: Self { .init(path: "", fileExtension: "") }
}

// MARK: - URLElement
public struct URLElement: Codable, Hashable {
    public let type, url: String
}


// MARK: - List

public struct List<Item: Codable & Hashable>: Codable, Hashable {

    public let available, returned: Int64
    public let collectionURI: String
    public let items: [Item]

    public init(available: Int64, returned: Int64, collectionURI: String, items: [Item]) {
        self.available = available
        self.returned = returned
        self.collectionURI = collectionURI
        self.items = items
    }

    static var empty: Self { .init(available: 0, returned: 0, collectionURI: "", items: []) }
}

// MARK: - Summaries

public struct ComicSummary: Codable, Hashable {

    public let resourceURI, name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }

    static var empty: Self { .init(resourceURI: "", name: "") }
}

public struct EventSummary: Codable, Hashable {
    public let resourceURI, name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }

    static var empty: Self { .init(resourceURI: "", name: "") }
}

public struct SeriesSummary: Codable, Hashable {
    public let resourceURI, name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }

    static var empty: Self { .init(resourceURI: "", name: "") }
}

public struct StorySummary: Codable, Hashable {
    public let resourceURI, name, type: String

    public init(resourceURI: String, name: String, type: String) {
        self.resourceURI = resourceURI
        self.name = name
        self.type = type
    }

    static var empty: Self { .init(resourceURI: "", name: "", type: "") }
}

public struct CreatorSummary: Codable, Hashable {
    public let resourceURI, name, role: String

    public init(resourceURI: String, name: String, role: String) {
        self.resourceURI = resourceURI
        self.name = name
        self.role = role
    }

    static var empty: Self { .init(resourceURI: "", name: "", role: "") }
}

public struct CharacterSummary: Codable, Hashable {
    public let resourceURI, name: String

    public init(resourceURI: String, name: String) {
        self.resourceURI = resourceURI
        self.name = name
    }

    public var id: Int64? {
        guard let url = URL(string: resourceURI) else {
            return nil
        }
        let idString = url.lastPathComponent
        return Int64(idString)
    }

    static var empty: Self { .init(resourceURI: "", name: "") }
}
