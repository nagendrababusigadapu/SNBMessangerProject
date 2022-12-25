//
//  StartChat.swift
//  SNBMessanger
//
//  Created by Syamala on 10/07/22.
//

import Foundation
import FirebaseFirestore

//MARK: - Start Chat

func startChat(user1:User, user2:User) -> String {
    
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    
    createRecentItems(chatRoomId: chatRoomId, users: [user1,user2])
    
    return chatRoomId
}

func createRecentItems(chatRoomId: String, users:[User]){
    //does user have recent?
    var memberIdsToCreateRecent = [users.first?.id, users.last?.id]
    
    print("members to create recent is", memberIdsToCreateRecent)
    
    FirebaseReference(.Recent).whereField(KCHATROOMID, isEqualTo: chatRoomId).getDocuments { snapShot, error in
        
        guard let snapShot = snapShot else { return }
        
        memberIdsToCreateRecent = removeMemberWhoHasRecent(snapShot: snapShot, memberIds: memberIdsToCreateRecent)
        
        print("updated members to create recent is", memberIdsToCreateRecent)
        
        for userId in memberIdsToCreateRecent {
            
            print("creating recent for user with id ", userId)
            
            let senderUser = userId == User.currentId ? User.currentUser : getReceiverFrom(users: users)
            
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser?.id ?? "", senderName: senderUser?.userName ?? "", receiverId: receiverUser?.id ?? "", receiverName: receiverUser?.userName ?? "", date: Date(), memberIds: [senderUser?.id ?? "", receiverUser?.id ?? ""], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser?.avatarLink ?? "")
            
            FirebaseRecentListener.shared.addRecent(recentObject)
        }
    }
    
}

func removeMemberWhoHasRecent(snapShot:QuerySnapshot, memberIds: [String?]) -> [String?]{
    
    var memberIdsToCreateRecent = memberIds
    
    for recentData in snapShot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSENDERID] {
            if memberIdsToCreateRecent.contains(currentUserId as? String){
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as? String)!)
            }
        }
    }
    
    return memberIdsToCreateRecent
}

func chatRoomIdFrom(user1Id:String, user2Id:String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue
    
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    
    return chatRoomId
}

/// get receiver 
func getReceiverFrom(users: [User]) -> User {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    return allUsers.first!
}
