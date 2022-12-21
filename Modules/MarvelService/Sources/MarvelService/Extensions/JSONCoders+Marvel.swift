import Foundation

extension JSONDecoder {
    static var marvel: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.marvel)
        return decoder
    }
}

extension JSONEncoder {
    static var marvel: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.marvel)
        return encoder
    }
}
