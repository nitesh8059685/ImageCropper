// QuadrilateralView.swift

import UIKit

// Enum for corner positions
enum CornerPosition {
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
    case midTop
    case midBottom
    case midRight
    case midLeft
}

// The QuadrilateralView is a simple UIView subclass that can draw a quadrilateral, and optionally edit it.
final class QuadrilateralView: UIView {
    
    var imageSize: CGSize?
    
    private let quadLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 1.0
        layer.opacity = 1.0
        layer.isHidden = true
        return layer
    }()
    
    // We want the corner views to be displayed under the outline of the quadrilateral.
    private let quadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // The quadrilateral drawn on the view.
    private(set) var quad: Quadrilateral?
    
    public var editable = false {
        didSet {
            cornerViews(hidden: !editable)
            quadLayer.fillColor = UIColor(white: 0.0, alpha: 0.2).cgColor
//            quadLayer.fillColor = editable ? UIColor(white: 0.0, alpha: 0.6).cgColor : UIColor(white: 1.0, alpha: 0.5).cgColor
            guard let quad = quad else {
                return
            }
            drawQuad(quad, animated: false)
            layoutCornerViews(forQuad: quad)
        }
    }
    
    public var strokeColor: CGColor? {
        didSet {
            quadLayer.strokeColor = strokeColor
            topLeftCornerView.strokeColor = strokeColor
            topRightCornerView.strokeColor = strokeColor
            bottomRightCornerView.strokeColor = strokeColor
            bottomLeftCornerView.strokeColor = strokeColor
            
            midTopView.strokeColor = strokeColor
            midBottomView.strokeColor = strokeColor
            midRightView.strokeColor = strokeColor
            midLeftView.strokeColor = strokeColor
            
        }
    }
    
    private var isHighlighted = false {
        didSet (oldValue) {
            guard oldValue != isHighlighted else {
                return
            }
            quadLayer.fillColor = UIColor(white: 0.0, alpha: 0.2).cgColor
//            if isHighlighted {
//                bringSubviewToFront(quadView)
//            } else {
//                sendSubviewToBack(quadView)
//            }
        }
    }
    
    private lazy var topLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topLeft)
    }()
    
    private lazy var topRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topRight)
    }()
    
    private lazy var bottomRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomRight)
    }()
    
    private lazy var bottomLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomLeft)
    }()
    //    ------------------------------------
    private lazy var midTopView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .midTop)
    }()
    
    private lazy var midBottomView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .midBottom)
    }()
    
    private lazy var midRightView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .midRight)
    }()
    
    private lazy var midLeftView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .midLeft)
    }()
    
    private lazy var magnificationView: MagnificationView = {
        let view = MagnificationView(frame: CGRect(origin: .init(x: 0, y: 0), size: magnificationViewSize))
        view.isHidden = true
        view.layer.cornerRadius = 50
        view.layer.masksToBounds = true
        view.setBorderColors(innerColor: UIColor(hex: "#87D4FF"), outerColor: UIColor.white) // Set your desired colors
        return view
    }()
    
    private func setupMagnificationViewConstraints() {
        magnificationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            magnificationView.widthAnchor.constraint(equalToConstant: magnificationViewSize.width),
//            magnificationView.heightAnchor.constraint(equalToConstant: magnificationViewSize.height),
            magnificationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            magnificationView.topAnchor.constraint(equalTo: topAnchor, constant: -102)
        ])
    }
    
    private let magnificationViewSize = CGSize(width: 100.0, height: 100.0)
