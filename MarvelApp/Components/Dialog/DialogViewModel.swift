import Foundation

public final class DialogViewModel {

    public let title: String?
    public let message: String?
    public let buttons: [Button]

    public init(title: String?, message: String?, buttons: [Button]) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }

    public struct Button: Identifiable {

        public var id = UUID() // SwiftUI.ForEach needs Button to be Identifiable

        public enum Style { case `default`, cancel, destructive }

        public let text: String
        public let style: Style
        public let action: (() -> Void)?

        public init(text: String, style: Style, action: (() -> Void)?) {
            self.text = text
            self.style = style
            self.action = action
        }
    }
}

import MarvelLocalization

extension DialogViewModel {

    static func error(title: String? = nil, message: String? = nil, dismissTitle: String? = nil) -> Self {
        return self.init(
            title: title ?? L10n.Generic.ErrorAlert.title,
            message: message ?? L10n.Generic.ErrorAlert.message,
            buttons: [
                .init(
                    text: dismissTitle ?? L10n.Generic.ErrorAlert.DismissButton.title,
                    style: .default,
                    action: nil
                )
            ]
        )
    }
}
