import UIKit

public final class DateLabel: UILabel, DaySelectorItemProtocol {
    public var customDateRange: ClosedRange<Date>? {
        didSet {
            enabledDateRange = customDateRange
        }
    }
    
    // MARK: - Public

    public var disableDays: [Int] = [] {
        didSet {
            setDisabledWeekdays(disableDays)
        }
    }
    
    public var showDot: Bool = false {
        didSet { reloadDot() }
    }

    public var calendar: Calendar = .autoupdatingCurrent {
        didSet { updateState() }
    }

    public var date: Date = Date() {
        didSet { updateState() }
    }

    /// Set weekdays to disable (e.g. [.monday, .wednesday])
    public var disabledWeekdays = Set<Int>() {
        didSet { updateState() }
    }

    public var selected: Bool = false {
        didSet {
            guard selected else { return }
            handleSelection()
        }
    }

    // MARK: - Private

    private var style = DaySelectorStyle()

    private var isToday: Bool {
        calendar.isDateInToday(date)
    }

    /// Optional enabled date range
    public var enabledDateRange: ClosedRange<Date>? {
        didSet { updateState() }
    }

    
    private var isDisabled: Bool {
        let weekdayDisabled = disabledWeekdays.contains(
            calendar.component(.weekday, from: date)
        )

        let outOfRange = !isDateInsideRange(date)

        return weekdayDisabled || outOfRange
    }
    
    private func isDateInsideRange(_ date: Date) -> Bool {
        guard let range = enabledDateRange else { return true }

        let startCompare = calendar.compare(
            date,
            to: range.lowerBound,
            toGranularity: .day
        )

        let endCompare = calendar.compare(
            date,
            to: range.upperBound,
            toGranularity: .day
        )

        return (startCompare == .orderedSame || startCompare == .orderedDescending)
            && (endCompare == .orderedSame || endCompare == .orderedAscending)
    }



    // MARK: - Init

    override public var intrinsicContentSize: CGSize {
        CGSize(width: 40, height: 40)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        textAlignment = .center
        clipsToBounds = true
        isUserInteractionEnabled = true
    }

    // MARK: - Public API

    public func updateStyle(_ newStyle: DaySelectorStyle) {
        style = newStyle
        updateState()
    }

    public func setDisabledWeekdays(_ weekdays: [Int]) {
        disabledWeekdays = Set(weekdays.map { $0 })
    }

    // MARK: - Selection Logic

    private func handleSelection() {
        if isDisabled {
            selected = false
            return
        }
        animate()
    }

    // MARK: - State

    func updateState() {
        text = String(calendar.component(.day, from: date))

        // 🚫 Disabled
        if isDisabled {
            font = style.font
            textColor = style.disabledTextColor
            backgroundColor = style.disabledBackgroundColor
            alpha = style.disabledAlpha
            isUserInteractionEnabled = false
            //backgroundColor = style.inactiveBackgroundColor
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
            reloadDot()
            return
        }

        // ✅ Enabled
        alpha = 1
        isUserInteractionEnabled = true

        if selected {
            font = style.todayFont
            textColor = isToday ? style.todayActiveTextColor : style.activeTextColor
            backgroundColor = isToday
                ? style.todayActiveBackgroundColor
                : style.selectedBackgroundColor
        } else {
            font = style.font
            let weekendColor = isWeekend(date) ? style.weekendTextColor : style.inactiveTextColor
            textColor = isToday ? style.todayInactiveTextColor : weekendColor
            backgroundColor = style.inactiveBackgroundColor

            layer.borderWidth = isToday ? 1.5 : 0
            layer.borderColor = isToday
                ? style.todayInactiveBorderColor
                : UIColor.clear.cgColor
        }

        reloadDot()
    }

    // MARK: - Dot
    public func reloadDot() {
        // update your dot visibility
        let color = selected ? (isToday ? style.todaySelectedDotColor : style.selectedDotColor) : style.dotColor
        
        addDotTag(showDot, color: color)
        
    }

    // MARK: - Helpers

    private func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    private func animate() {
        UIView.transition(
            with: self,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: { self.updateState() },
            completion: nil
        )
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8
    }

    override public func tintColorDidChange() {
        updateState()
    }
}
