import UIKit

public final class DateLabel: UILabel, DaySelectorItemProtocol {
    public var showDot: Bool = false
    
    public var calendar = Calendar.autoupdatingCurrent {
        didSet {
            updateState()
        }
    }

    public var date = Date() {
        didSet {
            text = String(calendar.dateComponents([.day], from: date).day!)
            updateState()
        }
    }

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    public var selected: Bool = false {
        didSet {
            animate()
        }
    }

    private var style = DaySelectorStyle()

    override public var intrinsicContentSize: CGSize {
        CGSize(width: 40, height: 40)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        isUserInteractionEnabled = true
        textAlignment = .center
        clipsToBounds = true
    }
    
    public func reloadDot() {
        // update your dot visibility
        addDotTag(showDot, color: selected ? style.selectedDotColor : style.dotColor)
    }
    
    public func updateStyle(_ newStyle: DaySelectorStyle) {
        style = newStyle
        updateState()
    }
       
    func updateState() {
        text = String(component(component: .day, from: date))
        let today = isToday
        if selected {
            font = style.todayFont
            textColor = today ? style.todayActiveTextColor : style.activeTextColor
            backgroundColor = today ? style.todayActiveBackgroundColor : style.selectedBackgroundColor
        } else {
            let notTodayColor = isAWeekend(date: date) ? style.weekendTextColor : style.inactiveTextColor
            font = style.font
            textColor = today ? style.todayInactiveTextColor : notTodayColor
            backgroundColor = style.inactiveBackgroundColor
        }
        reloadDot()
    }

    private func component(component: Calendar.Component, from date: Date) -> Int {
        calendar.component(component, from: date)
    }

    private func isAWeekend(date: Date) -> Bool {
        let weekday = component(component: .weekday, from: date)
        if weekday == 7 || weekday == 1 {
            return true
        }
        return false
    }

    private func animate(){
        UIView.transition(with: self,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.updateState()
        },
                          completion: nil)
    }

    override public func layoutSubviews() {
        layer.cornerRadius = bounds.height / 2
    }
    override public func tintColorDidChange() {
        updateState()
    }
}



public extension UIView  {
    func addDotTag(_ add: Bool,  color: UIColor) {
        self.removeDotTag()
        if !add { return }
        
        let dotView = UIView()
        dotView.backgroundColor = color
        dotView.layer.cornerRadius = 2
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.tag = 67890
        // Add dot inside the label
        self.addSubview(dotView)
        
        NSLayoutConstraint.activate([
            dotView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dotView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2), // little below
            dotView.widthAnchor.constraint(equalToConstant: 4),
            dotView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func removeDotTag() {
        if let tagV = self.viewWithTag(67890) {
            tagV.removeFromSuperview()
        }
    }
}
