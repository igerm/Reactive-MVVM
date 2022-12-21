// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum CharacterDetails {
    public enum DateLabel {
      /// Last updated: %@
      public static func lastModified(_ p1: Any) -> String {
        return L10n.tr("Localizable", "character_details.date_label.lastModified", String(describing: p1), fallback: "Last updated: %@")
      }
    }
    public enum EventsLabel {
      /// Events (%@)
      public static func count(_ p1: Any) -> String {
        return L10n.tr("Localizable", "character_details.events_label.count", String(describing: p1), fallback: "Events (%@)")
      }
    }
  }
  public enum Characters {
    /// Characters
    public static let title = L10n.tr("Localizable", "characters.title", fallback: "Characters")
    public enum Cell {
      public enum DateLabel {
        /// Last modified: %@
        public static func lastModified(_ p1: Any) -> String {
          return L10n.tr("Localizable", "characters.cell.date_label.lastModified", String(describing: p1), fallback: "Last modified: %@")
        }
      }
      public enum StoriesLabel {
        /// Plural format key: "%#@VARIABLE@"
        public static func count(_ p1: Int) -> String {
          return L10n.tr("Localizable", "characters.cell.stories_label.count", p1, fallback: "Plural format key: \"%#@VARIABLE@\"")
        }
      }
    }
    public enum Filter {
      /// Name
      public static let name = L10n.tr("Localizable", "characters.filter.name", fallback: "Name")
      /// Recents
      public static let recents = L10n.tr("Localizable", "characters.filter.recents", fallback: "Recents")
    }
  }
  public enum Events {
    /// Events
    public static let title = L10n.tr("Localizable", "events.title", fallback: "Events")
    public enum Cell {
      public enum ComicsLabel {
        /// Plural format key: "%#@VARIABLE@"
        public static func count(_ p1: Int) -> String {
          return L10n.tr("Localizable", "events.cell.comics_label.count", p1, fallback: "Plural format key: \"%#@VARIABLE@\"")
        }
      }
    }
    public enum Search {
      /// No results found
      public static let noResults = L10n.tr("Localizable", "events.search.no_results", fallback: "No results found")
      /// Filter Events
      public static let placeholder = L10n.tr("Localizable", "events.search.placeholder", fallback: "Filter Events")
    }
  }
  public enum Favorites {
    /// Favorites
    public static let title = L10n.tr("Localizable", "favorites.title", fallback: "Favorites")
  }
  public enum Generic {
    public enum ErrorAlert {
      /// An error has ocurred. Please try again later.
      public static let message = L10n.tr("Localizable", "generic.error_alert.message", fallback: "An error has ocurred. Please try again later.")
      /// Oops!
      public static let title = L10n.tr("Localizable", "generic.error_alert.title", fallback: "Oops!")
      public enum DismissButton {
        /// Ok
        public static let title = L10n.tr("Localizable", "generic.error_alert.dismissButton.title", fallback: "Ok")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
