//
//  StudentInformation.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 28/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// A struct representing the information posted by the student.
struct StudentInformation {

    // MARK: Properties

    /// The first name of the student.
    let firstName: String

    /// The last name of the student.
    let lastName: String

    /// The latitude the user chose for the pin.
    let latitude: Double

    /// The longitude the user chose for the pin.
    let longitude: Double

    /// The string referencing the pin on the map.
    let mapTextReference: String

    /// The media url.
    let mediaUrl: URL

    /// The information key.
    let key: String

    // MARK: Initializers

    init(firstName: String,
         lastName: String,
         latitude: Double,
         longitude: Double,
         mapTextReference: String,
         mediaUrl: URL,
         key: String
        ) {
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapTextReference = mapTextReference
        self.mediaUrl = mediaUrl
        self.key = key
    }

    init?(informationData: [String: AnyObject]) {
        guard let firstName = informationData[ParseAPIClient.JSONResponseKeys.FirstName] as? String else {
            return nil
        }

        guard let lastName = informationData[ParseAPIClient.JSONResponseKeys.LastName] as? String else {
            return nil
        }

        guard let latitude = informationData[ParseAPIClient.JSONResponseKeys.Latitude] as? Double else {
            return nil
        }

        guard let longitude = informationData[ParseAPIClient.JSONResponseKeys.Longitude] as? Double else {
            return nil
        }

        guard let mapTextReference = informationData[ParseAPIClient.JSONResponseKeys.MapTextReference] as? String  else {
            return nil
        }

        guard let mediaUrlText = informationData[ParseAPIClient.JSONResponseKeys.MediaUrl] as? String,
            let mediaUrl = URL(string: mediaUrlText) else {
            return nil
        }

        guard let key = informationData[ParseAPIClient.JSONResponseKeys.InformationKey] as? String else {
            return nil
        }

        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapTextReference = mapTextReference
        self.mediaUrl = mediaUrl
        self.key = key
    }
}
