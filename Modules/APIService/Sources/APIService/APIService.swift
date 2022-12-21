import Foundation
import Combine

/// Represents a network request
public struct APIRequest {

    public var method: HTTPMethod
    public var baseURL: String
    public var path: String
    public var headers: [String: String]
    public var queryItems: [URLQueryItem]
    public var body: Data?

    public init(
        method: HTTPMethod,
        baseURL: String,
        path: String,
        headers: [String : String] = [:],
        queryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
}

/// HTTP Method
public enum HTTPMethod: String {
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case trace = "TRACE"
}

/// Describes a service for making API calls through the network.
public protocol APIService {

    func dataPublisher(for request: APIRequest) -> Future<Data, Error>
}
