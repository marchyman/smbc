//
// Copyright 2021 Marco S Hyman
// https://www.snafu.org/
//

import Schedule
import SwiftUI

struct YearPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedYear: Int

    // the first year for which a schedule-yyyy.json exists
    let firstYear = 2017
    // a schedule for the following year is assumed to be available
    // in december
    var lastYear: Int {
        let today = Date.now
        let thisYear = Calendar.current.component(.year, from: today)
        let thisMonth = Calendar.current.component(.month, from: today)
        return thisMonth == 12 ? thisYear + 1 : thisYear
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }.padding()
            }
            Picker(
                "Pick desired year",
                selection: $selectedYear
            ) {
                ForEach(firstYear ... lastYear, id: \.self) { year in
                    Text(year.formatted(.number.grouping(.never))).tag(year)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()

            Text("Pick desired year")
            Spacer()
        }
    }
}

#Preview {
    YearPickerView(selectedYear: .constant(2025))
}
