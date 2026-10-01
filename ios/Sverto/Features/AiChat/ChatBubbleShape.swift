import SwiftUI

enum ChatBubbleShape {
    private static let radius: CGFloat = 22
    private static let tail: CGFloat = 6

    static let user = UnevenRoundedRectangle(
        topLeadingRadius: radius,
        bottomLeadingRadius: radius,
        bottomTrailingRadius: tail,
        topTrailingRadius: radius
    )

    static let assistant = UnevenRoundedRectangle(
        topLeadingRadius: radius,
        bottomLeadingRadius: tail,
        bottomTrailingRadius: radius,
        topTrailingRadius: radius
    )

    static let maxUserBubbleWidth: CGFloat = 340

    // The raw accent (#15BA81) gives white text ~2.5:1; darkening it lifts the bubble past WCAG 4.5:1.
    static let userFill = Color.accentColor.mix(with: .black, by: 0.35)
}
