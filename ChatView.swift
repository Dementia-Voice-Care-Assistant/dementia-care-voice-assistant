//
//  ChatView.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/7/24.
//

import SwiftUI
import SwiftData
import Combine
import Foundation

struct ChatView: View {
    @State private var prompt: String = ""
    @ObservedObject var apiClient = APIClient.shared // Observe changes to the API Client
    @ObservedObject var speechRecognizer = SpeechRecognizer() // Create instance of SpeechRecognizer
    @State private var isRecording = false // Track whether we are currently recording
    @State private var textBubbles: [TextBubble] = []
//    @State private var previousChats: [Chat] = [] // Array to store previous chats
//    @State private var selectedChat: Chat? // Currently selected chat
    @Binding var isSidebarVisible: Bool // Binding to control sidebar visibility


    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    ForEach(textBubbles) { bubble in
                        HStack {
                            if bubble.origin == "user" {
                                Spacer()
                            }
                            Text(bubble.textContent)
                                .font(.headline)
                                .foregroundColor(bubble.foregroundColor)
                                .padding()
                                .background(bubble.backgroundColor)
                                .cornerRadius(10)
                            if bubble.origin == "llm" {
                                Spacer()
                            }
                        }
                    }
                    
                }
                // TODO: Update .onChange -> deprecated in iOS 18
                .onChange(of: textBubbles) { newBubble in
                    if let lastBubble = newBubble.last {
                        scrollViewProxy.scrollTo(lastBubble.id, anchor: .bottom)
                    }
                }
            }
            Spacer()
            HStack {
                TextField("Begin typing here", text: $prompt)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    let newBubble = TextBubble(origin: "user", textContent: prompt)
                    textBubbles.append(newBubble)
                    apiClient.sendPrompt(prompt: prompt) { response in
                        if let responseText = response {
                            let responseBubble = TextBubble(origin: "llm", textContent: responseText)
                            textBubbles.append(responseBubble)
                        }
                    }
                    prompt = ""
                }) {
                    Image(systemName: "paperplane")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
        }
        .padding()
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: ChatView(isSidebarVisible: $isSidebarVisible)) {
                    Image(systemName: "plus.bubble.fill")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(PlainButtonStyle())

            }
            ToolbarItem(placement: .principal) {
                Text("New Chat")
                    .font(.headline)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    print("sidebar clicked")
                    withAnimation {
                        isSidebarVisible.toggle()
                    }
                }) {
                        Image(systemName: "sidebar.left")
                            .resizable()
                            .foregroundColor(.accentColor)
                            .frame(width: 24, height: 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Hides the back button
    }
}

struct Chat: Identifiable { // Start of Chat model
    var id: UUID = UUID() // Unique identifier for each chat
    var title: String // Title for the chat
    var textBubbles: [TextBubble]
} // End of Chat model
