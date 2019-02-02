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
        // TODO: Send the post or put request.
        navigationController?.popToRootViewController(animated: true)
    }
}
