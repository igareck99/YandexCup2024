import SwiftUI

extension CanvasView.Coordinator {

    func addTriangle() {
        guard self.canvas.bounds.width > 0 && canvas.bounds.height > 0 else { return }
        let centerX = canvas.bounds.width / 2
        let centerY = canvas.bounds.height / 2
        let size: CGFloat = min(canvas.bounds.width, canvas.bounds.height) / 3
        let point1 = CGPoint(x: centerX, y: centerY - size)
        let point2 = CGPoint(x: centerX - size * cos(.pi / 6), y: centerY + size / 2)
        let point3 = CGPoint(x: centerX + size * cos(.pi / 6), y: centerY + size / 2)
        let triangle = Line(
            points: [point1, point2, point3, point1],
            color: self.currentColor(),
            lineWidth: self.lineWidth,
            isEraser: false,
            isBrush: false
        )
        lines.append(triangle)
        redrawCanvas()
    }
    
    func addCircle() {
        guard self.canvas.bounds.width > 0 && canvas.bounds.height > 0 else { return }
        let centerX = canvas.bounds.width / 2
        let centerY = canvas.bounds.height / 2
        let radius: CGFloat = min(canvas.bounds.width, canvas.bounds.height) / 3
        var circlePoints: [CGPoint] = []
        let numberOfSegments = 100
        for i in 0...numberOfSegments {
            let angle = CGFloat(i) * 2 * .pi / CGFloat(numberOfSegments)
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            circlePoints.append(CGPoint(x: x, y: y))
        }
        if let firstPoint = circlePoints.first {
            circlePoints.append(firstPoint)
        }
        let circle = Line(
            points: circlePoints,
            color: self.currentColor(),
            lineWidth: self.lineWidth,
            isEraser: false,
            isBrush: false
        )
        lines.append(circle)
        redrawCanvas()
    }
    
    func addBezierCurve() {
        guard self.canvas.bounds.width > 0 && canvas.bounds.height > 0 else { return }
        let startX = canvas.bounds.width * 0.1
        let startY = canvas.bounds.height * 0.9
        let endX = canvas.bounds.width * 0.9
        let endY = canvas.bounds.height * 0.1
        let control1X = canvas.bounds.width * 0.3
        let control1Y = canvas.bounds.height * 0.2
        let control2X = canvas.bounds.width * 0.7
        let control2Y = canvas.bounds.height * 0.8
        var bezierPoints: [CGPoint] = []
        let numberOfSegments = 100
        for t in stride(from: 0.0, to: 1.0, by: 1.0 / Double(numberOfSegments)) {
            let x = pow(1 - t, 3) * startX + 3 * pow(1 - t, 2) * t * control1X + 3 * (1 - t) * pow(t, 2) * control2X + pow(t, 3) * endX
            let y = pow(1 - t, 3) * startY + 3 * pow(1 - t, 2) * t * control1Y + 3 * (1 - t) * pow(t, 2) * control2Y + pow(t, 3) * endY
            bezierPoints.append(CGPoint(x: x, y: y))
        }

        let bezierCurve = Line(
            points: bezierPoints,
            color: self.currentColor(),
            lineWidth: self.lineWidth,
            isEraser: false,
            isBrush: false
        )
        lines.append(bezierCurve)
        redrawCanvas()
    }


}

