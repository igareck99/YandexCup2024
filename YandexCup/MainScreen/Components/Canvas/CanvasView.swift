import SwiftUI

// MARK: - CanvasView

struct CanvasView: UIViewRepresentable {
    @Binding var color: Color
    @Binding var lineWidth: CGFloat
    @Binding var tool: BottomBarItem?
    @Binding var coordinator: Coordinator?
    @Binding var isDrawing: Bool
    let onLineAdded: (Line) -> Void
    
    init(color: Binding<Color>, lineWidth: Binding<CGFloat>,
         tool: Binding<BottomBarItem?> = .constant(nil),
         coordinator: Binding<Coordinator?> = .constant(nil),
         isDrawing: Binding<Bool>, onLineAdded: @escaping (Line) -> Void) {
        self._color = color
        self._lineWidth = lineWidth
        self._tool = tool
        self._coordinator = coordinator
        self._isDrawing = isDrawing
        self.onLineAdded = onLineAdded
    }

    class Coordinator: NSObject {
        var lines: [Line] = []
        var canvas: UIImageView
        var tool: BottomBarItem?
        var color: Color
        var lineWidth: CGFloat
        var isDrawing: Bool
        let onLineAdded: (Line) -> Void

        init(canvas: UIImageView, tool: BottomBarItem?,color: Color,
             lineWidth: CGFloat, isDrawing: Bool, onLineAdded: @escaping (Line) -> Void) {
            self.canvas = canvas
            self.color = color
            self.tool = tool
            self.lineWidth = lineWidth
            self.isDrawing = isDrawing
            self.onLineAdded = onLineAdded
        }

        @objc func panGesture(_ sender: UIPanGestureRecognizer) {
            if tool == nil {
                return
            }
            if !isDrawing && (tool != .eraser) {
                return
            }
            let point = sender.location(in: canvas)
            switch sender.state {
            case .began:
                startNewLine(at: point)
            case .changed:
                addPointToCurrentLine(point)
                redrawCanvas()
            case .ended, .cancelled:
                finishCurrentLine()
            default:
                break
            }
        }

        func startNewLine(at point: CGPoint) {
            let newLine = Line(
                points: [point],
                color: currentColor(),
                lineWidth: currentLineWidth(),
                isEraser: tool == .eraser,
                isBrush: tool == .brush
            )
            lines.append(newLine)
        }

        func addPointToCurrentLine(_ point: CGPoint) {
            guard !lines.isEmpty else { return }
            lines[lines.count - 1].points.append(point)
        }

        func finishCurrentLine() {
            redrawCanvas()
            self.onLineAdded(lines.last!)
        }

        func redrawCanvas() {
            let renderer = UIGraphicsImageRenderer(size: canvas.bounds.size)
            let image = renderer.image { context in
                for line in lines {
                    context.cgContext.setLineCap(.round)
                    context.cgContext.setLineWidth(line.lineWidth)
                    if line.isEraser {
                        context.cgContext.setBlendMode(.clear)
                        context.cgContext.setStrokeColor(UIColor.clear.cgColor)
                    } else {
                        if line.isBrush {
                            let color = line.color.withAlphaComponent(0.3)
                            context.cgContext.setBlendMode(.normal)
                            context.cgContext.setStrokeColor(color.cgColor)
                            context.cgContext.setShadow(offset: .zero, blur: line.lineWidth / 2, color: color.cgColor)
                        } else {
                            context.cgContext.setBlendMode(.normal)
                            context.cgContext.setStrokeColor(line.color.cgColor)
                        }
                    }
                    context.cgContext.addLines(between: line.points)
                    context.cgContext.strokePath()
                }
            }
            canvas.image = image
        }
        
        func clearCanvas() {
            lines.removeAll()
            redrawCanvas()
        }

        func undoLastLine() {
            guard !lines.isEmpty else { return }
            lines.removeLast()
            redrawCanvas()
        }

        func currentColor() -> UIColor {
            return UIColor(color)
        }

        private func currentLineWidth() -> CGFloat {
            return lineWidth
        }
    }

    func makeCoordinator() -> Coordinator {
        let canvas = UIImageView()
        let coordinator = Coordinator(canvas: canvas, tool: tool, color: color, lineWidth: lineWidth, isDrawing: isDrawing, onLineAdded: self.onLineAdded)
        DispatchQueue.main.async {
            self.coordinator = coordinator
        }
        return coordinator
    }

    func makeUIView(context: Context) -> UIImageView {
        let canvas = context.coordinator.canvas
        canvas.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panGesture(_:)))
        canvas.addGestureRecognizer(panGesture)
        return canvas
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        context.coordinator.color = color
        context.coordinator.lineWidth = lineWidth
        context.coordinator.tool = tool
        context.coordinator.isDrawing = isDrawing
    }
}
