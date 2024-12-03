import FirebaseFirestore

struct ChatSession: Identifiable {
    var id: String
    var messages: [ChatMessage]
    var timestamp: Timestamp
    var title: String
}

struct ChatMessage: Identifiable {
    var id = UUID()
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

class FirestoreChatManager: ObservableObject {
    static let shared = FirestoreChatManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Fetch Chat History
    func fetchChatHistory(userId: String, completion: @escaping ([ChatSession]?, Error?) -> Void) {
        db.collection("users").document(userId).collection("chatHistory")
            .order(by: "timestamp", descending: true)
            .getDocuments { document, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    let sessions = document?.documents.compactMap { doc -> ChatSession? in
                        let data = doc.data()
                        guard let msgData = data["messages"] as? [[String: Any]],
                              let timestamp = data["timestamp"] as? Timestamp else { return nil }
                        
                        let messages = msgData.compactMap { dict -> ChatMessage? in
                            guard let sender = dict["sender"] as? String,
                                  let text = dict["text"] as? String,
                                  let timestamp = dict["timestamp"] as? Timestamp else { return nil }
                            return ChatMessage(sender: sender, text: text, timestamp: timestamp)
                        }
                        let title = String(messages.first?.text.prefix(20) ?? "New Chat")
                        
                        return ChatSession(id: doc.documentID, messages: messages, timestamp: timestamp, title: title)
                    }
                    completion(sessions, nil)
                }
            }
    }
    
    // MARK: - Start New Chat Session
    func startNewChatSession(userId: String, initialMessage: ChatMessage, completion: @escaping (ChatSession?, Error?) -> Void) {
        let chatId = UUID().uuidString
        let title = String(initialMessage.text.prefix(20))
        let collectionRef = db.collection("users").document(userId).collection("chatHistory").document(chatId)
        
        let sessionData: [String: Any] = [
            "timestamp": initialMessage.timestamp,
            "messages": [initialMessage.toDictionary()]
        ]
        
        collectionRef.setData(sessionData) { error in
            if let error = error {
                completion(nil, error)
            } else {
                let newSessionRef = ChatSession(
                    id: chatId,
                    messages: [initialMessage],
                    timestamp: initialMessage.timestamp,
                    title: title)
                completion(newSessionRef, nil)
            }
        }
    }
    
    // MARK: - Add Session To Chat History
    func addSessionToChatHistory(userId: String, session: ChatSession, completion: @escaping (Error?) -> Void) {
        let sessionData: [String: Any] = [
            "id": session.id,
            "messages": session.messages.map { $0.toDictionary() },
            "timestamp": session.timestamp
        ]
        
        db.collection("users").document(userId).collection("chatHistory").document(session.id)
            .setData(sessionData) { error in
                completion(error)
            }
    }
    
    // MARK: - Add Message to Chat
    func addMessageToChat(userId: String, chatId: String, message: ChatMessage, completion: @escaping (Error?) -> Void) {
        let docRef = db.collection("users").document(userId).collection("chatHistory").document(chatId)
        
        docRef.updateData([
            "messages": FieldValue.arrayUnion([message.toDictionary()])
        ], completion: completion)
    }
    
    // MARK: - Delete a Chat Session
    func deleteSession(userId: String, chatId: String) {
        db.collection("users").document(userId).collection("chatsHistory").document(chatId).delete()
    }
}
