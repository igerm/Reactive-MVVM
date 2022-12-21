//
//  UIKitExtensions.swift
//  MarvelApp
//
//  Created by German Azcona on 12/13/22.
//

import UIKit

extension NSLayoutConstraint {
    public func with(priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
