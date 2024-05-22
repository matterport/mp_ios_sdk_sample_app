//
//  String.swift
//  ClientSampleApp
//
//  Created by Winnie Wen on 2/16/24.
//

import Foundation

extension String {
  public enum ExtendedEncoding {
    case hexadecimal
  }

  public func hexData(using _: ExtendedEncoding) -> Data? {
    let hexStr = dropFirst(hasPrefix("0x") ? 2 : 0)

    guard hexStr.count % 2 == 0 else { return nil }

    var newData = Data(capacity: hexStr.count / 2)

    var indexIsEven = true
    for i in hexStr.indices {
      if indexIsEven {
        let byteRange = i...hexStr.index(after: i)
        guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
        newData.append(byte)
      }
      indexIsEven.toggle()
    }
    return newData
  }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
