//
//  StudentLocationDetailsViewController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 31/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import MapKit

/// The controller displaying the student location on the map.
class StudentLocationDetailsViewController: UIViewController {

    // MARK: Parameters

    /// The currently logged in user.
    var loggedUser: User!

    /// The parse API client used to create or update the user's location.
    var parseClient: ParseAPIClientProtocol!

    /// The location text of the student information to be created or updated in the server.
    var locationText: String!

    /// The link text of the student information to be created or updated in the server.
    var linkText: String!

    /// The placemark searched by the user.
    var placemark: MKPlacemark!

    /// The student information to be posted to the server.
    private lazy var studentInformationToPost = {
        return makeStudentInformation(
            loggedUser: loggedUser,
            locationText: locationText,
            placemark: placemark,
            linkText: linkText
        )
    }()

    /// The map displaying the chosen location.
    @IBOutlet weak var mapView: MKMapView!

    /// The button to finish creating or loading the locations.
    @IBOutlet weak var finishButton: UIButton!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(loggedUser != nil)
        precondition(parseClient != nil)
        precondition(locationText != nil)
        precondition(linkText != nil)
        precondition(placemark != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Display the map annotation.
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = annotation.coordinate
        mapView.setRegion(
            MKCoordinateRegion(
                center: annotation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            ),
            animated: true
        )
    }

    // MARK: Actions

    @IBAction func createOrUpdateLocation(_ sender: UIButton) {
        parseClient.createStudentLocation(studentInformationToPost) { information, error in
            guard error == nil, let information = information else {
                DispatchQueue.main.async {
                    self.displayError(
                        "There was an error while sending the student information to the server, please, try again."
                    )
                }
                return
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name.StudentInformationCreated,
                    object: self,
                    userInfo: [ParseAPIClient.UserInfoKeys.CreatedStudentInformation: information]
                )
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    // MARK: Imperatives

    /// Creates and configures the student information struct from the passed data.
    /// - Parameters:
    ///     - loggedUser: the currently logged user.
    ///     - locationText: the text location text.
    ///     - placemark: the placemark associated with the searched location.
    ///     - linkText: the link to be posted.
    private func makeStudentInformation(
        loggedUser: User,
        locationText: String,
        placemark: MKPlacemark,
        linkText: String
        ) -> StudentInformation {
        return StudentInformation(
            firstName: loggedUser.firstName,
            lastName: loggedUser.lastName,
            latitude: placemark.coordinate.latitude,
            longitude: placemark.coordinate.longitude, mapTextReference: locationText,
            mediaUrl: URL(string: linkText)!,
            key: loggedUser.key
        )
    }

    /// Displays the an error to the user.
    /// - Parameter error: the error
    private func displayError(_ errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }
}
