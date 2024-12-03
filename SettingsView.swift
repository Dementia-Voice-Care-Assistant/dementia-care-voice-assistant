import SwiftUI
import SwiftData
import Combine
import Foundation
import FirebaseAuth
import FirebaseAuthUI
import FirebaseEmailAuthUI
import Firebase



struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var showLogOutAlert = false
    @State private var showResetPasswordAlert = false
    @State private var showDeleteAccountSheet = false
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var email = ""
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var confirmNewEmail = ""
    @State private var confirmNewPassword = ""
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("\(settingsManager.userEmail) Info")) {
                    Button("Reset Password") {
                        settingsManager.resetPassword()
                        showResetPasswordAlert = true
                    }
                    .alert("A link to reset password has been sent to \(settingsManager.userEmail)", isPresented: $showResetPasswordAlert) {
                        Button("OK", role: .cancel) { }
                    }
                }
                    Section(header: Text("Log Out")) {
                        Button("Log Out") {
                            showLogOutAlert = true
                        }
                        .alert("Are you sure you want to log out?", isPresented: $showLogOutAlert) {
                            Button("Log Out", role: .destructive) {
                                settingsManager.logOut()
                            }
                            Button("Never mind", role: .cancel) { }
                        }
                    }
                    
                    Section(header: Text("Delete Account")) {
                        Button("Delete Account") {
                            showDeleteAccountSheet = true                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showDeleteAccountSheet) {
                DeleteAccountSheet(
                    errorMessage: $errorMessage,
                    onConfirm: {
                        inputPassword in
                        settingsManager.deleteAccount(inputPassword: inputPassword) { success in
                            if success {
                                settingsManager.logOut()
                                showDeleteAccountSheet = false
                            }
                            else {
                                errorMessage = "Unkown error"
                            }
                        }
                    },
                    onCancel: {
                        errorMessage = ""
                        showDeleteAccountSheet = false
                    }
                )
            }
        }
    }


struct ChangeEmailSheet: View {
    @Binding var email: String
    @Binding var newEmail: String
    @Binding var password: String
    @Binding var errorMessage: String
    @State private var confirmNewEmail = ""
    
    var onConfirm: () -> Void
    var onCancel: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Change Email Address")
                .font(.title)
                .bold()
                .padding(.top)
            
            TextField("Old Email Address", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
            
            TextField("New Email Address", text: $newEmail)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
            
            TextField("Confirm New Email Address", text: $confirmNewEmail)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
            
            SecureField("Password", text: $password)
            Divider()
            
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            
            HStack {
                Button("Cancel", action: onCancel)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button("Confirm") {
                    if newEmail.isEmpty || confirmNewEmail.isEmpty || password.isEmpty {
                        errorMessage = "Please fill in all fields."
                    } else if newEmail != confirmNewEmail {
                        errorMessage = "New email addresses do not match."
                    }  else {
                        onConfirm()
                    }
                }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            Spacer()
        }
        .padding()
        .onDisappear {
            errorMessage = ""
            password = ""
            email = ""
        }
    }
}

struct DeleteAccountSheet: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var inputPassword = ""
    @Binding var errorMessage: String
    var onConfirm: (String) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Delete Account for \(settingsManager.userEmail)")
                .font(.title)
                .bold()
                .padding(.top)
            
            Text("Please enter your password to confirm")
                .multilineTextAlignment(.center)
            
            SecureField("Password", text: $inputPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
            
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            
            HStack {
                Button("Cancel", action: onCancel)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button("Confirm") {
                    if inputPassword.isEmpty {
                        errorMessage = "Please enter your password."
                    }
                    else {
                        onConfirm(inputPassword)
                    }
                }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            Spacer()
        }
        .padding()
        .onDisappear {
            errorMessage = ""
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
