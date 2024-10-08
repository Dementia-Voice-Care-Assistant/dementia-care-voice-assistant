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
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ContentView()) {
                    Text("Home")
                }
//                .simultaneousGesture(TapGesture().onEnded { removeBackButton = true })
            }
        }
        .navigationBarBackButtonHidden(removeBackButton) // Hides the back button
    }
}
