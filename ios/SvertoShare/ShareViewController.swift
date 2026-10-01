import SwiftUI
import UIKit

final class ShareViewController: UIViewController {
    private let model = ShareImportModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        embedStatusView()
        let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        Task { await model.run(items) }
    }

    private func embedStatusView() {
        let status = ShareStatusView(
            model: model,
            onDone: { [weak self] in self?.extensionContext?.completeRequest(returningItems: nil) },
            onCancel: { [weak self] in self?.extensionContext?.cancelRequest(withError: CocoaError(.userCancelled)) }
        )
        let host = UIHostingController(rootView: status)
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }
}
