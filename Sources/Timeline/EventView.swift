import UIKit

open class EventView: UIView {
    public var descriptor: EventDescriptor?
    public var color = UIColor.systemPink
    
    var maxFontSize: CGFloat = 12   // upper limit
    var minFontSize: CGFloat = 8   // lower limit
    var scaleFactor: CGFloat = 0.3  // % of parent height used as font size
    
    public var contentHeight: Double {
        textLabel.frame.height
    }
    
    private let verticalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return view
    }()
    
    private let stripedView: StripedBackgroundView = {
        let view = StripedBackgroundView()
        view.backgroundColor = .clear
        view.alpha = 0.3
        return view
    }()
    
    private let avatarStack: AvatarStackView = {
        let view = AvatarStackView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public private(set) lazy var textLabel: UILabel = {
        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    /// Resize Handle views showing up when editing the event.
    /// The top handle has a tag of `0` and the bottom has a tag of `1`
    public private(set) lazy var eventResizeHandles = [EventResizeHandleView(), EventResizeHandleView()]
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        clipsToBounds = false
        color = tintColor
        addSubview(textLabel)
        addSubview(verticalLine)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        //        for (idx, handle) in eventResizeHandles.enumerated() {
        //            handle.tag = idx
        //            addSubview(handle)
        //        }
    }
    
    public func updateWithDescriptor(event: EventDescriptor) {
        descriptor = event
        
        // Update text
        if let attributedText = event.attributedText {
            if textLabel.attributedText != attributedText {
                textLabel.attributedText = attributedText
            }
        } else {
            if textLabel.text != event.text { textLabel.text = event.text }
            if textLabel.textColor != event.textColor { textLabel.textColor = event.textColor }
            if textLabel.font != event.font { textLabel.font = event.font }
        }
        
        // Update line
        if verticalLine.backgroundColor != event.color {
            verticalLine.backgroundColor = event.color
        }
        
        // Update background
        backgroundColor = .clear
        layer.cornerRadius = 4
        if layer.backgroundColor != event.backgroundColor.withAlphaComponent(0.3).cgColor {
            layer.backgroundColor = event.backgroundColor.withAlphaComponent(0.3).cgColor
        }
        
        color = event.color
        
        // Resize handles
        let shouldShowHandles = event.editedEvent != nil
        //        for handle in eventResizeHandles {
        //            handle.borderColor = event.color
        //            handle.isHidden = !shouldShowHandles
        //        }
        drawsShadow = shouldShowHandles
        
        // Avatars (prevent duplicate stacking)
//        if avatarStack.superview == nil {
//            for _ in 1...5 {
//                if let url = URL(string: "https://s3-ap-southeast-2.amazonaws.com/repcard/users/dJEID16856188417637.jpg") {
//                    URLSession.shared.dataTask(with: url) { data, response, error in
//                        if let data = data, let image = UIImage(data: data) {
//                            DispatchQueue.main.async {
//                                // Use image on the main thread
//                                self.avatarStack.addAvatar(image: image)
//                                self.addSubview(self.avatarStack)
//                            }
//                        }
//                    }.resume()
//                }
//            }
//        }
        
        // Time off (prevent duplicate stacking)
        if event.isTimeOff {
            if stripedView.superview == nil {
                stripedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                stripedView.stripeColor = event.timeOffColor
                stripedView.stripeWidth = 6
                stripedView.stripeSpacing = 6
                stripedView.angle = .pi / 4
                addSubview(stripedView)
                sendSubviewToBack(stripedView)
            } else {
                stripedView.stripeColor = event.timeOffColor
            }
        } else {
            stripedView.removeFromSuperview()
        }
        
        // Refresh layout once
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    
    public func animateCreation() {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        func scaleAnimation() {
            transform = .identity
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 10,
                       options: [],
                       animations: scaleAnimation,
                       completion: nil)
    }
    
    /**
     Custom implementation of the hitTest method is needed for the tap gesture recognizers
     located in the ResizeHandleView to work.
     Since the ResizeHandleView could be outside of the EventView's bounds, the touches to the ResizeHandleView
     are ignored.
     In the custom implementation the method is recursively invoked for all of the subviews,
     regardless of their position in relation to the Timeline's bounds.
     */
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //        for resizeHandle in eventResizeHandles {
        //            if let subSubView = resizeHandle.hitTest(convert(point, to: resizeHandle), with: event) {
        //                return subSubView
        //            }
        //        }
        return super.hitTest(point, with: event)
    }
    private var drawsShadow = false
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let lineWidth: CGFloat = 4
        verticalLine.frame = CGRect(x: 0, y: 0, width: lineWidth, height: bounds.height)
        textLabel.frame = CGRect(x: 8, y: 0, width: bounds.width - 8, height: bounds.height > 21 ? 21 : bounds.height)
        stripedView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        avatarStack.frame = CGRect(x: 8, y: textLabel.frame.height + 2, width: bounds.width - 8, height: 20)
        
        //        textLabel.frame = {
        //            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
        //                return CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width - 3, height: bounds.height)
        //            } else {
        //                return CGRect(x: bounds.minX + 8, y: bounds.minY, width: bounds.width - 6, height: bounds.height)
        //            }
        //        }()
        //        if frame.minY < 0 {
        //            var textFrame = textLabel.frame;
        //            textFrame.origin.y = frame.minY * -1;
        //            textFrame.size.height += frame.minY;
        //            textLabel.frame = textFrame;
        //        }
        //        let first = eventResizeHandles.first
        //        let last = eventResizeHandles.last
        //        let radius: Double = 40
        //        let yPad: Double =  -radius / 2
        //        let width = bounds.width
        //        let height = bounds.height
        //        let size = CGSize(width: radius, height: radius)
        //        first?.frame = CGRect(origin: CGPoint(x: width - radius - layoutMargins.right, y: yPad),
        //                              size: size)
        //        last?.frame = CGRect(origin: CGPoint(x: layoutMargins.left, y: height - yPad - radius),
        //                             size: size)
        //
        if drawsShadow {
            applySketchShadow(alpha: 0.13,
                              blur: 10)
        }
        
        let parentHeight = bounds.height
        // Calculate font size relative to parent height
        let newSize = max(minFontSize, min(maxFontSize, parentHeight * scaleFactor))
        
        if textLabel.font.pointSize != newSize {
            textLabel.font = textLabel.font.withSize(newSize)
        }
    }
    
    private func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: Double = 0,
        y: Double = 2,
        blur: Double = 4,
        spread: Double = 0)
    {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2.0
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

class StripedBackgroundView: UIView {
    
    var stripeColor: UIColor = UIColor(hex: "#2E90FA14").withAlphaComponent(0.20)
    //var backgroundStripeColor: UIColor = .black
    var stripeWidth: CGFloat = 3
    var stripeSpacing: CGFloat = 3
    var angle: CGFloat = -.pi / 4   // "/" default, use .pi/4 for "\"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentMode = .redraw
        alpha = 0.3
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        contentMode = .redraw
        alpha = 0.3
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Fill background
//        context.setFillColor(backgroundStripeColor.cgColor)
//        context.fill(rect)
        
        context.saveGState()
        
        // Oversized rect so rotated lines always cover full area
        let maxDimension = max(rect.width, rect.height)
        let oversizedRect = CGRect(
            x: -maxDimension,
            y: -maxDimension,
            width: rect.width + maxDimension * 2,
            height: rect.height + maxDimension * 2
        )
        
        // Rotate around center
        context.translateBy(x: rect.midX, y: rect.midY)
        context.rotate(by: angle)
        context.translateBy(x: -rect.midX, y: -rect.midY)
        context.setAlpha(0.3)
        
        // Draw stripes
        var x: CGFloat = oversizedRect.minX
        while x < oversizedRect.maxX {
            let stripeRect = CGRect(x: x, y: oversizedRect.minY, width: stripeWidth, height: oversizedRect.height)
            //context.setFillColor(stripeColor.withAlphaComponent(0.08).cgColor)
            context.setFillColor(stripeColor.cgColor)
            context.fill(stripeRect)
            x += stripeWidth + stripeSpacing
        }
        context.restoreGState()
    }
}

