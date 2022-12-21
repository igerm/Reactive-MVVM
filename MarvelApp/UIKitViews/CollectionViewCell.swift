//
//  UIKitViews.swift
//  MarvelApp
//
//  Created by German Azcona on 12/13/22.
//

import UIKit

/// Generic CollectionViewCell. Can be initialized with any View. This allows us to separate view hierarchy and
/// layout from TableView/CollectionView implementations.
open class CollectionViewCell<View: UIView>: UICollectionViewCell, ReuseIdentifying {

    public let view: View

    @available(*, unavailable)
    public required init?(coder: NSCoder) { return nil }

    public init(view: View) {
        self.view = view
        super.init(frame: .zero)
        setupView()
    }

    public override init(frame: CGRect) {
        self.view = View(frame: frame)
        super.init(frame: frame)
        setupView()
    }

    func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        insetsLayoutMarginsFromSafeArea = false
        contentView.insetsLayoutMarginsFromSafeArea = false
        contentView.layoutMargins = .zero
        let contentMarginGuide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentMarginGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentMarginGuide.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentMarginGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentMarginGuide.trailingAnchor)
        ])
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        (view as? ReusableView)?.prepareForReuse()
    }
}

protocol ReusableView {
    func prepareForReuse()
}
