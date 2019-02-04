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

    /// The locations to be displayed.
    var locations: [StudentInformation]? {
        didSet {
            if locations != nil {
                self.tableView?.reloadData()
            }
        }
    }

    /// The currently logged user.
    var loggedUser: User!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(loggedUser != nil)
    }

    // MARK: Table view data source methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath)

        guard let currentLocation = locations?[indexPath.row] else {
            assertionFailure("The location must be successfully retrieved.")
            return cell
        }

        if currentLocation.key == loggedUser.key {
            cell.backgroundColor = .red
        } else {
            cell.backgroundColor = .white
        }

        cell.textLabel?.text = "\(currentLocation.firstName) \(currentLocation.lastName)"
        cell.detailTextLabel?.text = currentLocation.mediaUrl.absoluteString

        return cell
    }

    // MARK: Table view delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentLocation = locations?[indexPath.row] else {
            assertionFailure("The locations must be set in order to receive row touches.")
            return
        }

        UIApplication.shared.openDefaultBrowser(accessingAddress: currentLocation.mediaUrl.absoluteString)
    }
}
