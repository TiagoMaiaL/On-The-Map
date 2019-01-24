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

    /// The main scroll view of the controller.
    /// - Note: The scroll view is used to correclty position the textfields while the keyboard is being shown.
    @IBOutlet private weak var scrollView: UIScrollView!

    /// The content view inside the scroll view.
    @IBOutlet private weak var contentView: UIView!

    /// The textfield used to inform the user's name.
    @IBOutlet private weak var usernameTextField: UITextField!

    /// The textfield used to inform the user's password.
    @IBOutlet private weak var passwordTextField: UITextField!

    /// The button used to initiate the login.
    @IBOutlet private weak var loginButton: UIButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"

        // Configure the initial state of the views.
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    // MARK: Actions

    @IBAction func logIn(_ sender: UIButton?) {
        guard let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
            return
        }

        // TODO: Start the login process.
    }

    // MARK: Imperatives

    /// Subscribes to the keyboard notifications.
    private func subscribeToKeyboardNotifications() {
        subscribeToNotification(
            named: UIResponder.keyboardWillShowNotification,
            usingSelector: #selector(keyboardWillShow(_:))
        )
        subscribeToNotification(
            named: UIResponder.keyboardWillHideNotification,
            usingSelector: #selector(keyboardWillHide(_:))
        )
        subscribeToNotification(
            named: UIResponder.keyboardDidHideNotification,
            usingSelector: #selector(keyboardDidHide(_:))
        )
    }

    /// Adapts the position of the textfields while displaying the keyboard.
    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let keyboardY = getKeyboardYOrigin(from: sender) else {
            assertionFailure("Couldn't get the height of the keyboard.")
            return
        }

        let buttonY = view.convert(loginButton.frame, from: loginButton.superview!).origin.y + loginButton.frame.height
        var bottomVariation = buttonY - keyboardY

        // Update the scrollview to adjust the text fields with the keyboard.
        let bottomInset = scrollView.contentInset.bottom
        if bottomInset > 0 {
            bottomVariation += bottomInset
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomVariation, right: 0)
        // Scroll to the end of the content view.
        scrollView.scrollRectToVisible(CGRect(x: 0, y: contentView.frame.height, width: 1, height: 1), animated: true)
        scrollView.isScrollEnabled = false
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset = UIEdgeInsets()
    }

    @objc private func keyboardDidHide(_ sender: Notification) {
        scrollView.isScrollEnabled = true
    }

    /// Gets the Y origin of the keyboard from the passed notification object.
    /// - Parameter notification: The notification containing the height of the keyboard.
    /// - Returns: The Y origin of the keyboard, if provided.
    private func getKeyboardYOrigin(from notification: Notification) -> CGFloat? {
        if let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            return keyboardRect.origin.y
        } else {
            return nil
        }
    }
}

extension LoginViewController: UITextFieldDelegate {

    // MARK: Textfield Delegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            logIn(nil)
        }

        textField.resignFirstResponder()

        return true
    }
}

extension LoginViewController {

    // MARK: Notification helper methods

    /// Subscribes to a notification in the notification center.
    /// - Parameters:
    ///     - name: The name of the notification.
    ///     - selector: The selector to be called when the notification is received.
    private func subscribeToNotification(named name: Notification.Name, usingSelector selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }

    /// Unsubscribes from all notifications in the notification center.
    private func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
