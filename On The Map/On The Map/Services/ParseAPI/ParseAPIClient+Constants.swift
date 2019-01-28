//
//  ParseAPIClient+Constants.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 28/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension ParseAPIClient {

    /// The keys of the json returned in the responses.
    enum JSONResponseKeys {
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapTextReference = "mapString"
        static let MediaUrl = "mediaURL"
    }
}
