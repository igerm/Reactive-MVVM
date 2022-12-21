import APIService
import CryptoKit
import Foundation

extension APIRequest {

    /// Access marvel APIRequests
    static var marvel: MarvelAPIRequests.Type { MarvelAPIRequests.self }
}

/// Namespace for everything MARVEL requests.
enum MarvelAPIRequests {

    static func hash(ts: String, apiKey: String, privateKey: String) -> String {
        let string = "\(ts)\(privateKey)\(apiKey)"
        guard let data = string.data(using: .utf8) else { return "" }
        let digest = Insecure.MD5.hash(data: data)
        let hash = digest
            .map { String(format: "%02hhx", $0) }
            .joined()
        return hash
    }

    static var baseURLString = "https://gateway.marvel.com:443"

    /// convenience creator of marvel requests
    static func marvelRequest(
        method: HTTPMethod = .get,
        path: String,
        apiKey: String,
        privateKey: String,
        queryItems: [URLQueryItem] = []
    ) -> APIRequest {

        let ts = "\(Date().timeIntervalSince1970)"
        let extraItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "ts", value: ts),
            URLQueryItem(name: "hash", value: hash(ts: ts, apiKey: apiKey, privateKey: privateKey)),
        ]

        return APIRequest(
            method: method,
            baseURL: baseURLString,
            path: path,
            queryItems: extraItems + queryItems
        )
    }

    enum CharactersOrderBy: String {
        case name
        case modified
        case nameDescending = "-name"
        case modifiedDescending = "-modified"
    }

    static func character(
        apiKey: String,
        privateKey: String,
        id: Int64
    ) -> APIRequest {

        return marvelRequest(
            path: "v1/public/characters/\(String(id))",
            apiKey: apiKey,
            privateKey: privateKey
        )
    }

    enum EventsOrderBy: String {
        case name
        case startDate
        case modified
        case nameDescending = "-name"
        case startDateDescending = "-startDate"
        case modifiedDescending = "-modified"
    }

    static func characters(
        apiKey: String,
        privateKey: String,
        name: String? = nil,
        nameStartsWith: String? = nil,
        modifiedSince: Date? = nil,
        eventIDs: [Int]? = nil,
        comicIDs: [Int]? = nil,
        seriesIDs: [Int]? = nil,
        storyIDs: [Int]? = nil,
        orderBy: [CharactersOrderBy]? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> APIRequest {

        let queryItems: [URLQueryItem] = [
            .init(name: "name", value: name),
            .init(name: "nameStartsWith", value: nameStartsWith),
            .init(name: "modifiedSince", value: modifiedSince),
            .init(name: "events", value: eventIDs),
            .init(name: "comics", value: comicIDs),
            .init(name: "series", value: seriesIDs),
            .init(name: "stories", value: storyIDs),
            .init(name: "orderBy", value: orderBy),
            .init(name: "limit", value: limit),
            .init(name: "offset", value: offset)
        ]
            .filter { $0.value != nil }

        return marvelRequest(
            path: "v1/public/characters",
            apiKey: apiKey,
            privateKey: privateKey,
            queryItems: queryItems
        )
    }

    static func events(
        apiKey: String,
        privateKey: String,
        name: String? = nil,
        nameStartsWith: String? = nil,
        modifiedSince: Date? = nil,
        creatorIDs: [Int]? = nil,
        charactIDs: [Int]? = nil,
        comicIDs: [Int]? = nil,
        seriesIDs: [Int]? = nil,
        storyIDs: [Int]? = nil,
        orderBy: [EventsOrderBy]? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> APIRequest {

        let queryItems: [URLQueryItem] = [
            .init(name: "name", value: name),
            .init(name: "nameStartsWith", value: nameStartsWith),
            .init(name: "modifiedSince", value: modifiedSince),
            .init(name: "creators", value: creatorIDs),
            .init(name: "characters", value: charactIDs),
            .init(name: "comics", value: comicIDs),
            .init(name: "series", value: seriesIDs),
            .init(name: "stories", value: storyIDs),
            .init(name: "orderBy", value: orderBy),
            .init(name: "limit", value: limit),
            .init(name: "offset", value: offset)
        ]
            .filter { $0.value != nil }

        return marvelRequest(
            path: "v1/public/events",
            apiKey: apiKey,
            privateKey: privateKey,
            queryItems: queryItems
        )
    }
}

extension URLQueryItem {
    init(name: String, value: Int?) {
        self.init(name: name, value: value.map { String($0) })
    }
    init(name: String, value: [Int]?) {
        self.init(
            name: name,
            value: value?
                .map { String($0) }
                .joined(separator: ",")
        )
    }
    init(name: String, value: Date?) {
        self.init(
            name: name,
            value: value.flatMap { DateFormatter.marvel.string(from: $0) }
        )
    }
    init(name: String, value: [MarvelAPIRequests.CharactersOrderBy]?) {
        self.init(
            name: name,
            value: value?
                .map { $0.rawValue }
                .joined(separator: ",")
        )
    }
    init(name: String, value: [MarvelAPIRequests.EventsOrderBy]?) {
        self.init(
            name: name,
            value: value?
                .map { $0.rawValue }
                .joined(separator: ",")
        )
    }
}
