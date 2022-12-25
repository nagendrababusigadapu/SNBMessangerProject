//
//  FirebaseUserListeners.swift
//  SNBMessanger
//
//  Created by Nagendra Babu on 06/02/21.
//

import Foundation
import Firebase
import RealmSwift
import FirebaseFirestore


class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init(){}
    
    //MARK:- Login
    
    func loginUserWithEmail(email:String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified:Bool) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil && authDataResult!.user.isEmailVerified {
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
            }else{
                print("Email is not verified.")
                completion(error, false)
            }
        }
        
    }
    
    
    //MARK:- Register
    
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                
                //send verification email
                authDataResult?.user.sendEmailVerification(completion: { (error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                })
                
                //create user and save it
                
                if authDataResult?.user != nil {
                    
                    let user = User(id: authDataResult!.user.uid, userName: email, email: email, pushID: "", avatarLink: "", status: "Hey, I am an IOS Developer!")
                    
                    saveUserLocally(user)
                    self.saveUserToFireStore(user)
                }
                
            }
        }
    }
    
    
    //MARK::- Resend Verification link
    
    func resendVerificationLinkWith(email:String, completion: @escaping (_ error: Error?) -> Void){
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error)
            })
        })
        
    }
    
    //MARK:- reset the password
    
    func resetPasswordFor(email:String, completion: @escaping (_ error: Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    //MARK:- Logout the user
    
    func logoutCurrentUser(completion: @escaping (_ error: Error?) -> Void){
        
        do{
            try Auth.auth().signOut()
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
        }catch let error as NSError{
            print("Error while logging out \(error.localizedDescription)")
            completion(error)
        }
        
    }
    
    //MARK:- save user on Firebase
    
    func saveUserToFireStore(_ user: User){
        
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        }catch{
            print(error.localizedDescription, "adding user")
        }
    }
    
    //MARK:- download user from firebase
    
    func downloadUserFromFirebase(userId: String, email: String? = nil){
        
        FirebaseReference(.User).document(userId).getDocument { (snapShot, error) in
            
            guard let document = snapShot else {
                print("No user document")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result{
            
            case .success(let userObject):
                
                if let user = userObject {
                    saveUserLocally(user)
                }else{
                    print("document doesn't exist")
                }
                
            case .failure(let error):
                print("Error decoding user :\(error.localizedDescription)")
                
            }
        }
        
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers:[User]) -> Void){
        
        var users:[User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { querySnapShot, error in
            guard let documents = querySnapShot?.documents else {
                print("No Documents in all users")
                return
            }
            
            let allUsers = documents.compactMap{ (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            for user in allUsers {
                //this check is for not to add current user as allUser includes current user also (means logged in user )
                if User.currentId != user.id{
                    users.append(user)
                }
            }
            
            completion(users)
        }
        
    }
    
    /// download multiple users from firebase 
    
    func downloadUsersFromFirebase(withIds:[String], completion: @escaping (_ allUsers:[User]) -> Void){
        
        var count = 0
        var usersArray:[User] = []
        
        for userId in withIds {
            FirebaseReference(.User).document(userId).getDocument { (querySnapShot, error) in
                
                guard let document = querySnapShot else {
                    print("No user document")
                    return
                }
                
                guard let user = try? document.data(as: User.self) else {
                    return
                }
                
                usersArray.append(user)
                count += 1
                
                if count == withIds.count{
                    completion(usersArray)
                }
                
            }
        }
    }
    
}
