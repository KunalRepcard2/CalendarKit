import UIKit

public protocol DayViewDelegate: AnyObject {
    func dayViewDidSelectEventView(_ eventView: EventView)
    func dayViewDidLongPressEventView(_ eventView: EventView)
    func dayView(dayView: DayView, didTapTimelineAt date: Date)
    func dayView(dayView: DayView, didLongPressTimelineAt date: Date)
    func dayViewDidBeginDragging(dayView: DayView)
    func dayViewDidTransitionCancel(dayView: DayView)
    func dayView(dayView: DayView, willMoveTo date: Date)
    func dayView(dayView: DayView, didMoveTo  date: Date)
    func dayView(dayView: DayView, didUpdate event: EventDescriptor)
    func dayView(shouldShowDotAt date: Date) -> Bool
}

public class DayView: UIView, TimelinePagerViewDelegate {
    public weak var dataSource: EventDataSource? {
        get {
            timelinePagerView.dataSource
        }
        set(value) {
            timelinePagerView.dataSource = value
        }
    }
    
    public weak var delegate: DayViewDelegate?
        
    private var isMonthHeaderActive: Bool = false {
        didSet {
            self.monthHeaderView.isHidden = !isMonthHeaderActive
            self.dayHeaderView.isHidden = isMonthHeaderActive
            dayHieghtConstraint.constant = isMonthHeaderActive ? 0 : self.headerVisibleHeightD
            monthHieghtConstraint.constant = isMonthHeaderActive ? self.headerVisibleHeightM : 0
        
            timelineTopToDay.isActive = !isMonthHeaderActive
            timelineTopToMonth.isActive = isMonthHeaderActive
            
            UIView.animate(withDuration: 0.3) {
                self.setNeedsLayout()
            }
            self.reloadDotsOnHeader()
        }
    }
    
    public func toggleHeaderExpansion() {
        self.shouldExpandToMonth(!self.isMonthHeaderActive)
    }
    
    public func shouldExpandToMonth(_ expand: Bool) {
        if expand {
            self.monthHeaderView.selectedDate = self.dayHeaderView.selectedDate
        } else {
            self.dayHeaderView.selectedDate = self.monthHeaderView.selectedDate
        }
        self.isMonthHeaderActive = expand
    }
    
    
    public var timelineScrollOffset: CGPoint {
        timelinePagerView.timelineScrollOffset
    }
    
    private let headerVisibleHeightD: Double = 115 // earlier 95
    private var headerVisibleHeightM: Double {
        return monthHeaderView.totalHeight
    }
        
//    public var headerHeight: Double = headerVisibleHeightD
    
    public var autoScrollToFirstEvent: Bool {
        get {
            timelinePagerView.autoScrollToFirstEvent
        }
        set (value) {
            timelinePagerView.autoScrollToFirstEvent = value
        }
    }
    
    public let dayHeaderView: DayHeaderView
    let monthHeaderView: MonthHeaderView
    public let timelinePagerView: TimelinePagerView
    
    public var state: DayViewState? {
        didSet {
            dayHeaderView.state = state
            timelinePagerView.state = state
        }
    }
    
    public var calendar: Calendar = Calendar.current
    //autoupdatingCurrent
    
    public var eventEditingSnappingBehavior: EventEditingSnappingBehavior {
        get {
            timelinePagerView.eventEditingSnappingBehavior
        }
        set {
            timelinePagerView.eventEditingSnappingBehavior = newValue
        }
    }
    
    private var style = CalendarStyle()
    
