//
//  TripListViewController.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 18/08/24.
//

import UIKit

class TripListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tripsTableView: UITableView!
    @IBOutlet weak var emptyDataLbl: UILabel!
    
    var listOfTrip: [Trip] = []
    var searchResults: [Trip] = []
    
    var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }
}


//MARK: - Private Methods
extension TripListViewController {
    
    private func setupView() {
        
        self.title = "List of Trips"
        
        searchBar.delegate = self
        tripsTableView.delegate = self
        tripsTableView.dataSource = self
        tripsTableView.separatorStyle = .none
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func fetchData() {
        listOfTrip = CoreDataMethods.shared.fetchTrips()
        emptyDataLbl.isHidden = !listOfTrip.isEmpty
        tripsTableView.isHidden = listOfTrip.isEmpty
    }
}


//MARK: - SearchBarDelegate
extension TripListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = listOfTrip.filter { $0.title.prefix(searchText.count) == searchText }
        isSearching = true
        tripsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        tripsTableView.reloadData()
    }
}


//MARK: - UITableViewDelegate & UITableViewDataSource
extension TripListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchResults.count : listOfTrip.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TripTableViewCell
        
        let trip = isSearching ? searchResults[indexPath.row] : listOfTrip[indexPath.row]
        cell.selectionStyle = .none
        cell.configureCell(title: trip.title, fromDestination: trip.from, toDestination: trip.to, date: trip.startDateStr)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TripDetailViewController") as! TripDetailViewController
        vc.trip = isSearching ? searchResults[indexPath.row] : listOfTrip[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete Trip", message: "Are you sure you want to delete this trip?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                DispatchQueue.main.async { [self] in
                    CoreDataMethods.shared.deleteTrip(with: listOfTrip[indexPath.row].id)
                    
                    if isSearching {
                        let trip = searchResults.remove(at: indexPath.row)
                        listOfTrip.removeAll { $0.id == trip.id }
                    } else {
                        listOfTrip.remove(at: indexPath.row)
                    }
                    
                    
                    if listOfTrip.isEmpty {
                        emptyDataLbl.isHidden = false
                        tripsTableView.isHidden = true
                    }
                    
                    tripsTableView.reloadData()
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}
