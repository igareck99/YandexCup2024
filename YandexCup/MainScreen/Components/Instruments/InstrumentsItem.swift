import SwiftUI


enum InstrumentsItem: Identifiable, CaseIterable {
    var id: UUID { UUID() }
    
    case triangle
    case circle
    
    
    var image: Image {
        switch self {
        case .triangle:
            Image("triangle")
        case .circle:
            Image("circle")
        }
    }
    
}
