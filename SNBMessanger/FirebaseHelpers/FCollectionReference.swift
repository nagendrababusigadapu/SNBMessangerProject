//
//  FCollectionReference.swift
//  SNBMessanger
//
//  Created by Nagendra Babu on 06/02/21.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
}

func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
