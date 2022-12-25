//
//  FirebaseRecentListener.swift
//  SNBMessanger
//
//  Created by Syamala on 10/07/22.
//

import Foundation
import Firebase

class FirebaseRecentListener{
    
    static let shared = FirebaseRecentListener()
    
    private init(){}
    
    func addRecent(_ recent:RecentChat){
        
        do{
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }catch{
            print("Error saving recent chat:",error.localizedDescription)
        }
        
        
    }
    
    func downloadRecentChatFromFireStore(completion: @escaping (_ allRecents:[RecentChat]) -> Void){
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { snapShot, error in
            
            var recentChats: [RecentChat] = []
            
            guard let documents = snapShot?.documents else {
                print("No documents for recent chats")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapShot) -> RecentChat? in
                return try? queryDocumentSnapShot.data(as: RecentChat.self)
            }
            
            for recent in allRecents{
                if !recent.lastMessage.isEmpty{
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: {$0.date! > $1.date! })
            completion(recentChats)
        }
    }
    
}


