import Foundation

extension File {
    var data: Data {
        return try! Data(contentsOf: url)
    }
}
