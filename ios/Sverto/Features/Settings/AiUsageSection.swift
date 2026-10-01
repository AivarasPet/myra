import SvertoCore
import SwiftUI

struct AiUsageSection: View {
    let model: AiUsageViewModel

    var body: some View {
        Section("AI Usage") {
            if let usage = model.usage {
                AiUsageWindowRow(title: "Hourly", window: usage.hourly)
                AiUsageWindowRow(title: "Monthly", window: usage.monthly)
            } else if let error = model.errorMessage {
                Text(error).foregroundStyle(.red)
            } else {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Loading usage…").foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct AiUsageWindowRow: View {
    let title: String
    let window: AiUsageWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text("Resets \(resetDate.formatted(date: .numeric, time: .shortened))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            AiUsageBar(label: "Input", metric: window.input)
            AiUsageBar(label: "Output", metric: window.output)
        }
        .padding(.vertical, 4)
    }

    private var resetDate: Date {
        Date(timeIntervalSince1970: TimeInterval(window.resetAt))
    }
}

private struct AiUsageBar: View {
    let label: String
    let metric: AiUsageMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                Text("\(percent)%")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(percent), total: 100)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(percent) percent used")
    }

    private var percent: Int {
        guard metric.limit > 0 else { return 0 }
        let ratio = Double(metric.used) / Double(metric.limit) * 100
        return min(max(Int(ratio.rounded()), 0), 100)
    }
}
