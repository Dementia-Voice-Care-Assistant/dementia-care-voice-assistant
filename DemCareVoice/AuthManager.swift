//
//  AuthManager.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/21/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI
import SwiftUI

class AuthManager: NSObject {
    static let shared = AuthManager()

    private override init() {
        super.init()
    }

    func presentAuthUI(from viewController: UIViewController) {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            print("Failed to create Auth UI")
            return
        }
        authUI.delegate = self // Set the delegate to handle auth events

        // Configure providers
        let emailAuthProvider = FUIEmailAuth()
        let googleAuthProvider = FUIGoogleAuth()
        authUI.providers = [emailAuthProvider, googleAuthProvider]

        // Present the Firebase Auth UI
        let authViewController = authUI.authViewController()
        viewController.present(authViewController, animated: true, completion: nil)
        print("Auth UI presented")
    }

}

// Extend AuthManager to conform to FUIAuthDelegate
extension AuthManager: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInFor user: User) {
        print("User signed in: \(user.email ?? "")")
    }

    func authUI(_ authUI: FUIAuth, didFailToSignInWithError error: Error) {
        print("Error signing in: \(error.localizedDescription)")
    }
}
