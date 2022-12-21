import UIKit

extension DialogViewModel.Button.Style {
    var asUIAlertActionStyle: UIAlertAction.Style {
        switch self {
        case .default: return .default
        case .cancel: return .cancel
        case .destructive: return .destructive
        }
    }
}

public extension UIAlertController {

    convenience init(dialogViewModel: DialogViewModel) {
        self.init(
            title: dialogViewModel.title,
            message: dialogViewModel.message,
            preferredStyle: .alert
        )
        dialogViewModel.buttons.forEach { button in
            addAction(.init(title: button.text, style: button.style.asUIAlertActionStyle))
        }
    }
}
