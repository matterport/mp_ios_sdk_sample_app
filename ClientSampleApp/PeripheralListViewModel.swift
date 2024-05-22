//
//  PeripheralListViewModel.swift
//  ClientSampleApp
//
//  Created by Winnie Wen on 2/16/24.
//

import Foundation
import CoreBluetooth
import Combine

class PeripheralListViewModel: ObservableObject {
  @Published var peripheralList = Set<String>()
  private var subscriptions = Set<AnyCancellable>()
  private var bleManager = BleManager.shared

  init() {
    bleManager.discoveredPeripheralsSubject
      .sink { [weak self] peripherals in
      self?.peripheralList = peripherals
    }.store(in: &subscriptions)
  }

  func connectSelectedPeripheral(peripheral: String?) {
    guard let peripheral = peripheral else {
      return
    }
    bleManager.connect(peripheralName: peripheral)
    print("Connect this peripheral")
  }
}
