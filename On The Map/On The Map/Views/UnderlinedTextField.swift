//
//  UnderlinedTextField.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 07/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// MARK: A text field with an underline.
@IBDesignable class UnderlinedTextField: UITextField {

    // MARK: Imperatives

    /// The layer adding the underline.
    private lazy var underlineLayer: CALayer = {
        let underlineLayer = CALayer()
        underlineLayer.backgroundColor = textColor?.cgColor ?? UIColor.black.cgColor

        return underlineLayer
    }()

    /// The height of the underline bar.
    @IBInspectable var underlineHeight: CGFloat = 1

    // MARK: Life cycle

    override func prepareForInterfaceBuilder() {
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if underlineLayer.superlayer == nil {
            underlineLayer.frame = CGRect(x: 0, y: frame.height + 1, width: frame.width, height: underlineHeight)
            layer.addSublayer(underlineLayer)
        }
    }
}
