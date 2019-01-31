//
//  AnnotationLinkTapRecognizer.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 31/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A gesture recognizer associated to a student annotation.
class AnnotationLinkTapRecognizer: UITapGestureRecognizer {

    // MARK: Properties

    /// The annotation link associated to the tap recognizer, accessible when the user taps an annotation view.
    var link: String

    // MARK: Initializers

    init(target: Any?, action: Selector?, link: String) {
        self.link = link

        super.init(target: target, action: action)
    }

}
