import UIKit
import SwiftUICore

// MARK: - GradientSlider

final class GradientSlider: UIView {
    var widthChanged: ((CGFloat) -> Void)?

    var selectedWidth: CGFloat = GradientConsts.minWidth {
        didSet {
            let procent = (selectedWidth - GradientConsts.minWidth) / (GradientConsts.maxWidth - GradientConsts.minWidth)
            let position = procent * (GradientConsts.length - GradientConsts.circleSize)
            circlePositionConstraint?.constant = position
            circleView.setNeedsUpdateConstraints()
        }
    }

    private lazy var sliderView: UIView =  {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var backgroundLineLayer = CAGradientLayer()
    private lazy var maskLayer = CAShapeLayer()
    private lazy var circleView: UIView =  {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var circlePositionConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        addSubview(sliderView)
        sliderView.addSubview(circleView)
        sliderView.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        circleView.backgroundColor = .white
        circleView.layer.cornerRadius = GradientConsts.circleSize * 0.5
        circleView.layer.shadowColor = UIColor.yellow.cgColor
        circleView.layer.shadowOffset = CGSize(width: 1, height: 2)
        circleView.layer.shadowRadius = 5.0
        sliderView.layer.insertSublayer(backgroundLineLayer, at: 0)
        fillBackgroundLineLayer()
        makeConstraints()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureChanged))
        addGestureRecognizer(panGesture)
    }

    private func makeConstraints() {
        let circlePosition = circleView.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: 0.0)
        circlePositionConstraint = circlePosition
        NSLayoutConstraint.activate([
            sliderView.widthAnchor.constraint(equalToConstant: GradientConsts.circleSize),
            sliderView.heightAnchor.constraint(equalToConstant: GradientConsts.length),
            sliderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            sliderView.centerYAnchor.constraint(equalTo: self.bottomAnchor),
            circleView.widthAnchor.constraint(equalToConstant: GradientConsts.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: GradientConsts.circleSize),
            circlePosition,
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func fillBackgroundLineLayer() {
        let path = UIBezierPath()
        let offset = GradientConsts.circleSize * 0.5
        let length = GradientConsts.length
        let centerTop = CGPoint(x: GradientConsts.circleSize * 0.5, y: GradientConsts.circleSize * 0.1 + offset)
        let centerBottom = CGPoint(x: GradientConsts.circleSize * 0.5, y: length - GradientConsts.circleSize * 0.3 - offset)
        path.move(to: CGPoint(x: centerTop.x - GradientConsts.circleSize * 0.1, y: centerTop.y))
        path.addArc(withCenter: centerTop,
                    radius: GradientConsts.circleSize * 0.1,
                    startAngle: -.pi, endAngle: 0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: centerBottom.x + GradientConsts.circleSize * 0.3, y: centerBottom.y))
        path.addArc(withCenter: centerBottom,
                    radius: GradientConsts.circleSize * 0.3,
                    startAngle: 0, endAngle: .pi,
                    clockwise: true)
        path.close()
        maskLayer.path = path.cgPath
        maskLayer.frame = CGRect(x: 0, y: 0, width: GradientConsts.circleSize, height: GradientConsts.length)
        backgroundLineLayer.colors = [Color.sliderLeft.cgColor, Color.sliderRight.cgColor]
        backgroundLineLayer.frame = CGRect(x: 0, y: 0, width: GradientConsts.circleSize, height: GradientConsts.length)
        backgroundLineLayer.mask = maskLayer
    }

    @objc private func panGestureChanged(_ panGesture: UIPanGestureRecognizer) {
        let location = panGesture.location(in: sliderView)
        let position = max(0, min(location.y, GradientConsts.length - GradientConsts.circleSize))
        let procent = position / (GradientConsts.length - GradientConsts.circleSize)
        let width = GradientConsts.minWidth + (GradientConsts.maxWidth - GradientConsts.minWidth) * procent
        selectedWidth = width
        widthChanged?(width)
    }
}
