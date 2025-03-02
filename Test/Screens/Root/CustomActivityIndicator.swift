import UIKit

class CustomActivityIndicator: CALayer {
    private let shapeLayer = CAShapeLayer()
    private var isAnimating: Bool = false

    override init() {
        super.init()
        setupLayer()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        if let indicatorLayer = layer as? CustomActivityIndicator {
            self.isAnimating = indicatorLayer.isAnimating
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    override var bounds: CGRect {
        didSet {
            updatePath()
        }
    }

    private func setupLayer() {
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4.0
        shapeLayer.lineCap = .round
        addSublayer(shapeLayer)
    }

    private func updatePath() {
        let radius = min(bounds.width, bounds.height) / 2 - shapeLayer.lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle: CGFloat = -CGFloat.pi / 2
        let endAngle: CGFloat =  startAngle + 2 * CGFloat.pi
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath
    }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true

        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.duration = 1.0
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.duration = 1.0
        strokeStartAnimation.beginTime = 1.0
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.animations = [strokeEndAnimation, strokeStartAnimation]
        strokeAnimationGroup.duration = 2.0
        strokeAnimationGroup.repeatCount = .infinity
        strokeAnimationGroup.isRemovedOnCompletion = false

        shapeLayer.add(strokeAnimationGroup, forKey: "strokeAnimation")
    }

    func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        shapeLayer.removeAnimation(forKey: "strokeAnimation")
        self.removeFromSuperlayer()
    }
}
