//
//  SettingsView.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/7/24.
//

import SwiftUI
import SwiftData
import Combine
import Foundation

struct SettingsView: View {
    @State var removeBackButton: Bool = false
    @State var isSidebarVisible: Bool = false
    var body: some View {
        HStack {
            List {
                NavigationLink(destination: ContentView()) {
                    Text("Home")
                }
            }
        }
        .navigationBarBackButtonHidden(removeBackButton) // Hides the back button
    }
}
