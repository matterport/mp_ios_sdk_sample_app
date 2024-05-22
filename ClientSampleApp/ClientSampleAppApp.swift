//
//  ClientSampleAppApp.swift
//  ClientSampleApp
//
//  Created by Winnie Wen on 1/17/24.
//

import SwiftUI

@main
struct ClientSampleAppApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
              .onOpenURL(perform: handleURL)
        }
    }

  func handleURL(_ url: URL) {
    NotificationCenter.default.post(name: .init(Constants.handleUrl), object: url)
  }
}

