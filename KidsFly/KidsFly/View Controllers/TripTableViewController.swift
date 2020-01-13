//
//  TripTableViewController.swift
//  KidsFly
//
//  Created by Craig Swanson on 1/5/20.
//  Copyright © 2020 Craig Swanson. All rights reserved.
//

import UIKit
import CoreData

class TripTableViewController: UITableViewController {

    // MARK: - Properties
    var tripController = TripController()
    var travelerController = TravelerController()
    var kfConnectionController = KFConnectionController()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Trip> = {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.sortDescriptors = [
        NSSortDescriptor(key: "completedStatus", ascending: true),
            NSSortDescriptor(key: "departureTime", ascending: false)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "completedStatus", cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if travelerController.bearer == nil {
            performSegue(withIdentifier: "TravelerSignInSegue", sender: self)
        }
        
        tableView.reloadData()
    }
    
    // Implement pull down to refresh in table view
    // TODO: This does not seem to be working correctly.
    @IBAction func refresh(_ sender: Any) {
        guard let bearer = travelerController.bearer else { return }
        tripController.fetchTripsFromServer(traveler: bearer) { (_) in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        let sectionName = String(sectionInfo.name)
        switch sectionName {
        case "1":
            return "Completed"
        default:
            return "Not Completed"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as? TripTableViewCell else { return UITableViewCell()}
        
        let trip = fetchedResultsController.object(at: indexPath)
        cell.trip = trip

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            let trip = fetchedResultsController.object(at: indexPath)
            tripController.deleteTrip(for: trip)
            tableView.reloadData()
        }
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewTripSegue" {
            guard let newTripVC = segue.destination as? NewTripViewController else { return }
            newTripVC.tripController = tripController
            newTripVC.travelerController = travelerController
            newTripVC.kfConnectionController = kfConnectionController
            newTripVC.bearer = travelerController.bearer
        } else if segue.identifier == "TravelerSignInSegue" {
            guard let travelerSignInVC = segue.destination as? TravelerSignInViewController else { return }
            travelerSignInVC.travelerController = travelerController
            travelerSignInVC.tripController = tripController
            travelerSignInVC.kfConnectionController = kfConnectionController
        } else if segue.identifier == "TripDetailSegue" {
            guard let tripDetailVC = segue.destination as? NewTripViewController else { return }
            tripDetailVC.tripController = tripController
            tripDetailVC.bearer = travelerController.bearer
            tripDetailVC.kfConnectionController = kfConnectionController
            if let indexPath = tableView.indexPathForSelectedRow {
                tripDetailVC.trip = fetchedResultsController.object(at: indexPath)
            }
        }
        
    }

}

// MARK: - FRC Delegate
extension TripTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}
