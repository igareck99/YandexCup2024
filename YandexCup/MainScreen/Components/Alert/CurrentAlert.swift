import Foundation

// MARK: - CurrentAlert

enum CurrentAlert: Identifiable {
    var id: UUID { UUID() }
    
    case removeScreen
    case restartAnimation
}
