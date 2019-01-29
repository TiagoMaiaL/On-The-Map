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

    /// The students' locations to be displayed on the map.
    var locations: [StudentInformation]?

    /// The map displaying each location of each student.
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
}
