//
//  User.swift
//  SNBMessanger
//
//  Created by Nagendra Babu on 03/02/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import UIKit


struct User: Codable, Equatable {
    
    var id = ""
    var userName:String
    var email: String
    var pushID = ""
    var avatarLink = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        
        if Auth.auth().currentUser != nil{
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER){
                let decoder = JSONDecoder()
                do{
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}


func saveUserLocally(_ user: User){
    
    //save into userdefaults
    
    let encoder = JSONEncoder()
    
    do{
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    }catch{
        print("error saving user locally: \(error.localizedDescription)")
    }
    
}

func createDummyUsers(){
    
    let names = ["Tom Cruise","Tom Hardy", "Lokesh Kanagaraj", "Kamal Haasan", "Surya", "Karthi"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<6{
        
        let id = UUID().uuidString
        
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = User(id: id, userName: names[i], email: "user\(userIndex)@yopmail.com", pushID: "", avatarLink: avatarLink, status: "No Status")
            
            userIndex += 1
            FirebaseUserListener.shared.saveUserToFireStore(user)
        }
        
        imageIndex += 1
    }
}
