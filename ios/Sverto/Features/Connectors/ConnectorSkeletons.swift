import SwiftUI

struct ConnectionCardSkeleton: View {
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                SkeletonBlock(width: 120, height: 16)
                SkeletonBlock(width: 180, height: 12)
            }
            Spacer(minLength: 8)
            SkeletonBlock(width: 72, height: 28)
        }
        .padding(.vertical, 4)
        .accessibilityLabel("Loading")
    }
}

struct ConnectionHeaderSkeleton: View {
    var body: some View {
        HStack(spacing: 16) {
            SkeletonBlock(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(width: 120, height: 16)
                SkeletonBlock(width: 160, height: 12)
            }
            Spacer(minLength: 8)
            SkeletonBlock(width: 72, height: 28)
        }
        .padding(.vertical, 4)
        .accessibilityLabel("Loading")
    }
}

struct BindingRowSkeleton: View {
    var body: some View {
        HStack(spacing: 16) {
            SkeletonBlock(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(width: 110, height: 16)
                SkeletonBlock(width: 200, height: 12)
            }
            Spacer(minLength: 8)
        }
        .padding(.vertical, 4)
        .accessibilityLabel("Loading")
    }
}

struct BindingRowsSkeleton: View {
    var rows = 3

    var body: some View {
        ForEach(0..<rows, id: \.self) { _ in
            BindingRowSkeleton()
        }
    }
}

#Preview {
    List {
        Section { ConnectionHeaderSkeleton() }
        Section { ConnectionCardSkeleton() }
        Section { BindingRowsSkeleton() }
    }
    .listStyle(.insetGrouped)
}
