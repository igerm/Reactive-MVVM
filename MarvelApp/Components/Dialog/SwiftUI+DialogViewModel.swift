import SwiftUI

extension DialogViewModel.Button.Style {
    var asButtonRole: SwiftUI.ButtonRole? {
        switch self {
        case .default: return nil
        case .cancel: return .cancel
        case .destructive: return .destructive
        }
    }
}

public extension View {

    func alert(presenting: DialogViewModel?) -> some View {
        alert(
            presenting?.title ?? "",
            isPresented: .constant(presenting != nil),
            presenting: presenting,
            actions: { viewModel in
                ForEach(viewModel.buttons) { (button: DialogViewModel.Button) -> Button in
                    Button(button.text, role: button.style.asButtonRole, action: button.action ?? { })
                }
            },
            message: { viewModel in
                Text(viewModel.message ?? "")
            }
        )
    }
}
