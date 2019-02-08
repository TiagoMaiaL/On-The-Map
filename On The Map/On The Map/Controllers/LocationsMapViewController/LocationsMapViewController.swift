//
//  LocationsMapViewController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 29/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/// The controller displaying the students' locations in the map view.
class LocationsMapViewController: UIViewController {

    // MARK: Properties

    /// The reuse identifier of the annotation views used on the map.
    let annotationViewReuseIdentifier = "annotation view ID"

    /// The parse client used to retrieve the students locations.
    var parseClient: ParseAPIClientProtocol!

    /// The currently logged user.
    var loggedUser: User!

    /// The map displaying each location of each student.
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(parseClient != nil)
        precondition(loggedUser != nil)

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }

    // MARK: Imperatives

    /// Displays the locations on the map.
    func displayLocations() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(parseClient.studentLocations.compactMap {
            StudentAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                title: "\($0.firstName) \($0.lastName)",
                subtitle: $0.mediaUrl.absoluteString,
                studentInformation: $0
            )
        })
    }

    // MARK: Actions

    /// Displays the link found in the selected annotation.
    /// - Parameter sender: The tap gesture recognizer firing the action.
    @objc private func displayPostedLink(_ sender: AnnotationLinkTapRecognizer?) {
        guard let urlText = sender?.link else {
            assertionFailure("The link of the tap recognizer must be set.")
            return
        }

        UIApplication.shared.openDefaultBrowser(accessingAddress: urlText)
    }
}

extension LocationsMapViewController: MKMapViewDelegate {

    // MARK: MKMapView delegate methods

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let studentAnnotation = annotation as? StudentAnnotation else {
            return nil
        }

        var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationView(
            withIdentifier: annotationViewReuseIdentifier
        ) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(
                annotation: studentAnnotation,
                reuseIdentifier: annotationViewReuseIdentifier
            )
        }

        if studentAnnotation.studentInformation.key == loggedUser.key {
            annotationView.pinTintColor = Colors.UserLocationMarkerColor
        } else {
            annotationView.pinTintColor = .red
        }

        annotationView.canShowCallout = true
        annotationView.displayPriority = .required

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let studentAnnotation = view.annotation as? StudentAnnotation else {
            return
        }

        guard let link = studentAnnotation.subtitle else {
            assertionFailure("The annotation must have a valid link.")
            return
        }

        let tapRecognizer = AnnotationLinkTapRecognizer(
            target: self,
            action: #selector(displayPostedLink(_:)),
            link: link
        )
        view.addGestureRecognizer(tapRecognizer)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let recognizer = view.gestureRecognizers?.filter({ $0 is AnnotationLinkTapRecognizer }).first {
            view.removeGestureRecognizer(recognizer)
        }
    }
}
