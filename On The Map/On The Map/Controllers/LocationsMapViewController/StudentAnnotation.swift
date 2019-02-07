//
//  StudentAnnotation.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 07/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import MapKit

/// Represents a student location on the map.
class StudentAnnotation: NSObject, MKAnnotation {

    // MARK: Properties

    /// The associated student information.
    var studentInformation: StudentInformation

    /// The 2D coordinate of the annotation.
    var coordinate: CLLocationCoordinate2D

    /// The title of the annotation.
    var title: String?

    /// The subtitle of the annotation.
    var subtitle: String?

    // MARK: Initializers

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, studentInformation: StudentInformation) {
        self.coordinate = coordinate
        self.studentInformation = studentInformation

        super.init()

        self.title = title
        self.subtitle = subtitle
    }
}
