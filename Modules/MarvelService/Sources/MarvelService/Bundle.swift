import Foundation

extension Bundle {

    private final class BundleToken {}

    public static var marvelServiceBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
}

