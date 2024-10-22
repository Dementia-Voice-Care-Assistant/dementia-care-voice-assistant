//
//  DemCareVoiceApp.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 9/13/24.
//

import SwiftUI
import Firebase

@main
struct DemCareVoiceApp: App {
    // register app delegate w/ firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // init API client and Firestore manager
    @StateObject private var apiClient = APIClient.shared
    @StateObject private var firestoreManager = FirestoreManager.shared
    @StateObject private var userManager = UserManager.shared
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiClient) // pass api client
                .environmentObject(firestoreManager) // pass firestore manager
                .environmentObject(userManager) // pass in user state
        }
    }
}
