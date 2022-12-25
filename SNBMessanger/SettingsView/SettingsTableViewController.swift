//
//  SettingsTableViewController.swift
//  SNBMessanger
//
//  Created by opasa on 01/03/21.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    //MARK:- IBActions
    
    
    @IBAction func tellaFriendBtnPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func termsAndConditionsPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        FirebaseUserListener.shared.logoutCurrentUser { (error) in
            if error == nil{
                let loginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController")
                DispatchQueue.main.async {
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true, completion: nil)
                }
                
            }else{
                
            }
        }
    }
    
    //MARK:- update UI
    
    private func showUserInfo(){
        
        if let user = User.currentUser {
            
            userNameLabel.text = user.userName
            statusLabel.text = user.status
            appVersionLabel.text = "App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            if user.avatarLink != nil {
                //download and set avtar image
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    self.userProfileImageView.image = avatarImage?.circleMasked
                }
            }
            
            
        }
    }
}

//MARK:- Tableview Delegate

extension SettingsTableViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.0 : 10.0
    }
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0{
            performSegue(withIdentifier: EDITPROFILE, sender: self)
        }
    }
}
