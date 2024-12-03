import SwiftUI
import Firebase
import FirebaseAuth

let phoneNumber = "6786549865"

struct ContentView: View {
    @State private var prompt: String = ""
    @State private var isSidebarVisible = false
    @StateObject private var viewModel = ChatManager(userId: "")
    init() {
        if let userId = Auth.auth().currentUser?.uid {
            _viewModel = StateObject(wrappedValue: ChatManager(userId: userId))
        } else {
            fatalError("No user is logged in")
        }
    }
    @State private var isSidebarOpen = false

    var body: some View {
        NavigationStack {
        ZStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    NavigationView {
                        ChatView(viewModel: viewModel, isSidebarOpen: $isSidebarOpen)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    // Sidebar Overlay
                    if isSidebarOpen {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        withAnimation {
                                            isSidebarOpen.toggle()
                                        }
                                    }

                                VStack(alignment: .leading) {
                                    Button(action: {
                                        withAnimation {
                                            isSidebarOpen.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "sidebar.left")
                                                .resizable()
                                                .foregroundColor(.accentColor)
                                                .frame(width: 24, height: 24)
                                        }
                                    }
                                    .padding(.top)
                                    .padding(.leading)
                                    Text("Previous Chats")
                                        .padding()
                                        .font(.largeTitle)
                                    List(viewModel.chatSessions) { session in
                                        Button(action: {
                                            viewModel.selectSession(session)
                                            withAnimation {
                                                isSidebarOpen.toggle()
                                            }
                                        }) {
                                            VStack(alignment: .leading) {
                                                let firstMessageText = session.messages.first?.text ?? "No messages"
                                                let firstMessageTitle = firstMessageText.count > 20 ? String(firstMessageText.prefix(20)) + "..." : firstMessageText

                                                Text(firstMessageTitle)
                                                    .font(.headline)
                                            }
                                            .padding(.vertical, 5)
                                        }
                                    }
                                    .listStyle(PlainListStyle())
                                    HStack {
                                        Button(action: {
                                                makePhoneCall()
                                                }) {
                                                Text("Call 911")
                                                        .font(.headline)
                                                        .padding()
                                                        .background(Color.red)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(10)
                                                }
                                                .padding()
                                        Spacer()
                                        NavigationLink(destination: SettingsView()) {
                                            Image(systemName: "gearshape")
                                                .resizable()
                                                .foregroundColor(.accentColor)
                                                .frame(width: 24, height: 24)
                                        }
                                        .padding()
                                    }
                                }
                                .frame(width: geometry.size.width * 0.85)
                                .background(Color.white)
                                .offset(x: isSidebarOpen ? 0 : -geometry.size.width * 0.85) // to make it like a side panel
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

    func makePhoneCall() {
        guard let url = URL(string: "tel://\(phoneNumber)") else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot make a call on this device.")
        }
    }
