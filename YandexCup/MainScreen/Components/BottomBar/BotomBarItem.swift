import SwiftUI
import Foundation

enum BottomBarItem: Identifiable, CaseIterable {

    var id: UUID { UUID() }

    case pencil
    case brush
    case eraser
    case instruments
    case color
    case ruler
    
    var image: Image {
        switch self {
        case .pencil:
            return Image("pencil")
        case .brush:
            return Image("brush")
        case .eraser:
            return Image("eraser")
        case .instruments:
            return Image("instruments")
        case .color:
            return Image("")
        case .ruler:
            return Image(systemName: "ruler")
        }
    }
    
    var activeImage: Image {
        switch self {
        case .pencil:
            return Image("pencil-green")
        case .brush:
            return Image("brush-green")
        case .eraser:
            return Image("eraser-green")
        case .instruments:
            return Image("instruments-green")
        case .color:
            return Image("")
        case .ruler:
            return Image(systemName: "ruler")
        }
    }
}
