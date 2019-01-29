//
//  LocationsTabBarController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 29/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The tab bar controller displaying the map and table view controllers.
class LocationsTabBarController: UITabBarController {

    // MARK: Properties

    /// The udacity API client used to log the user out.
    var udacityClient: UdacityAPIClientProtocol!

    /// The Parse API client used to get the most recent student locations.
    var parseClient: ParseAPIClientProtocol!

    /// The logged User information used to post a new location.
    var loggedUser: User!

    // MARK: Imperatives

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert on the dependencies that must be injected.
        precondition(udacityClient != nil)
        precondition(parseClient != nil)
        precondition(loggedUser != nil)

        delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        parseClient.fetchStudentLocations(withLimit: 100, skippingPages: 0) { locations, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.displayError(error!)
                }
                return
            }

            DispatchQueue.main.async {
                guard let mapController = self.viewControllers?.first as? LocationsMapViewController,
                    let tableViewController = self.viewControllers?.last as? LocationsTableViewController else {
                        assertionFailure("Couldn't get the controllers.")
                        return
                }

                mapController.locations = locations
                tableViewController.locations = locations
            }
        }
    }

    // MARK: Imperatives

    /// Displays an error alert to the user.
    /// - Parameters:
    ///     - error: The error to be displayed to the user.
    private func displayError(_ error: APIClient.RequestError) {
        let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        })

        var alertMessage: String?

        switch error {
        case .connection:
            alertMessage = "There's a problem with your internet connection, please, fix it and try again."
        default:
            alertMessage = """
            There was an error while downloading the students' locations, please, contact the app developer.
            """
        }

        alert.message = alertMessage
        present(alert, animated: true)
    }
}

extension LocationsTabBarController: UITabBarControllerDelegate {

    // MARK: Tab bar controller delegate methods

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        title = viewController.title
    }
}
