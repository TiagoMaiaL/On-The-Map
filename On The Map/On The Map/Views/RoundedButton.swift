//
//  RoundedButton.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 07/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A button with rounded borders.
@IBDesignable class RoundedButton: UIButton {

    // MARK: Properties

    override var isEnabled: Bool {
        didSet {
            UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
                self.alpha = self.isEnabled ? 1 : 0.5
            }.startAnimation()
        }
    }

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }

}
