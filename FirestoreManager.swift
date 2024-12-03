//
//  FirestoreManager.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/20/24.
//

import Foundation
import FirebaseFirestore
import Firebase

struct ChatSession: Identifiable {
    var id: String
    var messages: [ChatMessage]
    var timestamp: Timestamp
}

struct ChatMessage: Identifiable {
    var id = UUID() // Unique identifier for each message
    var sender: String
    var text: String
    var timestamp: Timestamp

    func toDictionary() -> [String: Any] {
        return [
            "sender": sender,
            "text": text,
            "timestamp": timestamp
        ]
    }
}

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    let db: Firestore

    init() {
        db = Firestore.firestore()
    }

    // MARK: - User Data Functions
    func createUserDocument(userId: String, name: String, email: String, completion: @escaping (Error?) -> Void) {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "chatHistory": []
        ]
        db.collection("users").document(userId).setData(userData) { error in
            completion(error)
        }
    }

    // MARK: - Chat Functions
    func startNewChatSession(userId: String, initialMessage: ChatMessage, completion: @escaping (ChatSession?, Error?) -> Void) {
        let chatId = UUID().uuidString
        let chatRef = db.collection("users").document(userId).collection("chatHistory").document(chatId)

        let sessionData: [String: Any] = [
            "timestamp": initialMessage.timestamp,
            "messages": [initialMessage.toDictionary()]
        ]

        chatRef.setData(sessionData) { error in
            if let error = error {
                completion(nil, error)
            } else {
                let newSession = ChatSession(id: chatId, messages: [initialMessage], timestamp: initialMessage.timestamp)
                completion(newSession, nil)
            }
        }
    }

    func addMessageToChat(userId: String, chatId: String, message: ChatMessage, completion: @escaping (Error?) -> Void) {
        let chatRef = db.collection("users").document(userId).collection("chatHistory").document(chatId)

        chatRef.updateData([
            "messages": FieldValue.arrayUnion([message.toDictionary()])
        ], completion: completion)
    }

    func fetchChatHistory(userId: String, completion: @escaping ([ChatSession]?, Error?) -> Void) {
        db.collection("users").document(userId).collection("chatHistory")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    let sessions = snapshot?.documents.compactMap { doc -> ChatSession? in
                        guard let messagesData = doc.data()["messages"] as? [[String: Any]] else { return nil }
                        let messages = messagesData.compactMap { dict in
                            ChatMessage(
                                sender: dict["sender"] as? String ?? "",
                                text: dict["text"] as? String ?? "",
                                timestamp: dict["timestamp"] as? Timestamp ?? Timestamp(date: Date())
                            )
                        }
                        let timestamp = doc.data()["timestamp"] as? Timestamp ?? Timestamp(date: Date())
                        return ChatSession(id: doc.documentID, messages: messages, timestamp: timestamp)
                    }
                    completion(sessions, nil)
                }
            }
    }
}
