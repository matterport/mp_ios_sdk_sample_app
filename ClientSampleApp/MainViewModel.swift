//
//  MainViewModel.swift
//  ClientSampleApp
//
//  Created by Winnie Wen on 1/31/24.
//

import SwiftUI
import CoreBluetooth
import Combine

class MainViewModel: ObservableObject {
  private var matterportIdentifier: String = "com.matterport.MatterScan://MatterScan"
  private var clientIdentifier: String = ""
  private var bleManager = BleManager.shared
  private var centralManager: CBCentralManager?

  @Published private var isConnectionReady: Bool = false
  @Published private var isScanning: Bool = false
  @Published var logs = [String]()
  private var subscriptions = Set<AnyCancellable>()

  var jobID: String?
  
  init(matterportIdentifier: String) {
    self.matterportIdentifier = matterportIdentifier

    centralManager = bleManager.centralManager

    bleManager.isReadySubject.sink { [weak self] isReady in
      if isReady {
        self?.isConnectionReady = true
        self?.connectMatterport()
        self?.logs.append("Robot is ready")
      }
    }.store(in: &subscriptions)

    bleManager.startScanSubject.sink { [weak self] shouldStartScan in
      if shouldStartScan {
        self?.logs.append("Start Scanning")
        self?.startScan()
      }
    }.store(in: &subscriptions)

    bleManager.createJobSubject.sink { [weak self] _ in
      self?.logs.append("Creating Job")
      self?.createJob()
    }.store(in: &subscriptions)

    bleManager.completeJobSubject.sink { [weak self] _ in
      self?.logs.append("Complete Job")
      self?.completeScan()
    }.store(in: &subscriptions)

    bleManager.bleServerConnectedSubject.sink { [weak self] name in
      self?.logs.append("BLE Server Connected: \(name)")
    }.store(in: &subscriptions)

    guard let urlScheme = Bundle.externalURLSchemes else {
      return
    }
    clientIdentifier = urlScheme
  }

  func handleUrl(url: URL) {
    var urlProperties = [String:String]()
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      print("Unable to get components from url")
      return
    }
    if let queryItems = components.queryItems {
        for item in queryItems {
          if let value = item.value {
            urlProperties[item.name] = value
          }
        }
    }
    if let statusItem = urlProperties["status"],
        let status = Status(rawValue: Int(statusItem) ?? -1) {
      switch status {
      case .jobCreated:
        if let jobId = urlProperties["jobId"] {
          logs.append("Job created: \(jobId)")
        }
      case .connected:
        logs.append("Matterport App Connected")
      case .cameraReady:
        logs.append("Camera is ready")
      case .scanSuccess:
        logs.append("Scan Success")
      case .scanFailure:
        logs.append("Scan Failure")
      case .jobCompleted:
        logs.append("Job Completed")
      }

      updateScanStatus(status: status)
    }
  }

  func connectMatterport() {
    sendRequest(action: Action.connect)
  }

  func createJob() {
    sendRequest(action: Action.createJob)
  }

  func startScan() {
    sendRequest(action: Action.startScan)
  }

  func completeScan() {
    sendRequest(action: Action.completeJob)
  }

  func updateScanStatus(status: Status) {
    bleManager.write(status: status)
  }

  private func sendRequest(action: Action) {
    guard let url = URL(string: "\(matterportIdentifier)?action=\(action.rawValue)&identifier=\(clientIdentifier)") else {
      return
    }
    UIApplication.shared.open(
      url,
      options: [:],
      completionHandler: nil
    )
  }
}


struct Constants {
  static let handleUrl = "handleUrl"
}

enum Action: Int {
  case connect
  case startScan
  case createJob
  case completeJob
}

enum Status: Int {
  case connected
  case cameraReady
  case jobCreated
  case scanSuccess
  case scanFailure
  case jobCompleted
}

extension Bundle {
  static let externalURLSchemes: String? = {
    guard let urlTypes = main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
      return nil
  }

  for urlTypeDictionary in urlTypes {
    guard let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [String] else { continue }
    guard let externalURLScheme = urlSchemes.first else { continue }
    guard let urlIdentifier = urlTypeDictionary["CFBundleURLName"] else { continue }
    return "\(externalURLScheme)://\(urlIdentifier)"
  }

  return nil
  }()
}
