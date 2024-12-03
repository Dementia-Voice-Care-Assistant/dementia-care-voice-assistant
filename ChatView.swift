import SwiftUI
import FirebaseFirestore

struct ChatView: View {
    @ObservedObject var viewModel: ChatManager
    @ObservedObject var speechRecognizer = SpeechRecognizer() // Create instance of SpeechRecognizer
    @State private var userInput: String = ""
    @Binding var isSidebarOpen: Bool
    @FocusState private var isInputFieldFocused: Bool // Focus state for the text field

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 8) { // Adjust spacing as needed
                        ForEach(viewModel.selectedSession?.messages ?? []) { message in
                            HStack {
                                if message.sender == "user" {
                                    Spacer()
                                    TextBubble(
                                        origin: "user",
                                        textContent: message.text,
                                        foregroundColor: .white,
                                        backgroundColor: .blue.opacity(0.9)
                                    )
                                } else {
                                    TextBubble(
                                        origin: "bot",
                                        textContent: message.text,
                                        foregroundColor: .black,
                                        backgroundColor: .gray.opacity(0.1)
                                    )
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                            .id(message.id)  // Assign a unique ID for each message
                        }

                        if !viewModel.streamedResponseText.isEmpty {
                            HStack {
                                TextBubble(
                                    origin: "bot",
                                    textContent: viewModel.streamedResponseText,
                                    foregroundColor: .black,
                                    backgroundColor: .gray.opacity(0.1)
                                )
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("streaming")  // Use a constant ID for the streaming text
                        }
                    }
                }
                .onChange(of: viewModel.streamedResponseText) { _ in
                    withAnimation {
                        scrollViewProxy.scrollTo("streaming", anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.selectedSession?.messages.count) { _ in
                    if let lastMessage = viewModel.selectedSession?.messages.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input field and Send button
            HStack {
                TextField("Type a message...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isInputFieldFocused) // Attach focus state

                Button(action: {
                    viewModel.sendMessage(userInput)
                    userInput = ""
                }) {
                    Image(systemName: "paperplane")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)
                }
                .disabled(userInput.isEmpty)

                Button(action: {
                    if speechRecognizer.isRecording {
                        speechRecognizer.stopRecording { transcribedText in
                            guard !transcribedText.isEmpty else { return }
                            viewModel.sendMessage(transcribedText)
                        }
                    } else {
                        // Start recording
                        speechRecognizer.startRecording()
                    }
                }) {
                    Image(systemName: speechRecognizer.isRecording ? "mic.circle.fill" : "mic.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
                        .padding(8)
                }
                .disabled(viewModel.isResponding) // Disable based on isResponding

            }
        }
        .padding([.horizontal, .bottom])  // Padding applied only to sides and bottom
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    withAnimation {
                        isSidebarOpen.toggle()
                        isInputFieldFocused = false // Dismiss keyboard when sidebar opens
                    }
                }) {
                    Image(systemName: "sidebar.left")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.currentChatTitle.count == 20 ? viewModel.currentChatTitle + "..." : viewModel.currentChatTitle)
                    .font(.headline)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.startNewChatSession()
                }) {
                    Image(systemName: "plus.bubble.fill")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)
                }
                .disabled(isSidebarOpen || (viewModel.selectedSession?.messages.isEmpty ?? true))
            }
        }
    }
}
