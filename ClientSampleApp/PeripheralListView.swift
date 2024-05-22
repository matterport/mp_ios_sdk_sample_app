//
//  PeripheralListView.swift
//  ClientSampleApp
//
//  Created by Winnie Wen on 2/16/24.
//

import SwiftUI

struct PeripheralListView: View {
  @StateObject private var viewModel = PeripheralListViewModel()
  @State var selectedPeripheral: String? = nil
  @Environment(\.dismiss) var dismiss

  var body: some View {
    VStack {
      List(selection: $selectedPeripheral) {
        ForEach(Array(viewModel.peripheralList)) { peripheral in
          Button {
            selectedPeripheral = peripheral
            viewModel.connectSelectedPeripheral(peripheral: peripheral)
            dismiss()
          } label: {
            Text(peripheral)
          }
        }
      }
    }
  }
}
