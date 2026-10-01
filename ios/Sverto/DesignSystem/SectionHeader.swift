import SwiftUI

struct SectionHeader: View {
    private let title: String
    private let trailing: (() -> AnyView)?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(_ title: String, trailing: (() -> AnyView)? = nil) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
        layout {
            Text(title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 8)
            }
            if let trailing {
                trailing()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EmptyState: View {
    private let title: String
    private let systemImage: String
    private let description: String?

    init(title: String, systemImage: String, description: String? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let description {
                Text(description)
            }
        }
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            ProgressView()
                .controlSize(.large)
                .padding(24)
                .background(.regularMaterial, in: .rect(cornerRadius: Layout.cardRadius))
        }
        .accessibilityLabel("Loading")
    }
}

#Preview {
    VStack(spacing: 24) {
        SectionHeader("Holdings", trailing: { AnyView(Button("See all") {}) })
        EmptyState(title: "No transactions", systemImage: "list.bullet.rectangle.portrait", description: "Add your first transaction to get started.")
    }
    .padding()
}
