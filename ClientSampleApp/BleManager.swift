//
//  BleManager.swift
//  ClientSampleApp
//
//  Created by Winnie Wen on 2/12/24.
//

import Foundation
import CoreBluetooth
import Combine

public class BleManager: NSObject, CBCentralManagerDelegate {
  static let shared = BleManager()

  private var peripheral: CBPeripheral?
  var isReadySubject = PassthroughSubject<Bool, Never>()
  var startScanSubject = PassthroughSubject<Bool, Never>()
  var createJobSubject = PassthroughSubject<Bool, Never>()
  var completeJobSubject = PassthroughSubject<Bool, Never>()
  var discoveredPeripheralsSubject = CurrentValueSubject<Set<String>, Never>([])
  var bleServerConnectedSubject = PassthroughSubject<String, Never>()
  private var discoveredPeripherals = [String: CBPeripheral]()
  var centralManager: CBCentralManager?

  var statusUpdateCharacteristic: CBCharacteristic?

  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil, options: [:])
  }

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    centralManager = central
    print("State: \(central.state)")
    switch central.state {
    case .poweredOn:
      central.scanForPeripherals(withServices: nil)
    default:
      break
    }
  }

  public func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber
  ) {
    guard let peripheralName = peripheral.name else { return }
    discoveredPeripherals[peripheralName] = peripheral
    var savedPeripherals = discoveredPeripheralsSubject.value
    savedPeripherals.insert(peripheralName)
    discoveredPeripheralsSubject.send(savedPeripherals)
    print("Peripheral: \(String(describing: peripheral.name))")
  }

  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    guard let name = peripheral.name else {
      return
    }
    bleServerConnectedSubject.send(name)
    self.peripheral = peripheral
    self.peripheral?.delegate = self
    self.peripheral?.discoverServices(nil)
  }
}


extension BleManager: CBPeripheralDelegate {
  public func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverServices _: Error?
  ) {
    guard let services = peripheral.services else {
      print("No services found.")
      return
    }

    for service in services {
      print("Service \(service) and UUID: \(service.uuid.uuidString)")
      print("Service descriptor: \(service.description)")
      if service.uuid == CBUUID(string: "0x180A") {
        print("ready")
        isReadySubject.send(true)
      }

      else if service.uuid == CBUUID(string: "0x180D") {
        //startScanSubject.send(true)
      }
      peripheral.discoverCharacteristics(nil, for: service)
      peripheral.delegate = self
    }
  }

  public func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: Error?) {
    guard let characteristics = service.characteristics else {
      print("No characteristics found.")
      return
    }

    for characteristic in characteristics {
      print("Characteristic \(characteristic) and UUID: \(characteristic.uuid)")
      print("Characteristic descriptor: \(characteristic.description)")
      if characteristic.uuid == CBUUID(string: "0x2A37") {
        peripheral.setNotifyValue(true, for: characteristic)
      }
      else if characteristic.uuid == CBUUID(string: "0x2A2B") {
        statusUpdateCharacteristic = characteristic
      }
    }
  }

  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    print("Updated characteristic: \(characteristic)")
    /*
     Byte OUTPUT_CREATE_JOB_REQUEST = 0x31;
     Byte OUTPUT_START_SCAN_REQUEST_OUTPUT = 0x32;
     Byte OUTPUT_COMPLETE_JOB_REQUEST_OUTPUT = 0x33;
     */

    if characteristic.uuid == CBUUID(string: "0x2A37") {
      if let characteristicValue = characteristic.value {
        let value = convertDataToString(data: characteristicValue)
        if value == "1" {
          createJobSubject.send(true)
        } else if value == "2" {
          startScanSubject.send(true)
        } else if value == "3" {
          completeJobSubject.send(true)
        }
      }
    }
  }

  private func convertDataToString(data: Data) -> String {
    var convertedString = String(bytes: data, encoding: String.Encoding.utf8)
    // In case we have empty bytes, we want to remove it.
    convertedString = convertedString?.replacingOccurrences(of: "\0", with: "")
    return convertedString ?? "Unknown"
  }

  func connect(peripheralName: String) {
    guard let peripheral = discoveredPeripherals[peripheralName] else {
      print("Unable to find this peripheral.")
      return
    }
    self.peripheral = peripheral
    self.peripheral?.delegate = self
    centralManager?.connect(peripheral)
    centralManager?.stopScan()
  }

  func write(status: Status) {
    guard let statusUpdateCharacteristic = statusUpdateCharacteristic else {
      return
    }
    /* OUTPUT_JOB_CREATION_SUCCESS_VALUE: Byte = 0x40
     OUTPUT_READY_TO_SCAN_VALUE: Byte = 0x41
     OUTPUT_SCAN_SUCCESS_VALUE: Byte = 0x42
     OUTPUT_SCAN_FAILED_VALUE: Byte = 0x43
     */
    var commandString: String?
    switch status {
    case .cameraReady:
      commandString = "0x41"
    case .connected:
      break
    case .jobCreated:
      commandString = "0x40"
    case .scanSuccess:
      commandString = "0x42"
    case .scanFailure:
      commandString = "0x43"
    case .jobCompleted:
      break
    }

    guard 
      let commandString = commandString,
      let command = commandString.hexData(using: .hexadecimal) else {
      return
    }

    peripheral?
      .writeValue(
        command,
        for: statusUpdateCharacteristic,
        type: CBCharacteristicWriteType.withResponse
      )
  }
}
