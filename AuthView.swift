import SwiftUI
import Firebase
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Log In")
                    .font(.title)
                    .bold()
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Divider ()
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Divider()
                
                Text(authManager.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                
                Button("Log In") {
                    authManager.errorMessage = ""
                    authManager.logIn(email: email, password: password) { success in
                        if success {
                            print("log in successful")
                        } else {
                            print("log in failed")
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                NavigationLink("Create Account", destination: SignUpView())
                
                NavigationLink ("Forgot Password", destination: ResetPasswordView())
            }
        }
        .padding()
    }
}
struct ResetPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var showResetPasswordAlert = false

    var body: some View {
        VStack(spacing: 20) {
        Text("Reset Password")
                .font(.title)
                .bold()
            TextField("Email Address", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
            
            Button("Send Link") {
                authManager.resetPassword(emailAddress: email) { success in
                    if success {
                        print("success")
                    } else {
                        print("error")
                    }
                }
                showResetPasswordAlert = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .alert("A link to reset password has been sent to \(email)", isPresented: $showResetPasswordAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var confirmEmail = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 20) {
        Text("Create Account")
                .font(.title)
                .bold()
            
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
            
            TextField("Confirm Email", text: $confirmEmail)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
            
            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
            
            SecureField("Confirm Password", text: $confirmPassword)
            Divider()
            
            Text(authManager.errorMessage)
                .foregroundColor(.red)
                .font(.caption)
            
            Button("Sign Up") {
                guard password == confirmPassword && email == confirmEmail else {
                    authManager.errorMessage = "Passwords or emails do not match"
                    return
                }
                authManager.signUp(email: email, password: password) { success in
                    if success {
                        print("success")
                    }
                    else {
                        print("error")
                    }
                }
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
