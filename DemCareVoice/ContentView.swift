//
//  ContentView.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 9/13/24.
//

import SwiftUI
import SwiftData
import Combine
import Foundation
import Firebase
import FirebaseFirestore


struct ContentView: View {
    @State private var prompt: String = ""
    @ObservedObject var apiClient = APIClient.shared // Observe changes to the API Client
    @StateObject private var firestoreManager = FirestoreManager.shared
    @ObservedObject var speechRecognizer = SpeechRecognizer() // Create instance of SpeechRecognizer
    @State private var isRecording = false // Track whether we are currently recording
    @State private var textBubbles: [TextBubble] = []
    @State private var isSidebarVisible = false
    @State private var chatName = "New Chat"
    @State private var newText: String = ""
    @State private var items: [String] = []
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @StateObject private var userManager = UserManager.shared
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ChatView(isSidebarVisible: $isSidebarVisible)
                if isSidebarVisible {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea(.all)
                    SidebarView(isVisible: $isSidebarVisible)
                        .transition(.move(edge: .leading))
                        .frame(width: 325)
                        .frame(maxWidth: .infinity, alignment: .leading) // Align the menu to the left
                    
                    
                }
                
            }
        }
        .navigationBarBackButtonHidden(true) // Hides the back button
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// Button to start/stop recording
//                            Button(action: {
//                                // TODO: move thus button around so it works a little better??
//                                if self.isRecording {
//                                    self.speechRecognizer.stopRecording()
//                                    let newBubble = TextBubble(origin: "user", textContent: prompt)
//                                    textBubbles.append(newBubble)
//                                    apiClient.sendPrompt(prompt: prompt) { response in
//                                        if let responseText = response {
//                                            let responseBubble = TextBubble(origin: "llm", textContent: responseText)
//                                            textBubbles.append(responseBubble)
//                                        }
//                                    }
//
//                                } else {
//                                    self.speechRecognizer.startRecording()
//                                }
//                                self.isRecording.toggle()
//                            })
//                            {
//                                Text(isRecording ? "Stop Recording" : "Start Recording")
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(isRecording ? Color.red : Color.blue)
//                                    .cornerRadius(10)
//                            }
