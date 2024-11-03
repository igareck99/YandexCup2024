import Foundation

enum ShootScreenAlertItem: Identifiable {
    
    var id: UUID { UUID() }
    case removeAll
    case removeShoot
}
