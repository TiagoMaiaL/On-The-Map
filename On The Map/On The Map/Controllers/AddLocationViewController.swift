//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 31/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller in charge of collecting the student information to be posted.
class AddLocationViewController: UIViewController, UITextFieldDelegate {

    // MARK: Imperatives

    /// The segue identifier taking to the map controller with the student annotation to be posted.
    private let segueIdentifier = "show annotation on the map."

    /// The text field used to inform the location on the map.
    @IBOutlet weak var locationTextField: UITextField!

    /// The text field used to inform the link to be posted.
    @IBOutlet weak var linkTextField: UITextField!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
        linkTextField.delegate = self
    }

    // MARK: Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let isLocationEmpty = locationTextField.text?.isEmpty ?? true
        let isLinkEmpty = linkTextField.text?.isEmpty ?? true

        return !isLocationEmpty && !isLinkEmpty
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the informations to the next controller.
        let locationText = locationTextField.text!
        let linkText = linkTextField.text!

        print(locationText)
        print(linkText)
    }
}

extension AddLocationViewController {

    // MARK: UITextField delegate methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if textField == locationTextField {
            linkTextField.becomeFirstResponder()
        } else if textField == linkTextField {
            performSegue(withIdentifier: segueIdentifier, sender: self)
        }

        return true
    }
}
