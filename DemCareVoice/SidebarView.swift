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
        ZStack {
            NavigationStack {
                VStack(alignment: .leading) {
                    NavigationLink(destination: ChatView(isSidebarVisible: $isVisible)) {
                        Text(" Start New Chat")
                            .padding()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        isVisible = false
                    })
                    
                }
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: SettingsView()
                        .onAppear {
                            withAnimation {
                                isVisible = false
                            }
                        }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .foregroundColor(.accentColor)
                            .frame(width: 24, height: 24)
                            .padding()
                        
                    }
                }
            }
            .ignoresSafeArea()
            .frame(maxHeight: .infinity)
            .navigationBarBackButtonHidden(true) // Hides the back button
        }
    }
}
