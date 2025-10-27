import UIKit

@objc public final class CurrentTimeIndicator: UIView {
    private weak var timer: Timer?

    public var calendar: Calendar = .autoupdatingCurrent {
        didSet { updateDate() }
    }

    public var is24hClock: Bool = true {
        didSet { updateDate() }
    }

    public var date = Date() {
        didSet { updateDate() }
    }

    private let timeLabel = UILabel()
    private let leftLine = UIView()
    private let rightLine = UIView()
    private var style = CurrentTimeIndicatorStyle()

    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = calendar.locale
        df.timeZone = calendar.timeZone
        return df
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    // MARK: - Configure UI
    private func configure() {
        addSubview(leftLine)
        addSubview(timeLabel)
        addSubview(rightLine)

        leftLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Label centered in view
            //timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: leftLine.trailingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: rightLine.leadingAnchor, constant: -8),
           

            // Line height
            leftLine.heightAnchor.constraint(equalToConstant: 1),
            rightLine.heightAnchor.constraint(equalToConstant: 1),

            // Lines aligned to label vertically
            leftLine.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            rightLine.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),

            // Spacing between lines and label
            //leftLine.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            //rightLine.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8),

            // Lines anchored to edges
            leftLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            rightLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),

            // ⚖️ Equal width for perfect centering
            leftLine.widthAnchor.constraint(equalTo: rightLine.widthAnchor)
        ])

        // Label setup
        timeLabel.textAlignment = .center
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.8

        updateStyle(style)
        configureTimer()
        isUserInteractionEnabled = false
    }

    // MARK: - Timer
    private func configureTimer() {
        invalidateTimer()
        let date = Date()
        var components = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute], from: date)
        components.minute! += 1
        guard let nextMinute = calendar.date(from: components) else { return }

        let newTimer = Timer(fireAt: nextMinute,
                             interval: 60,
                             target: self,
                             selector: #selector(timerDidFire(_:)),
                             userInfo: nil,
                             repeats: true)

        RunLoop.current.add(newTimer, forMode: .common)
        timer = newTimer
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func timerDidFire(_ sender: Timer) {
        date = Date()
    }

    // MARK: - Date Formatting
    private func updateDate() {
        dateFormatter.dateFormat = is24hClock ? "HH:mm" : "h:mm a"
        dateFormatter.calendar = calendar
        dateFormatter.timeZone = calendar.timeZone
        timeLabel.text = dateFormatter.string(from: date)
        configureTimer()
    }

    // MARK: - Style
    func updateStyle(_ newStyle: CurrentTimeIndicatorStyle) {
        style = newStyle
        timeLabel.textColor = style.color
        timeLabel.font = style.font
        leftLine.backgroundColor = style.color
        rightLine.backgroundColor = style.color

        switch style.dateStyle {
        case .twelveHour:
            is24hClock = false
        case .twentyFourHour:
            is24hClock = true
        default:
            is24hClock = Locale.autoupdatingCurrent.uses24hClock
        }
    }

    // MARK: - Superview
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        newSuperview != nil ? configureTimer() : invalidateTimer()
    }
}