    public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.calendar = calendar
        self.dayHeaderView = DayHeaderView(calendar: calendar)
        self.monthHeaderView = MonthHeaderView(calendar: calendar)
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(frame: .zero)
        configure()
    }
    
    override public init(frame: CGRect) {
        self.dayHeaderView = DayHeaderView(calendar: calendar)
        self.monthHeaderView = MonthHeaderView(calendar: calendar)
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.dayHeaderView = DayHeaderView(calendar: calendar)
        self.monthHeaderView = MonthHeaderView(calendar: calendar)
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(coder: aDecoder)
        configure()
    }
        
    private func configure() {
        addSubview(timelinePagerView)
        addSubview(dayHeaderView)
        addSubview(monthHeaderView)
        configureLayout()
        monthHeaderView.isHidden = true
        timelinePagerView.delegate = self
        
        if state == nil {
            let newState = DayViewState(date: Date(), calendar: calendar)
            newState.move(to: Date())
            state = newState
        }
        self.dayHeaderView.headerDelegate = self
        self.monthHeaderView.headerDelegate = self
        
        self.dayHeaderView.setExpandCompletion { date in
            self.shouldExpandToMonth(true)
        }
        
        self.monthHeaderView.setDateClickCompletion { date in
            if let aDate = date {
                self.dayHeaderView.selectedDate = aDate
            }
        }
    }
    
    private var monthHieghtConstraint: NSLayoutConstraint!
    private var dayHieghtConstraint: NSLayoutConstraint!

    private var timelineTopToDay: NSLayoutConstraint!
    private var timelineTopToMonth: NSLayoutConstraint!
    
    private func configureLayout() {
        dayHeaderView.translatesAutoresizingMaskIntoConstraints = false
        monthHeaderView.translatesAutoresizingMaskIntoConstraints = false
        timelinePagerView.translatesAutoresizingMaskIntoConstraints = false

        let dayH = isMonthHeaderActive ? 0 : self.headerVisibleHeightD

        dayHeaderView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        dayHeaderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        dayHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        dayHieghtConstraint = dayHeaderView.heightAnchor.constraint(equalToConstant: dayH)
        dayHieghtConstraint.priority = .defaultLow
        dayHieghtConstraint.isActive = true
             
        let monthH = isMonthHeaderActive ? self.headerVisibleHeightM : 0
        monthHeaderView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        monthHeaderView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        monthHeaderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        monthHieghtConstraint = monthHeaderView.heightAnchor.constraint(equalToConstant: monthH)
        monthHieghtConstraint.priority = .defaultLow
        monthHieghtConstraint.isActive = true
    
//        let bAnchor: NSLayoutYAxisAnchor = isMonthHeaderActive ? monthHeaderView.bottomAnchor : dayHeaderView.bottomAnchor
        
        let tileLineH = isMonthHeaderActive ? self.headerVisibleHeightM : self.headerVisibleHeightD

        timelinePagerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        timelinePagerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        timelinePagerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        // Two possible top constraints
        timelineTopToDay = timelinePagerView.topAnchor.constraint(equalTo: dayHeaderView.bottomAnchor)
        timelineTopToMonth = timelinePagerView.topAnchor.constraint(equalTo: monthHeaderView.bottomAnchor)
        
        // Activate the correct one initially
        if isMonthHeaderActive {
            timelineTopToMonth.isActive = true
        } else {
            timelineTopToDay.isActive = true
        }
    }
    
    public func updateStyle(_ newStyle: CalendarStyle) {
        style = newStyle
        dayHeaderView.updateStyle(style.header)
        timelinePagerView.updateStyle(style.timeline)
        monthHeaderView.updateStyle(style.header)
    }
    
    public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
        timelinePagerView.timelinePanGestureRequire(toFail: gesture)
    }
    
    public func scrollTo(hour24: Float, animated: Bool = true) {
        timelinePagerView.scrollTo(hour24: hour24, animated: animated)
    }
    
    public func scrollToFirstEventIfNeeded(animated: Bool = true) {
        timelinePagerView.scrollToFirstEventIfNeeded(animated: animated)
    }
    
    public func reloadData() {
        timelinePagerView.reloadData()
    }
    
    public func reloadDotsOnHeader() {
        isMonthHeaderActive ? monthHeaderView.reloadDotsOnPage() : dayHeaderView.reloadDotsOnPage()
    }
    
    public func move(to date: Date) {
        state?.move(to: date)
    }
    
    public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        dayHeaderView.transitionToHorizontalSizeClass(sizeClass)
        updateStyle(style)
    }
    
    public func create(event: EventDescriptor, animated: Bool = false) {
        timelinePagerView.create(event: event, animated: animated)
    }
    
    public func beginEditing(event: EventDescriptor, animated: Bool = false) {
        timelinePagerView.beginEditing(event: event, animated: animated)
    }
    
    public func endEventEditing() {
        timelinePagerView.endEventEditing()
    }
    
    // MARK: TimelinePagerViewDelegate
    
    public func timelinePagerDidSelectEventView(_ eventView: EventView) {
        delegate?.dayViewDidSelectEventView(eventView)
    }
    public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
        delegate?.dayViewDidLongPressEventView(eventView)
    }
    public func timelinePagerDidBeginDragging(timelinePager: TimelinePagerView) {
        delegate?.dayViewDidBeginDragging(dayView: self)
    }
    public func timelinePagerDidTransitionCancel(timelinePager: TimelinePagerView) {
        delegate?.dayViewDidTransitionCancel(dayView: self)
    }
    public func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date) {
        delegate?.dayView(dayView: self, willMoveTo: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date) {
        delegate?.dayView(dayView: self, didMoveTo: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didLongPressTimelineAt date: Date) {
        delegate?.dayView(dayView: self, didLongPressTimelineAt: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didTapTimelineAt date: Date) {
        delegate?.dayView(dayView: self, didTapTimelineAt: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didUpdate event: EventDescriptor) {
        delegate?.dayView(dayView: self, didUpdate: event)
    }
}


extension DayView: CalHeaderViewDelegate {
    func shouldShowDotOn(date: Date) -> Bool {
        return delegate?.dayView(shouldShowDotAt: date) ?? false
    }
    
    func refreshOnHeightChange() { // no change in Weekly header
        if isMonthHeaderActive {
            monthHieghtConstraint.constant = self.headerVisibleHeightM
            UIView.animate(withDuration: 0.3) {
                self.setNeedsLayout()
            }
        }
        
    }
}
