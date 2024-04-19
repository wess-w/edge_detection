import UIKit

/// A simple rectangular button with a fixed width, red background color, centered horizontally at the bottom, containing an icon and text.
final class ShutterButton: UIControl {
    
    private let buttonLayer = CAShapeLayer()
    private let textLabel = UILabel()
    private let iconImageView = UIImageView()
    
    private let cornerRadius: CGFloat = 0
    private let buttonWidth: CGFloat = 400.0
    private let buttonHeight: CGFloat = 60.0 // Adjust height as needed
    private let iconSize: CGSize = CGSize(width: 24, height: 24)
    private let iconTextSpacing: CGFloat = 8.0
    private let textColor = UIColor.white
    private let fontSize: CGFloat = 18.0

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                animateButtonLayer(forHighlightedState: isHighlighted)
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        layer.addSublayer(buttonLayer)
        //addSubview(iconImageView)
        addSubview(textLabel)
        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
        impactFeedbackGenerator.prepare()
        
        textLabel.textColor = textColor
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: fontSize)
        textLabel.text = "Scanner"
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white // Set icon color to white
        iconImageView.image = UIImage(systemName: "camera") // Set your icon image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionTextLabel()
    }

    
    private func positionTextLabel() {
        let textX = iconTextSpacing
        let textY = (buttonHeight - textLabel.intrinsicContentSize.height) / 2.0
        textLabel.frame = CGRect(x: textX, y: textY, width: textLabel.intrinsicContentSize.width, height: textLabel.intrinsicContentSize.height)
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let buttonRect = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        
        buttonLayer.frame = buttonRect
        buttonLayer.path = UIBezierPath(roundedRect: buttonRect, cornerRadius: cornerRadius).cgPath
        buttonLayer.fillColor = UIColor(red: 88/255, green: 88/255, blue: 157/255, alpha: 1.0).cgColor // Set custom color
        buttonLayer.rasterizationScale = UIScreen.main.scale
        buttonLayer.shouldRasterize = true
    }
    
    // MARK: - Animation
    
    private func animateButtonLayer(forHighlightedState isHighlighted: Bool) {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        var values = [CATransform3DMakeScale(1.0, 1.0, 1.0), CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(0.93, 0.93, 0.93), CATransform3DMakeScale(0.9, 0.9, 0.9)]
        if isHighlighted == false {
            values = [CATransform3DMakeScale(0.9, 0.9, 0.9), CATransform3DMakeScale(1.0, 1.0, 1.0)]
        }
        animation.values = values
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.duration = isHighlighted ? 0.35 : 0.10
        
        buttonLayer.add(animation, forKey: "transform")
        impactFeedbackGenerator.impactOccurred()
    }
    
}
