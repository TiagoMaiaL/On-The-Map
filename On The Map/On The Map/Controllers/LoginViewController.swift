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

    /// The Udacity api client used to log the user in and get its details.
    var udacityAPIClient: UdacityAPIClientProtocol!

    /// The main scroll view of the controller.
    /// - Note: The scroll view is used to correclty position the textfields while the keyboard is being shown.
    @IBOutlet private weak var scrollView: UIScrollView!

    /// The content view inside the scroll view.
    @IBOutlet private weak var contentView: UIView!

    /// The stack view holding the label, fields, and button.
    @IBOutlet weak var contentStackView: UIStackView!

    /// The textfield used to inform the user's name.
    @IBOutlet private weak var usernameTextField: UITextField!

    /// The textfield used to inform the user's password.
    @IBOutlet private weak var passwordTextField: UITextField!

    /// The button used to initiate the login.
    @IBOutlet private weak var loginButton: UIButton!

    /// The activity indicator showing the loading state.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(udacityAPIClient != nil, "The api client must be injected.")

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

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.TabBarController {
            if let navigationController = segue.destination as? UINavigationController,
                let tabController = navigationController.visibleViewController as? LocationsTabBarController {
                tabController.udacityClient = udacityAPIClient
                tabController.parseClient = ParseAPIClient()
                tabController.loggedUser = udacityAPIClient.user
            }
        }
    }

    // MARK: Actions

    @IBAction func logIn(_ sender: UIButton?) {
        guard let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
            return
        }

        // Disable views to show loading.
        enableViews(false)

        udacityAPIClient.logIn(withUsername: username, password: password) { account, session, error in
            guard error == nil else {
                self.enableViews(true)
                self.displayError(error!, withMessage: "The username or password provided isn't correct.")
                return
            }

            self.udacityAPIClient.getUserInfo(usingUserIdentifier: account!.key) { user, error in
                self.enableViews(true)

                guard error == nil else {
                    self.displayError(error!, withMessage: "Couldn't get the user details. Plase, try again later.")
                    return
                }

                DispatchQueue.main.async {
                    // Re-enable views when request finishes.
                    self.performSegue(withIdentifier: SegueIdentifiers.TabBarController, sender: self)
                }
            }
        }
    }

    // MARK: Imperatives

    /// Enables or disables the views to display the loading state.
    private func enableViews(_ isEnabled: Bool) {
        let views = [self.usernameTextField, self.passwordTextField, self.loginButton]
        views.forEach {
            $0?.resignFirstResponder()
            $0?.isEnabled = isEnabled
        }

        if isEnabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }

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

        // Update the scrollview to adjust the text field with the keyboard.
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let buttonToKeyboardMargin: CGFloat = 10
        let buttonY = view.convert(loginButton.frame, from: loginButton.superview!).origin.y +
            loginButton.frame.size.height + statusBarHeight + buttonToKeyboardMargin
        let bottomVariation = buttonY - keyboardY

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomVariation, right: 0)
        // Scroll to the end of the content view.
        scrollView.scrollRectToVisible(
            CGRect(x: 0, y: contentView.frame.height, width: 1, height: 1),
            animated: true
        )
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

extension UIViewController {

    // MARK: Notification helper methods

    /// Subscribes to a notification in the notification center.
    /// - Parameters:
    ///     - name: The name of the notification.
    ///     - selector: The selector to be called when the notification is received.
    func subscribeToNotification(named name: Notification.Name, usingSelector selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }

    /// Unsubscribes from all notifications in the notification center.
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Error handling helper methods

    /// Displays an error message to the user.
    /// - Parameters:
    ///     - error: the error.
    ///     - message: the massage to be displayed.
    func displayError(_ error: APIClient.RequestError, withMessage message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))

            var alertMessage: String?

            switch error {
            case .connection:
                alertMessage = "There's a problem with your internet connection, please, fix it and try again."
            case .response(_):
                alertMessage = message
            default:
                break
            }

            alert.message = alertMessage
            self.present(alert, animated: true)
        }
    }
}
