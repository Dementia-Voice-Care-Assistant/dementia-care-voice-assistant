import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    
    private init() {
        DispatchQueue.main.async {
            self.isLoggedIn = Auth.auth().currentUser != nil
        }
    }
    // MARK: - Log In
    func logIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self?.isLoggedIn = true
                    self?.errorMessage = ""
                    completion(true)
                }
            }
        }
    }
    //MARK: - Sign Up
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self?.isLoggedIn = true
                    self?.errorMessage = ""
                    completion(true)
                }
            }
        }
    }
    // MARK: - Reset Password
    func resetPassword(emailAddress: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: emailAddress) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
} 
