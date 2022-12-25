//
//  EditProfileTableViewController.swift
//  SNBMessanger
//
//  Created by opasa on 17/03/21.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var avtarImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK:- Properties
    
    var gallery:GalleryController!
    
    
    //MARK:- ViewLifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
       tableView.tableFooterView = UIView()
        
        configureTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    //MARK:- IBActions
    
    @IBAction func editBtnPressed(_ sender: Any) {
        showImageGallery()
    }
    
    
    //MARK:- update UI
    
    private func showUserInfo(){
        
        if let user = User.currentUser {
            
            userNameTextField.text = user.userName
            statusLabel.text = user.status
            
            if user.avatarLink != nil{
                FileStorage.downloadImage(imageUrl: user.avatarLink) { image in
                    self.avtarImageView.image = image?.circleMasked
                }
            }
        }
    }
    
    private func configureTextField(){
        userNameTextField.delegate = self
        userNameTextField.clearButtonMode = .whileEditing
    }
    
    private func showImageGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(self.gallery, animated: true, completion: nil)
    }
    
    private func uploadAvtarImage(image:UIImage){
        
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { avtarLink in
            
            if var user = User.currentUser {
                user.avatarLink = avtarLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFireStore(user)
            }
            
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
        
    }
    
    //MARK:- Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.0 : 30.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0{
            performSegue(withIdentifier: "editProfileToStatusSeg", sender: self)
        }
    }
}

//MARK:- UITextField Delegate

extension EditProfileTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            if textField.text != "" {
                if var user = User.currentUser {
                    user.userName = textField.text!
                    saveUserLocally(user)
                    FirebaseUserListener.shared.saveUserToFireStore(user)
                }
            }
            
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
}

//MARK:- Gallery Delegate

extension EditProfileTableViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (avtarImage) in
                if avtarImage != nil {
                    self.uploadAvtarImage(image: avtarImage!)
                    self.avtarImageView.image = avtarImage?.circleMasked
                }else{
                    ProgressHUD.showError("Couldn't select image!")
                }
                
                
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
}
