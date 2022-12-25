//
//  ChatsTableViewController.swift
//  SNBMessanger
//
//  Created by Syamala on 11/07/22.
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    //MARK: - vars
    
    var allRecentChats:[RecentChat] = []
    var filteredRecentChats:[RecentChat] = []
    
    let searchController = UISearchController(searchResultsController: nil)

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        setupSearchController()
        downloadRecentChats()
    }
    
    private func configTableView(){
        tableView.tableFooterView = UIView()
    }
    
    private func downloadRecentChats(){
        FirebaseRecentListener.shared.downloadRecentChatFromFireStore { (allChats) in
            self.allRecentChats = allChats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupSearchController(){
     
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filterContentForSearchText(searchText:String){
        
        filteredRecentChats = allRecentChats.filter({ (recent) -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredRecentChats.count : allRecentChats.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? RecentTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(recent: searchController.isActive ? filteredRecentChats[indexPath.row] : allRecentChats[indexPath.row])
        
        return cell
    }
}

//MARK: - Search controller delegate

extension ChatsTableViewController :UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text ?? "")
    }
}
