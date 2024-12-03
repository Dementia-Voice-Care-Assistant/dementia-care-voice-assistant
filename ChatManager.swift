/* ChatManager is the bridge between ChatView and FirestoreChatManager
FirestoreChatManager works directly with the Firestore Database
ChatManager is the communication link for information
gathered from ChatView and FirestoreChatManager
 */

import SwiftUI
import FirebaseFirestore

class ChatManager: ObservableObject {
    @Published var chatSessions: [ChatSession] = []
    @Published var selectedSession: ChatSession? {
        didSet {
            updateTitleBasedOnFirstMessage()
        }
    }

    @Published var isResponding = false
    private let userId: String
    @Published var currentChatTitle: String = "New Chat"
    @Published var streamedResponseText: String = ""

    init(userId: String) {
        self.userId = userId
        loadChatHistory()
    }

    // MARK: - Load Chat History
    func loadChatHistory() {
        FirestoreChatManager.shared.fetchChatHistory(userId: userId) { [weak self] sessions, _ in
            if let sessions = sessions {
                DispatchQueue.main.async {
                    self?.chatSessions = sessions
                }
            }
        }
    }
// MARK: - Select Session
    func selectSession(_ session: ChatSession) {
        selectedSession = session
    }

    // MARK: - Send User Message to Firestore Handler 
    func sendMessage(_ messageText: String) {
        guard !messageText.isEmpty else { return }

        let userMessage = ChatMessage(sender: "user", text: messageText, timestamp: Timestamp(date: Date()))

        if selectedSession == nil {
            startNewChatSession(initialMessage: userMessage) { [weak self] session in
                guard let self = self, let session = session else { return }
                self.selectedSession = session
                self.fetchBotResponse(for: messageText, in: session.id)
            }
        } else {
            addMessageToCurrentSession(userMessage)
            updateTitleBasedOnFirstMessage()
            if let session = selectedSession {
                fetchBotResponse(for: messageText, in: session.id)
            }
        }
    }

    // MARK: - Fetch Bot Response Using APIClient
    func fetchBotResponse(for prompt: String, in chatSessionId: String) {
            isResponding = true
            streamedResponseText = ""

            APIClient.shared.sendPrompt(prompt, streamData: { [weak self] chunk in
                DispatchQueue.main.async {
                    self?.streamedResponseText += chunk
                }
            }, completed: { [weak self] result in
                DispatchQueue.main.async {
                    self?.isResponding = false
                    switch result {
                    case .success:
                        if let finalText = self?.streamedResponseText, !finalText.isEmpty {
                            let llmResponse = ChatMessage(sender: "bot", text: finalText, timestamp: Timestamp(date: Date()))
                            self?.selectedSession?.messages.append(llmResponse)
                            self?.streamedResponseText = ""
                            FirestoreChatManager.shared.addMessageToChat(userId: self?.userId ?? "", chatId: chatSessionId, message: llmResponse) { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    print("Final message saved to Firestore")
                                }
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        self?.streamedResponseText = "Error: Unable to get response."
                    }
                }
            })
        }

    // MARK: - Add Bot Response to Firestore
    func addBotResponse(to chatSessionId: String) {
        let llmResponse = ChatMessage(sender: "bot", text: "", timestamp: Timestamp(date: Date()))
        FirestoreChatManager.shared.addMessageToChat(userId: userId, chatId: chatSessionId, message: llmResponse) { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.selectedSession?.messages.append(llmResponse)
                    if let index = self?.chatSessions.firstIndex(where: { $0.id == chatSessionId }) {
                        self?.chatSessions[index].messages.append(llmResponse)
                    }
                }
            } else {
                print("\(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    // MARK: - Initiate New Chat
    func startNewChatSession(initialMessage: ChatMessage? = nil, completion: ((ChatSession?) -> Void)? = nil) {
        let title = initialMessage != nil ? String(initialMessage!.text.prefix(20)) : "New Chat"
        var newSession = ChatSession(id: UUID().uuidString, messages: [], timestamp: Timestamp(date: Date()), title: title)

        if let message = initialMessage {
            newSession.messages.append(message)
        }

        selectedSession = nil

        FirestoreChatManager.shared.addSessionToChatHistory(userId: userId, session: newSession) { [weak self] error in
            guard error == nil else {
                print("\(error?.localizedDescription ?? "Unknown error")")
                completion?(nil)
                return
            }

            DispatchQueue.main.async {
                self?.chatSessions.append(newSession)
                self?.selectedSession = newSession
                self?.updateTitleBasedOnFirstMessage()
                completion?(newSession)
            }
        }
    }

    // MARK: - Continue with current session on Firestore
    private func addMessageToCurrentSession(_ message: ChatMessage) {
        guard let chatSessionId = selectedSession?.id else {
            return
        }

        FirestoreChatManager.shared.addMessageToChat(userId: userId, chatId: chatSessionId, message: message) { [weak self] error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.selectedSession?.messages.append(message)
                    self?.updateTitleBasedOnFirstMessage()

                    self?.loadChatHistory()
                }
            } else {
                print("\(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    // MARK: - Title Placeholder
    private func updateTitleBasedOnFirstMessage() {
        if let firstMessage = selectedSession?.messages.first {
            currentChatTitle = String(firstMessage.text.prefix(20))
        } else {
            currentChatTitle = "New Chat"
        }
    }
}
