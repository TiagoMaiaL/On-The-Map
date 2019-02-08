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

    /// The reuse identifier of the annotation view.
    private let annotationViewIdentifier = "user annotation"

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

    /// The location posted by the current user, if existent.
    var loggedUserStudentInformation: StudentInformation?

    /// The student information to be posted to the server.
    private lazy var studentInformationToPost: StudentInformation = {
        var studentInformation = makeStudentInformation(
            loggedUser: loggedUser,
            locationText: locationText,
            placemark: placemark,
            linkText: linkText
        )

        if loggedUserStudentInformation != nil {
            studentInformation.objectID = loggedUserStudentInformation?.objectID
        }

        return studentInformation
    }()

    /// The map displaying the chosen location.
    @IBOutlet weak var mapView: MKMapView!

    /// The button to finish creating or loading the locations.
    @IBOutlet weak var finishButton: UIButton!

    /// The tap gesture recognizer added to the selected map annotation view.
    private var selectedViewTapRecognizer: UITapGestureRecognizer?

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(loggedUser != nil)
        precondition(parseClient != nil)
        precondition(locationText != nil)
        precondition(linkText != nil)
        precondition(placemark != nil)

        mapView.delegate = self
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationViewIdentifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Display the map annotation.
        let annotation = StudentAnnotation(
            coordinate: placemark.coordinate,
            title: locationText,
            subtitle: linkText,
            studentInformation: studentInformationToPost
        )
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
        let completionHandler: (StudentInformation?, APIClient.RequestError?) -> Void = { information, error in
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

        // Update or create the informed location values.
        (loggedUserStudentInformation != nil ? parseClient.updateStudentLocation : parseClient.createStudentLocation)(
            studentInformationToPost,
            completionHandler
        )
    }

    /// Called when the details view of the annotation view is tapped. This opens the browser with the specified link.
    @objc private func openDefaultBrowser(_ sender: UITapGestureRecognizer?) {
        UIApplication.shared.openDefaultBrowser(accessingAddress: studentInformationToPost.mediaUrl.absoluteString)
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
        guard let urlString = linkText.replacingOccurrences(
            of: " ",
            with: "+"
            ).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                preconditionFailure("Couldn't configure the provided url string.")
        }

        return StudentInformation(
            firstName: loggedUser.firstName,
            lastName: loggedUser.lastName,
            latitude: placemark.coordinate.latitude,
            longitude: placemark.coordinate.longitude, mapTextReference: locationText,
            mediaUrl: URL(string: urlString)!,
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

extension StudentLocationDetailsViewController: MKMapViewDelegate {

    // MARK: Map view delegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationView(
            withIdentifier: annotationViewIdentifier,
            for: annotation
        ) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
        }

        annotationView.displayPriority = .required
        annotationView.pinTintColor = Colors.UserLocationMarkerColor
        annotationView.canShowCallout = true

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openDefaultBrowser(_:)))
        view.addGestureRecognizer(self.selectedViewTapRecognizer!)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(self.selectedViewTapRecognizer!)
    }
}
