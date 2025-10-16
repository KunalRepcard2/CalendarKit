import UIKit

public final class SwipeLabelView: UIView, DayViewStateUpdating {
    public enum AnimationDirection {
        case Forward
        case Backward

        mutating func flip() {
            switch self {
            case .Forward:
                self = .Backward
            case .Backward:
                self = .Forward
            }
        }
    }

    var clickCompletion: ((Date) -> Void)?
    
    public private(set) var calendar = Calendar.autoupdatingCurrent
    public weak var state: DayViewState? {
        willSet(newValue) {
            state?.unsubscribe(client: self)
        }
        didSet {
            state?.subscribe(client: self)
            updateLabelText()
        }
    }
    
    private func updateLabelText() {
        let str = self.textWithDate(state!.selectedDate)
        firstLabelBtn.setAttributedTitle(str, for: .normal)
    }

    private var firstLabelBtn: UIButton {
        labelButtons.first!
    }

    private var secondLabelBtn: UIButton {
        labelButtons.last!
    }

    private var labelButtons = [UIButton]()

    private var style = SwipeLabelStyle()

    public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.calendar = calendar
        super.init(frame: .zero)
        configure()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        for _ in 0...1 {
            let button = UIButton(type: .system)
            button.titleLabel?.textAlignment = .center
            button.tintColor = .black
            labelButtons.append(button)
            addSubview(button)
           
            // Add action with closure
            if #available(iOS 14.0, *) {
                button.addAction(UIAction { _ in
                    print("Button tapped via UIAction\(self.state?.selectedDate.description ?? "")")
                    self.clickCompletion?(self.state?.selectedDate ?? Date())
                }, for: .touchUpInside)
            } else {
                
            }
        }
        updateStyle(style)
    }

    public func updateStyle(_ newStyle: SwipeLabelStyle) {
        style = newStyle
        labelButtons.forEach { button in
            button.setTitleColor(style.textColor, for: .normal)
            button.titleLabel?.font = style.font
        }
    }

    private func animate(_ direction: AnimationDirection) {
        let multiplier: Double = direction == .Forward ? -1 : 1
        let shiftRatio: Double = 30/375
        let screenWidth = bounds.width

        secondLabelBtn.alpha = 0
        secondLabelBtn.frame = bounds
        secondLabelBtn.frame.origin.x -= Double(shiftRatio * screenWidth * 3) * multiplier

        UIView.animate(withDuration: 0.3, animations: {
            self.secondLabelBtn.frame = self.bounds
            self.firstLabelBtn.frame.origin.x += Double(shiftRatio * screenWidth) * multiplier
            self.secondLabelBtn.alpha = 1
            self.firstLabelBtn.alpha = 0
        }, completion: { _ in
            self.labelButtons = self.labelButtons.reversed()
        })
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { subview in
            subview.frame = bounds
        }
    }

    // MARK: DayViewStateUpdating
    public func move(from oldDate: Date, to newDate: Date) {
        guard newDate != oldDate else {
            return
        }
        
        let str = self.textWithDate(newDate)
        secondLabelBtn.setAttributedTitle(str, for: .normal)
        
        var direction: AnimationDirection = newDate > oldDate ? .Forward : .Backward

        let rightToLeft = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if rightToLeft { direction.flip() }

        animate(direction)
    }

    private func textWithDate(_ date: Date) -> NSAttributedString {
        let attachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            attachment.image = UIImage(systemName: "chevron.down")
        }
        
        let txt = formattedDate(date: date)
        let attributedString = NSMutableAttributedString(string: txt)
        attributedString.append(NSAttributedString(string:" ")) // two spaces
        attributedString.append(NSAttributedString(attachment: attachment))
        return attributedString
    }
    
    private func formattedDate(date: Date) -> String {
        return date.stringWith(formate: "MMM d, yyyy", timeZone: calendar.timeZone)
    }
}
