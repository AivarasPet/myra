import SwiftUI
import Testing
import UIKit
@testable import Sverto

@MainActor
@Suite(.serialized)
struct LayoutParityTests {
    @Test func longAmountStaysInsideItsContainerAndRemainsEditable() async throws {
        var edits: [String] = []
        let mounted = try await LayoutTestHost(
            HeroAmountHarness(value: "123456789012345.67", sign: .negative) { edits.append($0) },
            width: 320
        )
        defer { mounted.close() }
        let field = try #require(mounted.descendants.compactMap { $0 as? UITextField }.first)
        let frame = field.convert(field.bounds, to: mounted.controller.view)
        #expect(frame.minX >= 16)
        #expect(frame.maxX <= 304)
        #expect(field.text == "123456789012345.67")
        #expect(field.keyboardType == .decimalPad)

        field.becomeFirstResponder()
        field.selectedTextRange = field.textRange(from: field.endOfDocument, to: field.endOfDocument)
        field.insertText("8")
        await mounted.settle()
        #expect(field.text == "123456789012345.678")
        #expect(edits.last == "123456789012345.678")
        field.deleteBackward()
        await mounted.settle()
        #expect(field.text == "123456789012345.67")
        #expect(edits.last == "123456789012345.67")
    }
}

private struct HeroAmountHarness: View {
    @State var value: String
    let sign: AmountSign
    let onChange: (String) -> Void
    @FocusState private var focus: FormField?

    var body: some View {
        HeroAmountInput(value: value, sign: sign, autofocus: false, focus: $focus) { updated in
            value = updated
            onChange(updated)
        }
    }
}

@MainActor
private final class LayoutTestHost<Content: View> {
    let controller: UIHostingController<AnyView>
    private let window: UIWindow

    init(_ content: Content, width: CGFloat) async throws {
        controller = UIHostingController(rootView: AnyView(
            content
                .padding(.horizontal, 16)
                .frame(width: width)
                .frame(maxHeight: .infinity, alignment: .top)
                .environment(\.locale, Locale(identifier: "en_GB"))
        ))
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: width, height: 1000)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        await settle()
    }

    func settle() async {
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        try? await Task.sleep(for: .milliseconds(150))
        controller.view.layoutIfNeeded()
    }

    func close() {
        window.isHidden = true
    }

    var descendants: [UIView] {
        func visit(_ view: UIView) -> [UIView] {
            [view] + view.subviews.flatMap(visit)
        }
        return visit(controller.view)
    }
}
