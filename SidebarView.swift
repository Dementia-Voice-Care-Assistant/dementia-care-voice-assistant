//
//  SidebarView.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/7/24.
//

import SwiftUI
import SwiftData
import Combine
import Foundation

struct SidebarView: View {
    //@Binding var previousChats: [Chat] // Bind previous chats array
    //@Binding var selectedChat: Chat? // Bind selected chat
    @Binding var isVisible: Bool // To control sidebar visibility
    @State var isSidebarVisibleNewChat: Bool = false

    var body: some View {
        VStack {
            NavigationLink(destination: ChatView(isSidebarVisible: $isSidebarVisibleNewChat)) {
                Text("New Chat")
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
//            List(previousChats) { chat in // List to display previous chats
//                Button(action: {
//                    selectedChat = chat // Set selected chat
//                    isVisible = false // Close sidebar
//                }) {
//                    Text(chat.title) // Display chat title
//                }
//            }
//            .listStyle(PlainListStyle()) // Style for the list
            
            // Navigation link to go to the SettingsView
            NavigationLink(destination: SettingsView()) {
                Text("Settings") // Button for settings
                    .padding()
            }
            .buttonStyle(PlainButtonStyle()) // Style for the button
        }
        .padding()
        .frame(maxHeight: .infinity) // Fill the height of the sidebar
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden(true) // Hides the back button
    }
}
