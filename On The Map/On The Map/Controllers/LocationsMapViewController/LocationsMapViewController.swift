//
//  LocationsMapViewController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 29/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import MapKit

/// The controller displaying the students' locations in the map view.
class LocationsMapViewController: UIViewController {

    // MARK: Properties

    /// The reuse identifier of the annotation views used on the map.
    let annotationViewReuseIdentifier = "annotation view ID"

    /// The students' locations to be displayed on the map.
    var locations: [StudentInformation]? {
        didSet {
            if let locations = locations {
                displayLocations(locations)
            }
        }
    }

    /// The map displaying each location of each student.
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
    }

    // MARK: Imperatives

    /// Displays the locations on the map.
    /// - Parameters:
    ///     - locations: the locations to be displayed on the map.
    private func displayLocations(_ locations: [StudentInformation]) {
        mapView.addAnnotations(locations.compactMap {
            StudentAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                title: "\($0.firstName) \($0.lastName)",
                subtitle: $0.mediaUrl.absoluteString
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
        var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationView(
            withIdentifier: annotationViewReuseIdentifier
        ) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(
                annotation: annotation,
                reuseIdentifier: annotationViewReuseIdentifier
            )
        }

        annotationView.canShowCallout = true
        annotationView.displayPriority = .required

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? StudentAnnotation,
         let link = annotation.subtitle else {
            assertionFailure("The annotation must be of the student annotation type and also have a valid link.")
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

/// Represents a student location on the map.
private class StudentAnnotation: NSObject, MKAnnotation {

    // MARK: Properties

    /// The 2D coordinate of the annotation.
    var coordinate: CLLocationCoordinate2D

    /// The title of the annotation.
    var title: String?

    /// The subtitle of the annotation.
    var subtitle: String?

    // MARK: Initializers

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate

        // TODO: Why does the init have to be called after?
        super.init()

        self.title = title
        self.subtitle = subtitle
    }
}
