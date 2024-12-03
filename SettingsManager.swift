import SwiftData
import Combine
import Foundation
import FirebaseAuth
import Firebase


class SettingsManager: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var userEmail = Auth.auth().currentUser?.email ?? ""

    private let authManager: AuthManager

    init(authManager: AuthManager = AuthManager.shared) {
        self.authManager = authManager
    }

    // MARK: - Log User Out
    func logOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.authManager.isLoggedIn = false // Update AuthManager state
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
// MARK: - Delete Account
    func deleteAccount(inputPassword: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user is logged in."
            completion(false)
            return
        }
        guard let userEmail = user.email else {
            completion(false)
            return
        }

        let userCredentials = EmailAuthProvider.credential(withEmail: userEmail, password: inputPassword)
        user.reauthenticate(with: userCredentials) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                completion(false)
                return
            }

            user.delete { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    completion(false)
                } else {
                    DispatchQueue.main.async {
                        self.authManager.isLoggedIn = false // Update AuthManager state
                    }
                    completion(true)
                }
            }
        }
    }
// MARK: - Send Password Reset
    func resetPassword() {
        guard let emailAddress = Auth.auth().currentUser?.email else {
            DispatchQueue.main.async {
                self.errorMessage = "No email address found."
            }
            return
        }

        Auth.auth().sendPasswordReset(withEmail: emailAddress) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = "Password reset email sent to \(emailAddress)."
                }
            }
        }
    }
}
