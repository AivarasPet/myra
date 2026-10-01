import SwiftUI
import UIKit

enum LucideCatalog {
    static let fallbackName = "tag"
    static var all: [String] { LucideIconNames.all }
    private static let known = Set(LucideIconNames.all)

    nonisolated static func normalizedName(_ stored: String) -> String {
        stored.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
    }

    static func assetName(for stored: String) -> String {
        let name = normalizedName(stored)
        if known.contains(name) || UIImage(named: "lucide-\(name)") != nil {
            return "lucide-\(name)"
        }
        return "lucide-\(fallbackName)"
    }
}

struct LucideIcon: View {
    private let assetName: String
    private let size: CGFloat
    private let color: Color?

    init(name: String, size: CGFloat = 20, color: Color? = nil) {
        assetName = LucideCatalog.assetName(for: name)
        self.size = size
        self.color = color
    }

    var body: some View {
        let image = Image(assetName)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
        if let color {
            image.foregroundStyle(color)
        } else {
            image
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        LucideIcon(name: "shopping-cart")
        LucideIcon(name: "money_off", size: 28, color: .brand)
        LucideIcon(name: "does-not-exist", size: 32, color: .secondary)
    }
    .padding()
}
