import UIKit

// MARK: - Line

struct Line: Equatable, Identifiable {
    let id = UUID()
    
    var points: [CGPoint]
    var color: UIColor
    var lineWidth: CGFloat
    var isEraser: Bool
    var isBrush: Bool
}
