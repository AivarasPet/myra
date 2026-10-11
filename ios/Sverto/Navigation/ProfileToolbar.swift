import SwiftUI

struct ProfileToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        ToolbarItem(placement: .topBarTrailing) {
            ProfileAvatarButton()
                .tint(.primary)
        }
    }
}
