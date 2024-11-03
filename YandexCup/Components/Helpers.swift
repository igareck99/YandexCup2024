import SwiftUI

// MARK: - Image

func getColor(_ isActive: Bool = true) -> Color {
    var color = ColorScheme.current == .dark ? Color.white : Color.red
    return color.opacity(isActive ? 1 : 0.4)
}
