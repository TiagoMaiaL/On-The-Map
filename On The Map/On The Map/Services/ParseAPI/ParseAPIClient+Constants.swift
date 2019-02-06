//
//  ParseAPIClient+Constants.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 28/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension ParseAPIClient {

    /// The constants used to generate an url to access a resource in the API.
    enum API {
        static let Scheme = "https"
        static let Host = "parse.udacity.com"
        static let Path = "/parse/classes"
    }

    /// The methods used in the API.
    enum Methods {
        static let StudentLocation = "StudentLocation"
    }

    /// The keys of the parameters sent in the requests.
    enum ParameterKeys {
        static let Limit = "limit"
        static let Page = "skip"
        static let WhereQuery = "where"
    }

    /// The keys of the json returned in the responses.
    enum JSONResponseKeys {
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapTextReference = "mapString"
        static let MediaUrl = "mediaURL"
        static let InformationKey = "uniqueKey"
        static let ObjectID = "objectId"
    }

    /// The keys of the user info that comes with the notifications sent in the notification center.
    enum UserInfoKeys {
        static let CreatedStudentInformation = "created_information"
    }
}

extension NSNotification.Name {
    static let StudentInformationCreated = NSNotification.Name("student_notification_created")
}
