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

    /// The identifier of the segue that takes the user to the controller to add a new location.
    private let addNewSegueIdentifier = "show controller to add a new segue"

    /// The udacity API client used to log the user out.
    var udacityClient: UdacityAPIClientProtocol!

    /// The Parse API client used to get the most recent student locations.
    var parseClient: ParseAPIClientProtocol!

    /// The logged User information used to post a new location.
    var loggedUser: User!

    /// The student information of the currently logged user.
    var loggedUserStudentInformation: StudentInformation?

    // MARK: Imperatives

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert on the dependencies that must be injected.
        precondition(udacityClient != nil)
        precondition(parseClient != nil)
        precondition(loggedUser != nil)

        guard let mapsViewController = viewControllers!.first as? LocationsMapViewController,
            let tableViewController = viewControllers!.last as? LocationsTableViewController else {
                preconditionFailure("Couldn't correclty get the child view controllers.")
        }

        mapsViewController.loggedUser = loggedUser
        tableViewController.loggedUser = loggedUser

        delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadLocations()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addNewSegueIdentifier {
            if let addLocationController = segue.destination as? AddLocationViewController {
                addLocationController.loggedUser = loggedUser
                addLocationController.parseClient = parseClient

                if let mapController = viewControllers?.first as? LocationsMapViewController {
                    addLocationController.userLocation = mapController.mapView.userLocation
                }
            }
        }
    }

    // MARK: Actions

    /// Loads the most recent student locations.
    @IBAction func loadLocations(_ sender: UIBarButtonItem? = nil) {
        sender?.isEnabled = false

        parseClient.fetchStudentLocations(withLimit: 100, skippingPages: 0) { locations, error in

            /// Updates the handled controllers to show the passed student locations.
            /// - Parameter locations: the fetched student locations.
            func displayStudentLocations(_ locations: [StudentInformation]) {
                DispatchQueue.main.async {
                    guard let mapController = self.viewControllers?.first as? LocationsMapViewController,
                        let tableViewController = self.viewControllers?.last as? LocationsTableViewController else {
                            assertionFailure("Couldn't get the controllers.")
                            return
                    }

                    mapController.locations = locations
                    tableViewController.locations = locations

                    sender?.isEnabled = true
                }
            }

            let errorMessage = """
There was an error while downloading the students' locations, please, contact the app developer.
"""

            guard var locations = locations, error == nil else {
                DispatchQueue.main.async {
                    self.displayError(error ?? .malformedJson, withMessage: errorMessage)
                }
                sender?.isEnabled = true
                return
            }

            if let loggedUserInformation = self.loggedUserStudentInformation ??
                locations.filter({ $0.key == self.loggedUser.key }).first {
                // Try to search for the logged user's location, if one wasn't already set.
                if let index = locations.firstIndex(of: loggedUserInformation) {
                    locations.insert(locations.remove(at: index), at: 0)
                } else {
                    locations.insert(loggedUserInformation, at: 0)
                }

                displayStudentLocations(locations)
            } else {
                // Otherwise, try to fetch it, and if successful, display it.
                _ = self.parseClient.fetchStudentLocation(byUsingUniqueKey: self.loggedUser.key) { information, _ in
                    if information != nil {
                        self.loggedUserStudentInformation = information
                        locations.insert(information!, at: 0)
                    }

                    displayStudentLocations(locations)
                }
            }
        }
    }

    /// Logs the user out of the application.
    @IBAction func logUserOut(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        udacityClient.logOut { isSuccessful, error in
            guard isSuccessful, error == nil else {
                DispatchQueue.main.async {
                    self.displayError(
                        error!,
                        withMessage: "There was an error while logging out. Please, try again later. "
                    )
                    sender.isEnabled = true
                }
                return
            }

            DispatchQueue.main.async {
                self.dismiss(animated: true)
                sender.isEnabled = true
            }
        }
    }

    // MARK: Imperatives

    /// Displays an error alert to the user.
    /// - Parameters:
    ///     - error: The error to be displayed to the user.
    private func displayError(_ error: APIClient.RequestError, withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        })

        var alertMessage: String?

        switch error {
        case .connection:
            alertMessage = "There's a problem with your internet connection, please, fix it and try again."
        default:
            alertMessage = message
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
