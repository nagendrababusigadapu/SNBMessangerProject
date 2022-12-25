//
//  StatusTableViewController.swift
//  SNBMessanger
//
//  Created by Syamala on 09/07/22.
//

import UIKit

class StatusTableViewController: UITableViewController {
    
    //MARK:- Vars
    var allStatuses:[String] = []
    
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        loadUserStatus()
    }
    
    private func loadUserStatus(){
        allStatuses = userDefaults.object(forKey: kSTATUS) as! [String]
        tableView.reloadData()
    }
    
    private func updateCellCheck(_ indexPath: IndexPath){
        
        if var user = User.currentUser{
            user.status = allStatuses[indexPath.row]
            saveUserLocally(user)
            FirebaseUserListener.shared.saveUserToFireStore(user)
        }
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStatuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let status = allStatuses[indexPath.row]
        cell.textLabel?.text = status
        
        cell.accessoryType = User.currentUser?.status == status ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateCellCheck(indexPath)
        tableView.reloadData()
    }
}
