//
//  LocationsTableViewController.swift
//  On The Map
//
//  Created by Tiago Maia Lopes on 29/01/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// The controller displaying the locations of the students in a table view.
class LocationsTableViewController: UITableViewController {

    // MARK: Properties

    /// The location cell identifier used in this controller.
    private let locationCellIdentifier = "locationCell"

    /// The parse client in charge of retrieving the students locations.
    var parseClient: ParseAPIClientProtocol!

    /// The currently logged user.
    var loggedUser: User!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(parseClient != nil)
        precondition(loggedUser != nil)
    }

    // MARK: Imperatives

    /// Displays the locations in the table view.
    func displayLocations() {
        tableView.reloadData()
    }

    // MARK: Table view data source methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClient.studentLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath)

        let currentLocation = parseClient.studentLocations[indexPath.row]

        if currentLocation.key == loggedUser.key {
            cell.backgroundColor = Colors.UserLocationCellColor
        } else {
            cell.backgroundColor = .white
        }

        cell.textLabel?.text = "\(currentLocation.firstName) \(currentLocation.lastName)"
        cell.detailTextLabel?.text = currentLocation.mediaUrl.absoluteString

        return cell
    }

    // MARK: Table view delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentLocation = parseClient.studentLocations[indexPath.row]
        UIApplication.shared.openDefaultBrowser(accessingAddress: currentLocation.mediaUrl.absoluteString)
    }
}
