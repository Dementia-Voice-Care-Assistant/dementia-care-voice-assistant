////
////  SidebarView.swift
////  DemCareVoice
////
////  Created by Emily Centeno on 10/7/24.
////
//
// import SwiftUI
// import SwiftData
// import Combine
// import Foundation
// 
// private let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .medium
//    formatter.timeStyle = .short
//    return formatter
// }()
//
// struct SidebarView: View {
//    //@Binding var previousChats: [Chat] // Bind previous chats array
//    //@Binding var selectedChat: Chat? // Bind selected chat
//    @Binding var isVisible: Bool // To control sidebar visibility
//    @State var isSidebarVisibleNewChat: Bool = false
//    @StateObject var viewModel = ChatViewModel(userId: "FaoogR0ZEoeeWOE4x69KxPQK8fs1")
//    
//    let phoneNumber = "6786549865"
//
//
//    var body: some View {
//        ZStack {
//            NavigationStack {
//                VStack(alignment: .leading) {
//                    NavigationView {
//                        List(viewModel.chatSessions) { session in
//                            NavigationLink(destination: ChatView(viewModel: viewModel)) {
//                                VStack(alignment: .leading) {
//                                    Text("Chat ID: \(session.id)")
//                                        .font(.headline)
//                                    Text("Started at: \(session.timestamp.dateValue(), formatter: dateFormatter)")
//                                        .font(.subheadline)
//                                }
//                            }
//                            .onTapGesture {
//                                viewModel.selectSession(session) // Set the session when tapped
//                            }
//                        }
//                        .onAppear {
//                            viewModel.loadChatHistory()
//                        }
//                        .navigationTitle("Chat History")
//                    }                }
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        makePhoneCall()
//                    }) {
//                        Text("Call \(phoneNumber)")
//                            .font(.headline)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .padding()
////                    NavigationLink(destination: SettingsView()
////                        .onAppear {
////                            withAnimation {
////                                isVisible = false
////                            }
////                        }) {
////                        Image(systemName: "gearshape.fill")
////                            .resizable()
////                            .foregroundColor(.accentColor)
////                            .frame(width: 24, height: 24)
////                            .padding()
////                        
////                    }
//                    
//                }
//            }
//            .ignoresSafeArea()
//            .frame(maxHeight: .infinity)
//            .navigationBarBackButtonHidden(true) // Hides the back button
//        }
//    }
//    func makePhoneCall() {
//        guard let url = URL(string: "tel://\(phoneNumber)") else {
//            return
//        }
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        } else {
//            print("Cannot make a call on this device.")
//        }
//    }
//
// }
