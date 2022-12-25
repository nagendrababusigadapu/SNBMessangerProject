//
//  ProfileTableViewController.swift
//  SNBMessanger
//
//  Created by Syamala on 10/07/22.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: - Vars
    
    var user:User?
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        updateUI()
    }
    
    private func updateUI(){
        if user != nil{
            self.title = user?.userName
            userNameLabel.text = user?.userName
            statusLabel.text = user?.status
            if user?.avatarLink != nil{
                FileStorage.downloadImage(imageUrl: user?.avatarLink ?? "") { image in
                    DispatchQueue.main.async {
                        self.avatarImageView.image = image?.circleMasked
                    }
                }
            }
            
        }
        
    }
   
}
//MARK: - Tableview Delegates

extension ProfileTableViewController{
    
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
        
        if indexPath.section == 1 {
            
            guard let user = user else { return }
            
            let chatId = startChat(user1: User.currentUser!, user2: user)
            print("======================================")
            print("Start chatting chatroom id is:", chatId)
            print("======================================")
        }
    }
}
