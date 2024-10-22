//
//  UserManager.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/21/24.
//

import Firebase
import FirebaseAuth
import FirebaseAuthUI
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager() // Singleton instance

    @Published var user: User? // Store the current user

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    private init() {
        // Observe authentication state
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user // Update the user property
            print("Auth state changed: \(user != nil ? "User logged in" : "No user")") // Debugging log
        }
    }

    // Log out the current user
    func logOut() {
        do {
            try Auth.auth().signOut()
            user = nil // Clear the user property
            print("User logged out") // Debugging log
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    deinit {
        // Remove the listener when the instance is deallocated
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
