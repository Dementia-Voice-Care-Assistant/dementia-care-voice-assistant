//
//  FirestoreManager.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/20/24.
//

import Foundation
import FirebaseFirestore
import Firebase

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    let db = Firestore.firestore()
    private init() {}
    
    // methods for reading and writing data
    
    // TesterMethods
    func addData(data: String) {
        let dataToSave: [String: Any] = ["text": data]
        db.collection("testingCollection").addDocument(data: dataToSave) { error in
            if let error = error {
                print("Error adding document: \(error)")
            }
            else {
                print("Document added successfully")
            }
        }
    }
    func fetchData(completion: @escaping ([String]) -> Void) {
        db.collection("testingCollection").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents \(error)")
                completion([])
            } else {
                let items = querySnapshot!.documents.compactMap { document -> String? in
                    return document.data()["text"] as? String
                }
                completion(items)
            }
        }
        
        
    }
    
}
