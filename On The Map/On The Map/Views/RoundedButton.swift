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

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }

}
