import SwiftUI

struct DateChip: View {
    let dateEpochSeconds: Int64?
    let onSelectDate: (Date) -> Void

    private var selection: Binding<Date> {
        Binding(
            get: { dateEpochSeconds.map(DateText.date(fromUnix:)) ?? Date() },
            set: { onSelectDate($0) }
        )
    }

    var body: some View {
        DatePicker(selection: selection, displayedComponents: .date) {
            Label {
                Text("Date")
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(.brand)
            }
        }
    }
}
