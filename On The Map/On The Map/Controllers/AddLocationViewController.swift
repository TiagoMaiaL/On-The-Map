//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 31/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import MapKit

/// Controller in charge of collecting the student information to be posted.
class AddLocationViewController: UIViewController, UITextFieldDelegate {

    // MARK: Imperatives

    /// The segue identifier taking to the map controller with the student annotation to be posted.
    private let segueIdentifier = "show annotation on the map"

    /// The text field used to inform the location on the map.
    @IBOutlet weak var locationTextField: UITextField!

    /// The text field used to inform the link to be posted.
    @IBOutlet weak var linkTextField: UITextField!

    /// The button used to find the user location.
    @IBOutlet weak var findLocationButton: UIButton!

    /// The currently logged in user.
    var loggedUser: User!

    /// The parse API client used to create or update the user's location.
    var parseClient: ParseAPIClientProtocol!

    /// The region of the current user, if retrieved.
    var userLocation: MKUserLocation?

    /// The placemark searched by the user.
    private var searchedPlacemark: MKPlacemark?

    /// The location posted by the current user, if existent.
    var loggedUserStudentInformation: StudentInformation?

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(loggedUser != nil)
        precondition(parseClient != nil)

        if let userInformation = loggedUserStudentInformation {
            locationTextField.text = userInformation.mapTextReference
            linkTextField.text = userInformation.mediaUrl.absoluteString
        }

        locationTextField.delegate = self
        linkTextField.delegate = self
    }

    // MARK: Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return searchedPlacemark != nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the informations to the next controller.
        let locationText = locationTextField.text!
        let linkText = linkTextField.text!

        if let detailsController = segue.destination as? StudentLocationDetailsViewController {
            detailsController.loggedUser = loggedUser
            detailsController.parseClient = parseClient
            detailsController.locationText = locationText
            detailsController.linkText = linkText
            detailsController.placemark = searchedPlacemark
            detailsController.loggedUserStudentInformation = loggedUserStudentInformation
        }
    }

    // MARK: Actions

    @IBAction func findLocationOnMap(_ sender: UIButton?) {
        guard let locationText = locationTextField.text, !locationText.isEmpty,
            let linkText = linkTextField.text, !linkText.isEmpty else {
            return
        }

        let mapSearchRequest = MKLocalSearch.Request()
        mapSearchRequest.naturalLanguageQuery = locationText
        if let userLocation = userLocation {
            let userRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
            )
            mapSearchRequest.region = userRegion
        }

        findLocationButton.isEnabled = false

        let localSearch = MKLocalSearch(request: mapSearchRequest)
        localSearch.start { response, error in
            self.findLocationButton.isEnabled = true

            guard error == nil, let response = response, !response.mapItems.isEmpty else {
                self.displayError(withMessage: "Couldn't find the entered location, please, try a more specific term.")
                return
            }

            self.searchedPlacemark = response.mapItems.first!.placemark
            self.performSegue(withIdentifier: self.segueIdentifier, sender: self)
        }
    }

    // MARK: Imperatives

    /// Displays an error alert to the user.
    /// - Parameter message: the error message to be displayed.
    private func displayError(withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "Ok", style: .default) { _ in
                alert.dismiss(animated: true)
            }
        )

        present(alert, animated: true)
    }
}

extension AddLocationViewController {

    // MARK: UITextField delegate methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            linkTextField.becomeFirstResponder()
        } else if textField == linkTextField {
            findLocationOnMap(nil)
            if (textField.text ?? "").isEmpty {
                return false
            }
        }

        textField.resignFirstResponder()
        return true
    }
}