//        private let highlightedCornerViewSize = CGSize(width: 75.0, height: 75.0)
    private let cornerViewSize = CGSize(width: 20.0, height: 20.0)
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubview(quadView)
        setupCornerViews()
        setupConstraints()
        quadView.layer.addSublayer(quadLayer)
        addSubview(magnificationView)
        layoutMagnificationView()
    }
    
    private func setupConstraints() {
        guard let superview = superview else {
            // Ensure this view has been added to a superview before setting up constraints
            return
        }
        
        NSLayoutConstraint.activate([
            quadView.topAnchor.constraint(equalTo: superview.topAnchor),
            quadView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            quadView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            quadView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    private func setupCornerViews() {
        addSubview(topLeftCornerView)
        addSubview(topRightCornerView)
        addSubview(bottomRightCornerView)
        addSubview(bottomLeftCornerView)
        //        ------------
//        addSubview(midTopView)
//        addSubview(midBottomView)
//        addSubview(midRightView)
//        addSubview(midLeftView)
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard quadLayer.frame != bounds else {
            return
        }
        
        quadView.frame = bounds

            // Update quadLayer's frame to match quadView's bounds with an offset
            let offset: CGFloat = 0
            let adjustedFrame = quadView.bounds.offsetBy(dx: 0, dy: -offset)
            quadLayer.frame = adjustedFrame
        
        if let quad = quad {
            drawQuadrilateral(quad: quad, animated: false)
        }
        layoutMagnificationView()
    }
    
    private func layoutMagnificationView() {
        // Get the size of the view
        let viewSize = bounds.size
//        print(viewSize)
        
        // Define the threshold height
        let heightThreshold: CGFloat = 510.0 // Example threshold height
        
        // Set default offset and size for magnificationView
        var xOffset: CGFloat = 20
        var yOffset: CGFloat = 20
        let magnificationViewWidth: CGFloat = magnificationViewSize.width
        let magnificationViewHeight: CGFloat = magnificationViewSize.height
        
        if viewSize.height > heightThreshold {
            // If view height is greater than the threshold, set a different position
            xOffset = 20
            yOffset = 20
        } else {
            // If view height is less than or equal to the threshold, set a different position
            xOffset = 20
            yOffset = -110
        }
        
        // Update magnificationView frame
        magnificationView.frame = CGRect(
            x: xOffset,
            y: yOffset,
            width: magnificationViewWidth,
            height: magnificationViewHeight
        )
    }

    
    // MARK: - Drawings
    
    func drawQuadrilateral(quad: Quadrilateral, animated: Bool) {
        self.quad = quad
        drawQuad(quad, animated: animated)
        if editable {
            cornerViews(hidden: false)
            layoutCornerViews(forQuad: quad)
        }
    }
    
    private func drawQuad(_ quad: Quadrilateral, animated: Bool) {
        var path = quad.path
        
        if editable {
            path = path.reversing()
            let rectPath = UIBezierPath(rect: bounds)
            path.append(rectPath)
        }
        
        if animated {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = 0.2
            quadLayer.add(pathAnimation, forKey: "path")
        }
        
        quadLayer.path = path.cgPath
        quadLayer.isHidden = false
    }
    
    private func layoutCornerViews(forQuad quad: Quadrilateral) {
        topLeftCornerView.center = quad.topLeft
        topRightCornerView.center = quad.topRight
        bottomLeftCornerView.center = quad.bottomLeft
        bottomRightCornerView.center = quad.bottomRight
        //        -----------------
        midTopView.center = quad.midTop
        midBottomView.center = quad.midBottom
        midRightView.center = quad.midRight
        midLeftView.center = quad.midLeft
    }
    
    func removeQuadrilateral() {
        quadLayer.path = nil
        quadLayer.isHidden = true
    }
    
    // MARK: - Actions
    
    func moveCorner(cornerView: EditScanCornerView, atPoint point: CGPoint) {
        guard let quad = quad else {
            return
        }
        
        let validPoint = self.validPoint(point, forCornerViewOfSize: cornerView.bounds.size, inView: self)
        
        cornerView.center = validPoint
        let updatedQuad = update(quad, withPosition: validPoint, forCorner: cornerView.position)
        
        self.quad = updatedQuad
        drawQuad(updatedQuad, animated: false)
    }
    
    func highlightCornerAtPosition(position: CornerPosition, with image: UIImage) {
        guard editable else {
            return
        }
        isHighlighted = true
        
        let cornerView = cornerViewForCornerPosition(position: position)
        guard cornerView.isHighlighted == false else {
            cornerView.highlightWithImage(image)
            return
        }
        
        // Move all corner views to magnification view
        magnificationView.isHidden = false
        magnificationView.highlightWithImage(image, forCorner: position)
    }
    
    func resetHighlightedCornerViews() {
        guard editable else {
            return
        }
        isHighlighted = false
        
        magnificationView.isHidden = true
        
        for position in [CornerPosition.topLeft, CornerPosition.topRight, CornerPosition.bottomLeft, CornerPosition.bottomRight] {
            let cornerView = cornerViewForCornerPosition(position: position)
            resetHighlightedCornerView(cornerView: cornerView)
        }
    }
    
    private func resetHighlightedCornerView(cornerView: EditScanCornerView) {
        cornerView.image = nil
        cornerView.setNeedsDisplay()
    }
    
    // MARK: Validation
    
    private func validPoint(_ point: CGPoint, forCornerViewOfSize cornerViewSize: CGSize, inView view: UIView) -> CGPoint {
        var validPoint = point
        
        if point.x > view.bounds.width {
            validPoint.x = view.bounds.width
        } else if point.x < 0.0 {
            validPoint.x = 0.0
        }
        
        if point.y > view.bounds.height {
            validPoint.y = view.bounds.height
        } else if point.y < 0.0 {
            validPoint.y = 0.0
        }
        
        return validPoint
    }
    
    // MARK: - Convenience
    
    private func cornerViews(hidden: Bool) {
        topLeftCornerView.isHidden = hidden
        topRightCornerView.isHidden = hidden
        bottomRightCornerView.isHidden = hidden
        bottomLeftCornerView.isHidden = hidden
        
        midTopView.isHidden = hidden
        midBottomView.isHidden = hidden
        midRightView.isHidden = hidden
        midLeftView.isHidden = hidden
    }
    
    private func update(_ quad: Quadrilateral, withPosition position: CGPoint, forCorner corner: CornerPosition) -> Quadrilateral {
        var quad = quad
        
        switch corner {
        case .topLeft:
            quad.topLeft = position
        case .topRight:
            quad.topRight = position
        case .bottomRight:
            quad.bottomRight = position
        case .bottomLeft:
            quad.bottomLeft = position
        case .midTop:
            // Update topLeft and topRight based on the new midTop position
            print("hello")
            quad.bottomLeft = position
//            let deltaX = position.x - quad.midTop.x
//            quad.topLeft.x += deltaX
//            quad.topRight.x += deltaX
//            let deltaY = position.y - quad.midTop.y
//            quad.topLeft.y += deltaY
//            quad.topRight.y += deltaY
//            print("Updated midTop to \(position), new topLeft: \(quad.topLeft), new topRight: \(quad.topRight)")
        case .midBottom:
            // Update bottomLeft and bottomRight based on the new midBottom position
            let deltaX = position.x - quad.midBottom.x
            quad.bottomLeft.x += deltaX
            quad.bottomRight.x += deltaX
            let deltaY = position.y - quad.midBottom.y
            quad.bottomLeft.y += deltaY
            quad.bottomRight.y += deltaY
            print("Updated midBottom to \(position), new bottomLeft: \(quad.bottomLeft), new bottomRight: \(quad.bottomRight)")
        case .midRight:
            // Update topRight and bottomRight based on the new midRight position
            let deltaX = position.x - quad.midRight.x
            quad.topRight.x += deltaX
            quad.bottomRight.x += deltaX
            let deltaY = position.y - quad.midRight.y
            quad.topRight.y += deltaY
            quad.bottomRight.y += deltaY
            print("Updated midRight to \(position), new topRight: \(quad.topRight), new bottomRight: \(quad.bottomRight)")
        case .midLeft:
            // Update topLeft and bottomLeft based on the new midLeft position
            let deltaX = position.x - quad.midLeft.x
            quad.topLeft.x += deltaX
            quad.bottomLeft.x += deltaX
            let deltaY = position.y - quad.midLeft.y
            quad.topLeft.y += deltaY
            quad.bottomLeft.y += deltaY
            print("Updated midLeft to \(position), new topLeft: \(quad.topLeft), new bottomLeft: \(quad.bottomLeft)")
        }
        
        return quad
    }
    
    
    func cornerViewForCornerPosition(position: CornerPosition) -> EditScanCornerView {
        switch position {
        case .topLeft:
            return topLeftCornerView
        case .topRight:
            return topRightCornerView
        case .bottomLeft:
            return bottomLeftCornerView
        case .bottomRight:
            return bottomRightCornerView
        case .midTop:
            return midTopView
        case .midBottom:
            return midBottomView
        case .midRight:
            return midRightView
        case .midLeft:
            return midLeftView
        }
    }
}

