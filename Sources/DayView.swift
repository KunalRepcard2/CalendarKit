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
    public var shouldDispQuickFilter : Bool = true
    
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
        
            qFilterTopToDay.isActive = !isMonthHeaderActive
            qFilterTopToMonth.isActive = isMonthHeaderActive
            
            UIView.animate(withDuration: 0.3) {
                self.setNeedsLayout()
            }
            self.reloadDotsOnHeader()
            if isMonthHeaderActive {
                self.monthHeaderView.willApearing()
            }
            
        }
    }
    
    public var isExpendedHeader: Bool {
        get {
            self.isMonthHeaderActive
        }
        set {
            self.isMonthHeaderActive = newValue
        }
    }
    
    public func toggleHeaderExpansion() {
        self.shouldExpandToMonth(!self.isMonthHeaderActive)
    }
    
    public func shouldExpandToMonth(_ expand: Bool) {
        if expand {
            self.monthHeaderView.selectedDate = self.dayHeaderView.selectedDate
            self.monthHeaderView.reloadOnDateChange(isManualMove: true)
        } else {
            self.dayHeaderView.selectedDate = self.monthHeaderView.selectedDate
            self.dayHeaderView.reloadOnDateChange(isManualMove: true)
        }
        self.isMonthHeaderActive = expand
    }
    
    
    public var timelineScrollOffset: CGPoint {
        timelinePagerView.timelineScrollOffset
    }
    
    private let headerVisibleHeightD: Double = 80 // earlier 95
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
    public let quickFilterView: QuickFilterView
    
    public let timelinePagerView: TimelinePagerView
    
    public var state: DayViewState? {
        didSet {
            dayHeaderView.state = state
            timelinePagerView.state = state
        }
    }
        
    public var calendar: Calendar = Calendar.current {
        didSet {
            calendar.timeZone = TimeZone.current
            calendar.locale = Locale.current
        }
    }
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
    
    public init(calendar: Calendar = Calendar.autoupdatingCurrent,
                dispQuickFilter: Bool = true,
                selectedDate: Date = Date()) {
        self.calendar = calendar
        self.dayHeaderView = DayHeaderView(calendar: calendar)
        self.monthHeaderView = MonthHeaderView(calendar: calendar)
        self.quickFilterView = QuickFilterView()
        self.timelinePagerView = TimelinePagerView(calendar: calendar, date: selectedDate)
        self.shouldDispQuickFilter = dispQuickFilter
        super.init(frame: .zero)
        configure(date: selectedDate)
    }
    
    override public init(frame: CGRect) {
        self.dayHeaderView = DayHeaderView(calendar: calendar)
        self.monthHeaderView = MonthHeaderView(calendar: calendar)
        self.quickFilterView = QuickFilterView()
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.dayHeaderView = DayHeaderView(calendar: calendar)
        self.monthHeaderView = MonthHeaderView(calendar: calendar)
        self.quickFilterView = QuickFilterView()
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(coder: aDecoder)
        configure()
    }
        
    private func configure(date: Date = Date()) {
        addSubview(timelinePagerView)
        addSubview(dayHeaderView)
        addSubview(monthHeaderView)
        addSubview(quickFilterView)
        quickFilterView.isHidden = !shouldDispQuickFilter
        configureLayout()
        monthHeaderView.isHidden = true
        timelinePagerView.delegate = self
        
        if state == nil {
            let newState = DayViewState(date: date, calendar: calendar)
            newState.move(to: date)
            state = newState
        }
        if date != dayHeaderView.selectedDate {
            self.dayHeaderView.selectedDate = date
            self.dayHeaderView.reloadOnDateChange(isManualMove: true)
            
        }
        if date != monthHeaderView.selectedDate {
            self.monthHeaderView.selectedDate = date
            self.monthHeaderView.reloadOnDateChange(isManualMove: true)
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

    private var qFilterTopToDay: NSLayoutConstraint!
    private var qFilterTopToMonth: NSLayoutConstraint!
    
    private func configureLayout() {
        dayHeaderView.translatesAutoresizingMaskIntoConstraints = false
        monthHeaderView.translatesAutoresizingMaskIntoConstraints = false
        quickFilterView.translatesAutoresizingMaskIntoConstraints = false
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
        
//        let tileLineH = isMonthHeaderActive ? self.headerVisibleHeightM : self.headerVisibleHeightD

        quickFilterView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        quickFilterView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        quickFilterView.heightAnchor.constraint(equalToConstant: shouldDispQuickFilter ? 46 : 0).isActive = true
        
        timelinePagerView.topAnchor.constraint(equalTo: quickFilterView.bottomAnchor).isActive = true
        timelinePagerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        timelinePagerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        timelinePagerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        // Two possible top constraints
        qFilterTopToDay = quickFilterView.topAnchor.constraint(equalTo: dayHeaderView.bottomAnchor)
        qFilterTopToMonth = quickFilterView.topAnchor.constraint(equalTo: monthHeaderView.bottomAnchor)
        
        // Activate the correct one initially
        if isMonthHeaderActive {
            qFilterTopToMonth.isActive = true
        } else {
            qFilterTopToDay.isActive = true
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
    
    public func moveMonthHeader(to date: Date) {
        monthHeaderView.move(from: date, to: date)
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
    public func shouldShowDotOn(date: Date) -> Bool {
        return delegate?.dayView(shouldShowDotAt: date) ?? false
    }
    
    public func refreshOnHeightChange() { // no change in Weekly header
        if isMonthHeaderActive {
            monthHieghtConstraint.constant = self.headerVisibleHeightM
            UIView.animate(withDuration: 0.3) {
                self.setNeedsLayout()
            }
        }
    }
}
