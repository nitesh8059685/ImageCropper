//
//  File.swift
//
//
//  Created by Nitesh Sharma on 02/08/24.
//

import UIKit

// MagnificationView implementation

final class MagnificationView: UIView {
    
    private lazy var topLeftCornerView: UIImageView = {
        return createCornerImageView()
    }()
    
    private lazy var topRightCornerView: UIImageView = {
        return createCornerImageView()
    }()
    
    private lazy var bottomLeftCornerView: UIImageView = {
        return createCornerImageView()
    }()
    
    private lazy var bottomRightCornerView: UIImageView = {
        return createCornerImageView()
    }()
    
    private lazy var midTopView: UIImageView = {
        return createCornerImageView()
    }()
    private lazy var midBottomView: UIImageView = {
        return createCornerImageView()
    }()
    private lazy var midRightView: UIImageView = {
        return createCornerImageView()
    }()
    private lazy var midLeftView: UIImageView = {
        return createCornerImageView()
    }()
    
    private let outerBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor // Initially clear, set later
        layer.lineWidth = 6.0 // Adjust as needed
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private let innerBorderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor // Initially clear, set later
        layer.lineWidth = 3.0 // Adjust as needed
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    private lazy var centerIndicatorView: UILabel = {
        let plusSign = UILabel()
        plusSign.text = "+"
        plusSign.textColor = UIColor(hex: "#00FF38")
        plusSign.font = UIFont.systemFont(ofSize: 24) // Adjust size as needed
        plusSign.textAlignment = .center
        addSubview(plusSign)
        
        return plusSign
    }()
    
    private func createCornerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 130, height: 130) // Example size
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true // Initially hidden
        addSubview(imageView)
        return imageView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Arrange corner views within the magnification view
        topLeftCornerView.frame.origin = CGPoint(x: -15, y: -15)
        topRightCornerView.frame.origin = CGPoint(x: -15, y: -15)
        bottomLeftCornerView.frame.origin = CGPoint(x: -15, y: -15)
        bottomRightCornerView.frame.origin = CGPoint(x: -15, y: -15)
        
        midTopView.frame.origin = CGPoint(x: -15, y: -15)
        midBottomView.frame.origin = CGPoint(x: -15, y: -15)
        midRightView.frame.origin = CGPoint(x: -15, y: -15)
        midLeftView.frame.origin = CGPoint(x: -15, y: -15)
        
        layer.addSublayer(outerBorderLayer)
                layer.addSublayer(innerBorderLayer)
                setupBorderLayers()
        
        // Center indicator setup
        centerIndicatorView.frame.size = CGSize(width: 30, height: 30) // Adjust size as needed
        centerIndicatorView.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    
    private func setupBorderLayers() {
         let path = UIBezierPath(ovalIn: bounds)
         outerBorderLayer.path = path.cgPath
         innerBorderLayer.path = path.cgPath
     }
    
    // Update border colors and redraw
    func setBorderColors(innerColor: UIColor, outerColor: UIColor) {
        innerBorderLayer.strokeColor = innerColor.cgColor
        outerBorderLayer.strokeColor = outerColor.cgColor
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBorderLayers()
        // Adjust positions of the borders if needed
        outerBorderLayer.frame = bounds
        innerBorderLayer.frame = bounds
    }

    func highlightWithImage(_ image: UIImage, forCorner position: CornerPosition) {
        // Hide all corner views first
        topLeftCornerView.isHidden = true
        topRightCornerView.isHidden = true
        bottomLeftCornerView.isHidden = true
        bottomRightCornerView.isHidden = true
        //            -------------------
        midTopView.isHidden = true
        midBottomView.isHidden = true
        midRightView.isHidden = true
        midLeftView.isHidden = true
        
        switch position {
        case .topLeft:
            topLeftCornerView.image = image
            topLeftCornerView.isHidden = false
        case .topRight:
            topRightCornerView.image = image
            topRightCornerView.isHidden = false
        case .bottomLeft:
            bottomLeftCornerView.image = image
            bottomLeftCornerView.isHidden = false
        case .bottomRight:
            bottomRightCornerView.image = image
            bottomRightCornerView.isHidden = false
//            -------------------
        case .midTop:
            midTopView.image = image
            midTopView.isHidden = false
        case .midRight:
            midRightView.image = image
            midRightView.isHidden = false
        case .midBottom:
            midBottomView.image = image
            midBottomView.isHidden = false
        case .midLeft:
            midLeftView.image = image
            midLeftView.isHidden = false
        }
    }
    
    
}

extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let r, g, b: CGFloat
        r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        g = CGFloat((color & 0x00FF00) >> 8) / 255.0
        b = CGFloat(color & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
