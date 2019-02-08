//
//  LocationsTabBarController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 29/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreLocation

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

    /// The location manager used to access the user location, if allowed.
    var locationManager: CLLocationManager!

    // MARK: Imperatives

    deinit {
        unsubscribeFromAllNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Assert on the dependencies that must be injected.
        precondition(udacityClient != nil)
        precondition(parseClient != nil)
        precondition(loggedUser != nil)

        locationManager = CLLocationManager()

        guard let mapsViewController = viewControllers!.first as? LocationsMapViewController,
            let tableViewController = viewControllers!.last as? LocationsTableViewController else {
                preconditionFailure("Couldn't correclty get the child view controllers.")
        }

        mapsViewController.loggedUser = loggedUser
        mapsViewController.parseClient = parseClient
        tableViewController.loggedUser = loggedUser
        tableViewController.parseClient = parseClient

        delegate = self

        subscribeToNotification(
            named: Notification.Name.StudentInformationCreated,
            usingSelector: #selector(displayCreatedLocation(usingNotification:))
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadLocations()

        /// Request authorization to access the location in order to show the user in the map.
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addNewSegueIdentifier {
            if let addLocationController = segue.destination as? AddLocationViewController {
                addLocationController.loggedUser = loggedUser
                addLocationController.parseClient = parseClient
                addLocationController.loggedUserStudentInformation = loggedUserStudentInformation

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

        /// Shows the fetched locations on the main thread.
        /// - Parameter locations: the fetched locations.
        func showFetchedLocationsOnMainThread(_ locations: [StudentInformation]) {
            DispatchQueue.main.async {
                sender?.isEnabled = true
                self.displayStudentLocations(locations)
            }
        }

        parseClient.fetchStudentLocations(withLimit: 100, skippingPages: 0) { locations, error in
            let errorMessage = """
There was an error while downloading the students' locations, please, contact the app developer.
"""

            guard let locations = locations, error == nil else {
                DispatchQueue.main.async {
                    self.displayError(error ?? .malformedJson, withMessage: errorMessage)
                    sender?.isEnabled = true
                }
                return
            }

            if self.loggedUserStudentInformation == nil {
                // Search for the student information of the logged user.Z
                if let loggedUserInformation = locations.filter({ $0.key == self.loggedUser.key }).first {
                    self.loggedUserStudentInformation = loggedUserInformation
                    showFetchedLocationsOnMainThread(locations)
                } else {
                    // Otherwise, try to fetch it, and if successful, display it.
                    _ = self.parseClient.fetchStudentLocation(byUsingUniqueKey: self.loggedUser.key) { information, _ in
                        if let information = information {
                            // Include the fetched information into the other locations and sort them.
                            self.loggedUserStudentInformation = information
                            self.parseClient.studentLocations.append(information)
                            self.parseClient.sortLocations()
                        }

                        showFetchedLocationsOnMainThread(self.parseClient.studentLocations)
                    }
                }
            } else {
                showFetchedLocationsOnMainThread(locations)
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

    // MARK: Notifications

    /// Receives the created student location and updates the map and table views with it.
    /// - Parameter notification: the sent notification.
    @objc private func displayCreatedLocation(usingNotification notification: NSNotification) {
        guard let createdInformation =
            notification.userInfo?[ParseAPIClient.UserInfoKeys.CreatedStudentInformation] as? StudentInformation else {
                preconditionFailure("Coulnd't get the created student information from the notification.")
        }

        self.loggedUserStudentInformation = createdInformation

        // Check if the location already exists. If so, remove it.
        parseClient.studentLocations.removeAll {
            $0.key == createdInformation.key && $0.objectID == createdInformation.objectID
        }
        parseClient.studentLocations.append(createdInformation)
        parseClient.sortLocations()

        displayStudentLocations(parseClient.studentLocations)
    }

    /// Updates the handled controllers to display the passed student locations.
    /// - Parameter locations: the fetched student locations.
    private func displayStudentLocations(_ locations: [StudentInformation]) {
        guard let mapController = self.viewControllers?.first as? LocationsMapViewController,
            let tableViewController = self.viewControllers?.last as? LocationsTableViewController else {
                assertionFailure("Couldn't get the controllers.")
                return
        }

        tableViewController.displayLocations()
        mapController.displayLocations()
    }
}

extension LocationsTabBarController: UITabBarControllerDelegate {

    // MARK: Tab bar controller delegate methods

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        title = viewController.title
    }
}
