import UIKit

public final class DaySymbolsView: UIView {

    // MARK: - Properties

    public private(set) var daysInWeek: Int = 7
    private var calendar: Calendar = .autoupdatingCurrent
    private var labels: [UILabel] = []
    private var style: DaySymbolsStyle = DaySymbolsStyle()

    private var disabledWeekdays = Set<Int>() // Calendar weekday values (1–7)
    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeViews()
    }

    public init(daysInWeek: Int = 7, calendar: Calendar = .autoupdatingCurrent, disabledWeekdays: [Int] = []) {
        self.daysInWeek = daysInWeek
        self.calendar = calendar
        self.disabledWeekdays = Set(disabledWeekdays.map { $0 })
        super.init(frame: .zero)
        initializeViews()
    }

    // MARK: - Setup

    private func initializeViews() {
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll()

        for _ in 0..<daysInWeek {
            let label = UILabel()
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            addSubview(label)
            labels.append(label)
        }
        configure()
    }

    // MARK: - Public API

    public func updateStyle(_ newStyle: DaySymbolsStyle) {
        self.style = newStyle
        configure()
    }

    // MARK: - Configure

    private func configure() {
        let symbols = UIDevice.current.userInterfaceIdiom == .pad
            ? calendar.shortWeekdaySymbols
            : calendar.veryShortWeekdaySymbols

        let weekendMask = [true] + [Bool](repeating: false, count: 5) + [true]
        var weekDays = Array(zip(symbols, weekendMask))

        // Shift according to firstWeekday
        weekDays.shift(calendar.firstWeekday - 1)

        // RTL support
        let isRTL = UIView.userInterfaceLayoutDirection(
            for: semanticContentAttribute
        ) == .rightToLeft

        if isRTL { weekDays.reverse() }

        for (index, label) in labels.enumerated() {

            let weekday = ((calendar.firstWeekday - 1 + index) % 7) + 1
            let isDisabled = disabledWeekdays.contains(weekday)
            let isWeekend = weekDays[index].1

            label.text = weekDays[index].0
            label.font = style.font

            if isDisabled {
                label.textColor = style.disabledColor
                label.alpha = style.disabledAlpha
                label.isUserInteractionEnabled = false
            } else {
                label.textColor = isWeekend ? style.weekendColor : style.weekDayColor
                label.alpha = 1.0
                label.isUserInteractionEnabled = true
            }
        }
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()

        let labelWidth = bounds.width / CGFloat(labels.count)
        let fixedWidth: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 70 : 20

        for (index, label) in labels.enumerated() {
            let x = CGFloat(index) * labelWidth + (labelWidth - fixedWidth) / 2
            label.frame = CGRect(
                x: x,
                y: 0,
                width: fixedWidth,
                height: bounds.height
            )
        }
    }
}

