
import CoreImage
import UIKit

/// A UIView used by corners of a quadrilateral that is aware of its position.
final class EditScanCornerView: UIView {

    let position: CornerPosition

    /// The image to display when the corner view is highlighted.
    var image: UIImage?
    private(set) var isHighlighted = false

    private lazy var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        return layer
    }()

    /// Set stroke color of corner layer
    public var strokeColor: CGColor? {
        didSet {
            circleLayer.strokeColor = strokeColor
        }
    }

    public var indicatorColor: UIColor = UIColor(hex: "#00FF38")
    
    init(frame: CGRect, position: CornerPosition) {
        self.position = position
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        clipsToBounds = true
        layer.addSublayer(circleLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let bezierPath = UIBezierPath(ovalIn: rect.insetBy(dx: circleLayer.lineWidth, dy: circleLayer.lineWidth))
        circleLayer.frame = rect
        circleLayer.path = bezierPath.cgPath

        // Draw image if set
        if let image = image {
            let imageRect = rect.insetBy(dx: 4.0, dy: 4.0) // Adjust inset as needed
            image.draw(in: imageRect)
        }
        let indicatorRadius: CGFloat = 2.0 // Adjust size as needed
               let indicatorCenter = CGPoint(x: bounds.midX, y: bounds.midY)
               let indicatorPath = UIBezierPath(ovalIn: CGRect(
                   x: indicatorCenter.x - indicatorRadius,
                   y: indicatorCenter.y - indicatorRadius,
                   width: 2 * indicatorRadius,
                   height: 2 * indicatorRadius
               ))

               indicatorColor.setFill()
               indicatorPath.fill()
    }

    func highlightWithImage(_ image: UIImage) {
        isHighlighted = true
        self.image = image
        self.setNeedsDisplay()
    }

    func reset() {
        isHighlighted = false
        image = nil
        self.setNeedsDisplay()
    }

}
