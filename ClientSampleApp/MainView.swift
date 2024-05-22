//
//  ContentView.swift
//  ClientSampleApp
//
//  Created by Winnie Wen on 1/17/24.
//

import SwiftUI

struct MainView: View {
  @StateObject private var viewModel = MainViewModel(
    matterportIdentifier: "com.matterport.MatterScan://MatterScan"
  )
  //@State var logs = [String]()
  @State private var showingAlert = false
  @State private var isApptoAppConnected = false
  @State private var isJobInSession = false
  @State private var isPresentingPeripheralList = false

  var body: some View {
      VStack(alignment: .leading, content: {
        List(viewModel.logs, id: \.self) { log in
          Text(log)
        }
        Spacer()
        Button {
          isPresentingPeripheralList = true
          viewModel.logs.append("Connecting to BLE Server")
        } label: {
          HStack {
            Image(systemName: "plus.circle.fill")
              .imageScale(.large)
              .foregroundStyle(.tint)
            Text("Connect to BLE Server")
          }
        }.bold()
        Button {
          viewModel.connectMatterport()
          viewModel.logs.append("Connect to Matterport")
        } label: {
          HStack {
            Image(systemName: "app.connected.to.app.below.fill")
              .imageScale(.large)
              .foregroundStyle(.tint)
            Text("Connect to Matterport")
          }
        }
        .disabled(isApptoAppConnected)
        .bold()
//        Button {
//          viewModel.createJob()
//          viewModel.logs.append("Creating Job")
//        } label: {
//          HStack {
//            Image(systemName: "plus.circle.fill")
//              .imageScale(.large)
//              .foregroundStyle(.tint)
//            Text("Create a Job")
//          }
//        }
//        .disabled(isApptoAppConnected && isJobInSession)
//        .bold()
//        Button {
//          viewModel.logs.append("Start Scan")
//          viewModel.startScan()
//        } label: {
//          HStack {
//            Image(systemName: "scanner.fill")
//              .imageScale(.large)
//              .foregroundStyle(.tint)
//            Text("Start Scan")
//          }
//        }.bold()
//        Button {
//          viewModel.completeScan()
//          isJobInSession = false
//        } label: {
//          HStack {
//            Image(systemName: "checkmark.circle.fill")
//              .imageScale(.large)
//              .foregroundStyle(.tint)
//            Text("Complete Job")
//          }
//        }.bold()
      })
      .padding()
      .onReceive(
        NotificationCenter
          .default
          .publisher(for: Notification.Name(Constants.handleUrl)),
        perform: { object in
          if let url = object.object as? URL {
            viewModel.handleUrl(url: url)
          }
        }
      )
      .sheet(isPresented: $isPresentingPeripheralList, content: {
        PeripheralListView(selectedPeripheral: nil)
      })
      .padding(20)
    }
}

#Preview {
    MainView()
}
