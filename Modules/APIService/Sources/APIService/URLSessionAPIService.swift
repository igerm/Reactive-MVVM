import Combine
import CombineExtensions
import Foundation

/// Live implementation of APIService using URLSession.
final public class URLSessionAPIService: APIService {

    let urlSession: URLSession

    public init(urlSession: URLSession? = nil) {

        if let urlSession = urlSession {
            self.urlSession = urlSession
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024)

            self.urlSession = URLSession(configuration: configuration)
        }
    }

    public func dataPublisher(for request: APIRequest) -> Future<Data, Error> {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.asURLRequest()
        } catch {
            return Fail(outputType: Data.self, failure: error).eraseToFuture()
        }
        return urlSession
            .dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, response: URLResponse) throws -> (Data, HTTPURLResponse) in
                guard let httpURLResponse = response as? HTTPURLResponse else {
                    throw URLSessionAPIServiceError.unexpectedURLResponse(response, data)
                }
                return (data, httpURLResponse)
            }
            .tryMap { (data: Data, response: HTTPURLResponse) throws -> Data in
                switch response.statusCode {
                case 100...399:
                    return data
                case 401:
                    throw URLSessionAPIServiceError.unauthorizedAccesss
                default:
                    throw URLSessionAPIServiceError.unexpectedHTTPURLResponse(response, data)
                }
            }
            .eraseToFuture()
    }
}

/// Error that the HTTPService may issue.
public enum URLSessionAPIServiceError: Error {

    /// The response included a 401. The user is no longer authenticated.
    case unauthorizedAccesss

    /// The response could not be cast to an HTTPURLResponse
    case unexpectedURLResponse(URLResponse, Data)

    /// The response is unexpected
    case unexpectedHTTPURLResponse(HTTPURLResponse, Data)
}

public enum APIRequestError: Error {

    case malformedBaseURL

    /// Malformed URL
    case malformedURL

    /// URL Request Could not be created
    case couldNotCreateURLRequest
}

private extension APIRequest {
    func asURLRequest() throws -> URLRequest {
        let url = try getBaseUrl().appendingPathComponent(path)
        var urlComponents = URLComponents(string: url.absoluteString)
        urlComponents?.queryItems = queryItems
        guard let finalURL = urlComponents?.url else {
            throw APIRequestError.couldNotCreateURLRequest
        }

        var urlRequest = URLRequest(url: URL(string: finalURL.absoluteString)!)
        urlRequest.httpMethod = method.rawValue

        body.map {
            urlRequest.httpBody = $0
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        headers.forEach({ (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        })
        return urlRequest
    }

    func getBaseUrl() throws -> URL {
        guard let baseURL = URL(string: baseURL) else {
            throw APIRequestError.malformedBaseURL
        }
        return baseURL
    }
}
