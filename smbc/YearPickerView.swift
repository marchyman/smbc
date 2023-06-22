//
//  YearPickerView.swift
//  smbc
//
//  Created by Marco S Hyman on 11/9/21.
//

import SwiftUI

struct YearPickerView: View {
    @Environment(ProgramState.self) var state
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIndex: Int

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }.padding()
            }
            Picker("Pick desired year",
                   selection: $selectedIndex) {
                ForEach(0 ..< state.yearModel.scheduleYears.count, id: \.self) {
                    Text(state.yearModel.scheduleYears[$0].year).tag($0)
                }
            }.pickerStyle(WheelPickerStyle())
             .labelsHidden()
            Text("Pick desired year")
            Spacer()
        }
    }
}

#Preview {
    let state = ProgramState()
    @State var yearIndex: Int = 0
    return YearPickerView(selectedIndex: $yearIndex)
        .environment(state)
}