class AvatarStackView: UIStackView {
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        axis = .horizontal
        spacing = 0         // space between avatars
        alignment = .center
        distribution = .equalSpacing
    }
    
    // MARK: - Public API
    public func addAvatar(image: UIImage?) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let size: CGFloat = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.heightAnchor.constraint(equalToConstant: size)
        ])
        
        // Make it circular
        imageView.layer.cornerRadius = size / 2
        imageView.layer.masksToBounds = true
        
        // Optional border (like in your design)
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        
        addArrangedSubview(imageView)
    }
}

public extension UIColor {
    convenience init(hex: String?) {
        let normalizedHexString: String = UIColor.normalize(hex)
        var c: CUnsignedLongLong = 0
        Scanner(string: normalizedHexString).scanHexInt64(&c)
        self.init(red:UIColorMasks.redValue(c), green:UIColorMasks.greenValue(c), blue:UIColorMasks.blueValue(c), alpha:UIColorMasks.alphaValue(c))
    }
    
    var hex: String { hexDescription(false) }
    var hexWithAlpha: String { hexDescription(true) }
    
    func hexDescription(_ includeAlpha: Bool = false) -> String {
        guard self.cgColor.numberOfComponents == 4 else {
            return "Color not RGB."
        }
        let a = self.cgColor.components!.map { Int($0 * CGFloat(255)) }
        let color = String.init(format: "%02x%02x%02x", a[0], a[1], a[2])
        if includeAlpha {
            let alpha = String.init(format: "%02x", a[3])
            return "\(color)\(alpha)"
        }
        return color
    }
    
    fileprivate enum UIColorMasks: CUnsignedLongLong {
        case redMask    = 0xff000000
        case greenMask  = 0x00ff0000
        case blueMask   = 0x0000ff00
        case alphaMask  = 0x000000ff
        
        static func redValue(_ value: CUnsignedLongLong) -> CGFloat {
            return CGFloat((value & redMask.rawValue) >> 24) / 255.0
        }
        
        static func greenValue(_ value: CUnsignedLongLong) -> CGFloat {
            return CGFloat((value & greenMask.rawValue) >> 16) / 255.0
        }
        
        static func blueValue(_ value: CUnsignedLongLong) -> CGFloat {
            return CGFloat((value & blueMask.rawValue) >> 8) / 255.0
        }
        
        static func alphaValue(_ value: CUnsignedLongLong) -> CGFloat {
            return CGFloat(value & alphaMask.rawValue) / 255.0
        }
    }
    
    fileprivate static func normalize(_ hex: String?) -> String {
        guard var hexString = hex else {
            return "00000000"
        }
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        if hexString.count == 3 || hexString.count == 4 {
            hexString = hexString.map { "\($0)\($0)" } .joined()
        }
        let hasAlpha = hexString.count > 7
        if !hasAlpha {
            hexString += "ff"
        }
        return hexString
    }
}

