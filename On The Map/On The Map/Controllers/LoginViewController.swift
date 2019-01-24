//
//  LoginViewController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 24/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller in charge of handling the login process.
class LoginViewController: UIViewController {

    // MARK: Properties

    /// The textfield used to inform the user's name.
    @IBOutlet weak var usernameTextField: UITextField!

    /// The textfield used to inform the user's password.
    @IBOutlet weak var passwordTextField: UITextField!

    /// The button used to initiate the login.
    @IBOutlet weak var loginButton: UIButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"

        // Configure the initial state of the views.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    // MARK: Actions

    @IBAction func logIn(_ sender: UIButton) {
        // TODO: Start the login process.
    }
}

extension LoginViewController: UITextFieldDelegate {

}
