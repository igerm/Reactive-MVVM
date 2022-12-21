//
//  ReuseIdentifying.swift
//  MarvelApp
//
//  Created by German Azcona on 12/13/22.
//

import UIKit

public protocol ReuseIdentifying {}

public extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

public extension UICollectionView {

    /// Registers a cell on the collection view if the cell implements `ReuseIdentifting`.
    func register<Cell>(_ cell: Cell.Type = Cell.self) where Cell: UICollectionViewCell, Cell: ReuseIdentifying {
        register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }

    /// Dequeues a cell from the collection view if the cell implements `ReuseIdentifting`.
    func dequeue<Cell>(_ cell: Cell.Type = Cell.self, for indexPath: IndexPath) -> Cell
    where Cell: UICollectionViewCell, Cell: ReuseIdentifying {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("UICollectionView didn't register \(String(describing: cell))")
        }
        return cell
    }
}

public extension UICollectionView {

    /// Registers a reusableSupplementaryView on the collection view if the view implements `ReuseIdentifting`.
    func registerReusableSupplementaryView<View>(_ viewType: View.Type = View.self, kind: String)
    where View: UICollectionReusableView, View: ReuseIdentifying {
        register(viewType, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewType.reuseIdentifier)
    }

    /// Dequeues a reusableSupplementaryView from the collection view if the view implements `ReuseIdentifting`.
    func dequeueReusableSupplementaryView<View>(
        _ viewType: View.Type = View.self,
        ofKind: String,
        for indexPath: IndexPath
    ) -> View where View: UICollectionReusableView, View: ReuseIdentifying {

        guard let view = dequeueReusableSupplementaryView(
            ofKind: ofKind,
            withReuseIdentifier: viewType.reuseIdentifier,
            for: indexPath
        ) as? View else {
            fatalError("UICollectionView didn't register \(String(describing: viewType))")
        }
        return view
    }
}

public extension UITableView {

    func register<Cell>(_ cell: Cell.Type = Cell.self) where Cell: UITableViewCell, Cell: ReuseIdentifying {
        register(cell, forCellReuseIdentifier: cell.reuseIdentifier)
    }

    func dequeue<Cell>(_ cell: Cell.Type = Cell.self, for indexPath: IndexPath) -> Cell
    where Cell: UITableViewCell, Cell: ReuseIdentifying {
        guard let cell = dequeueReusableCell(withIdentifier: cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("UITableView didn't register \(String(describing: cell))")
        }
        return cell
    }
}
