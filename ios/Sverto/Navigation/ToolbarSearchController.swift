import SwiftUI
import UIKit

struct ToolbarSearchController: UIViewControllerRepresentable {
    @Binding var text: String
    let isPresented: Bool
    let prompt: String
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.onTextChange = { text = $0 }
        controller.onDismiss = onDismiss
        controller.update(text: text, isPresented: isPresented, prompt: prompt)
    }

    static func dismantleUIViewController(_ controller: Controller, coordinator: ()) {
        controller.tearDown()
    }

    final class Controller: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating {
        var onTextChange: (String) -> Void = { _ in }
        var onDismiss: () -> Void = {}

        private let searchController = UISearchController(searchResultsController: nil)
        private weak var host: UIViewController?
        private var wantsSearch = false
        private var needsKeyboardFocus = false
        private var isDismissingSearch = false

        override func viewDidLoad() {
            super.viewDidLoad()
            searchController.delegate = self
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.autocapitalizationType = .none
            searchController.searchBar.autocorrectionType = .no
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            synchronizePresentation()
        }

        func update(text: String, isPresented: Bool, prompt: String) {
            if isPresented && !wantsSearch {
                needsKeyboardFocus = true
            }
            wantsSearch = isPresented
            searchController.searchBar.placeholder = prompt
            if searchController.searchBar.text != text {
                searchController.searchBar.text = text
            }
            synchronizePresentation()
        }

        private func synchronizePresentation() {
            guard isViewLoaded, view.window != nil else { return }
            if host == nil {
                var ancestor = parent
                while let controller = ancestor {
                    if controller.navigationController?.viewControllers.contains(where: { $0 === controller }) == true {
                        host = controller
                        break
                    }
                    ancestor = controller.parent
                }
            }
            guard let host, host.navigationController?.topViewController === host else { return }

            if wantsSearch {
                guard !isDismissingSearch else { return }
                let item = host.navigationItem
                item.preferredSearchBarPlacement = .integratedButton
                item.searchBarPlacementAllowsToolbarIntegration = false
                item.searchController = searchController
                host.definesPresentationContext = true
                if !searchController.isActive {
                    searchController.isActive = true
                }
                focusSearchIfNeeded()
            } else if searchController.isActive {
                searchController.isActive = false
            } else if !isDismissingSearch {
                detach()
            }
        }

        func didPresentSearchController(_ searchController: UISearchController) {
            focusSearchIfNeeded()
        }

        private func focusSearchIfNeeded() {
            if needsKeyboardFocus, searchController.isActive,
               searchController.searchBar.becomeFirstResponder() {
                needsKeyboardFocus = false
            }
        }

        func willDismissSearchController(_ searchController: UISearchController) {
            isDismissingSearch = true
            if host?.navigationController?.topViewController === host {
                wantsSearch = false
                needsKeyboardFocus = false
                detach()
                onDismiss()
            }
        }

        func didDismissSearchController(_ searchController: UISearchController) {
            isDismissingSearch = false
            if wantsSearch {
                synchronizePresentation()
            } else {
                detach()
            }
        }

        func updateSearchResults(for searchController: UISearchController) {
            onTextChange(searchController.searchBar.text ?? "")
        }

        func tearDown() {
            searchController.delegate = nil
            searchController.searchResultsUpdater = nil
            searchController.isActive = false
            detach()
        }

        private func detach() {
            if host?.navigationItem.searchController === searchController {
                host?.navigationItem.searchController = nil
            }
        }
    }
}
