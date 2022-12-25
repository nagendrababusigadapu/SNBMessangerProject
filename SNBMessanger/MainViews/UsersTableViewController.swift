//
//  UsersTableViewController.swift
//  SNBMessanger
//
//  Created by Syamala on 09/07/22.
//

import UIKit
import RealmSwift

class UsersTableViewController: UITableViewController {
    
    //MARK: - Vars
    
    var allUsers:[User] = []
    var filteredUsers:[User] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
        setupSearchController()
        //createDummyUsers()
        downloadUsers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configTableView(){
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
    }
    
    private func downloadUsers(){
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { allFirebaseUsers in
            self.allUsers = allFirebaseUsers
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
        
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.userName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    private func showUserProfile(user:User){
        
        guard let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: USER_PROFILE_SCREEN) as? ProfileTableViewController else {
            return
        }
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if self.refreshControl!.isRefreshing{
            self.downloadUsers()
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        cell.configure(user: user)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        self.showUserProfile(user: user)
        
    }
    
}

//MARK: - UISearchBarDelegate

extension UsersTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text ?? "")
    }
}
