//
//  AuthView.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 10/21/24.
//

import SwiftUI


struct AuthView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        // Create a simple UIViewController to present the Auth UI
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if uiViewController.presentedViewController == nil {
            print("Presenting Auth UI")
            AuthManager.shared.presentAuthUI(from: uiViewController)
        } else {
            print("Auth UI is already presented")
        }
    }
}
