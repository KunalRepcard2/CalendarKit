import UIKit

private extension DayHeaderView {
    static let daySymbolsViewHeight: Double = 20
    static let pagingScrollViewHeight: Double = 45
    static let swipeLabelViewHeight: Double = 0
    static let daysInWeek = 7
}

public final class DayHeaderView: CalHeaderView {
    private var currentSizeClass = UIUserInterfaceSizeClass.compact
    
    public weak var state: DayViewState? {
        willSet(newValue) {
            state?.unsubscribe(client: self)
        }
        didSet {
            state?.subscribe(client: self)
            swipeLabelView.state = state
        }
    }
    
    private var currentWeekdayIndex = -1  
    
    private var swipeLabelView: SwipeLabelView
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = SystemColors.systemSeparator
        return separator
    }()
    
    override init(calendar: Calendar) {
        let swipeLabel = SwipeLabelView(calendar: calendar)
        self.swipeLabelView = swipeLabel
        super.init(calendar: calendar)
        configure()
    }
    
    public override func reloadDotsOnPage() {
        super.reloadDotsOnPage()
        guard let pageC = pagingViewController.viewControllers?.first as? DaySelectorController else { return }
        pageC.reloadDots()
    }
    
    public override func reloadOnDateChange() {
        configurePagingViewController()
        reloadDotsOnPage()
        state?.move(to: selectedDate)
    }
    
    func setExpandCompletion(_ block: @escaping (Date) -> Void) {
        self.swipeLabelView.clickCompletion = block
    }
    
    private func configure() {
        [daySymbolsView, separator].forEach(addSubview) // swipeLabelView was added too
        backgroundColor = style.backgroundColor
        configurePagingViewController()
    }
    
    private func configurePagingViewController() {
        let daySelectorController = makeSelectorController(startDate: beginningOfWeek(selectedDate))
        daySelectorController.selectedDate = selectedDate
        currentWeekdayIndex = daySelectorController.selectedIndex
        
        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let direction: UIPageViewController.NavigationDirection = leftToRight ? .forward : .reverse
        
        pagingViewController.setViewControllers([daySelectorController], direction: direction, animated: false, completion: nil)
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        addSubview(pagingViewController.view!)
    }
    
    private func makeSelectorController(startDate: Date) -> DaySelectorController {
        let daySelectorController = DaySelectorController()
        daySelectorController.calendar = calendar
        daySelectorController.transitionToHorizontalSizeClass(currentSizeClass)
        daySelectorController.updateStyle(style.daySelector)
        daySelectorController.startDate = startDate
        daySelectorController.delegate = self
        daySelectorController.reloadDots()
        return daySelectorController
    }
    
    private func beginningOfWeek(_ date: Date) -> Date {
        let weekOfYear = component(component: .weekOfYear, from: date)
        let yearForWeekOfYear = component(component: .yearForWeekOfYear, from: date)
        return calendar.date(from: DateComponents(calendar: calendar,
                                                  weekday: calendar.firstWeekday,
                                                  weekOfYear: weekOfYear,
                                                  yearForWeekOfYear: yearForWeekOfYear))!
    }
    
    private func component(component: Calendar.Component, from date: Date) -> Int {
        calendar.component(component, from: date)
    }
    
    public override func updateStyle(_ newStyle: DayHeaderStyle) {
        super.updateStyle(newStyle)
        swipeLabelView.updateStyle(style.swipeLabel)
        (pagingViewController.viewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(newStyle.daySelector)}
        backgroundColor = style.backgroundColor
        separator.backgroundColor = style.separatorColor
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        var yy: CGFloat = 5
        daySymbolsView.frame = CGRect(origin: CGPoint(x: 0, y: yy),
                                      size: CGSize(width: bounds.width, height: DayHeaderView.daySymbolsViewHeight))
        yy += DayHeaderView.daySymbolsViewHeight + 5
        pagingViewController.view?.frame = CGRect(origin: CGPoint(x: 0, y: yy),
                                                  size: CGSize(width: bounds.width, height: DayHeaderView.pagingScrollViewHeight))
        swipeLabelView.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - 5 - DayHeaderView.swipeLabelViewHeight),
                                      size: CGSize(width: bounds.width, height: DayHeaderView.swipeLabelViewHeight))
        
        let separatorHeight = 1 / UIScreen.main.scale
        separator.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - separatorHeight),
                                 size: CGSize(width: bounds.width, height: separatorHeight))
    }
    
    public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        currentSizeClass = sizeClass
//        daySymbolsView.isHidden = sizeClass == .regular
        (pagingViewController.children as? [DaySelectorController])?.forEach{$0.transitionToHorizontalSizeClass(sizeClass)}
    }
}

// MARK: DayViewStateUpdating
extension DayHeaderView : DayViewStateUpdating {
    public func move(from oldDate: Date, to newDate: Date) {
        let newDate = newDate.dateOnly(calendar: calendar)
        
        let centerView = pagingViewController.viewControllers![0] as! DaySelectorController
        let startDate = centerView.startDate.dateOnly(calendar: calendar)
        
        let daysFrom = calendar.dateComponents([.day], from: startDate, to: newDate).day!
        let newStartDate = beginningOfWeek(newDate)
        
        let new = makeSelectorController(startDate: newStartDate)
        
        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        
        if daysFrom < 0 {
            currentWeekdayIndex = abs(DayHeaderView.daysInWeek + daysFrom % DayHeaderView.daysInWeek) % DayHeaderView.daysInWeek
            new.selectedIndex = currentWeekdayIndex
            
            let direction: UIPageViewController.NavigationDirection = leftToRight ? .reverse : .forward
            
            pagingViewController.setViewControllers([new], direction: direction, animated: true, completion: nil)
        } else if daysFrom > DayHeaderView.daysInWeek - 1 {
            currentWeekdayIndex = daysFrom % DayHeaderView.daysInWeek
            new.selectedIndex = currentWeekdayIndex
            
            let direction: UIPageViewController.NavigationDirection = leftToRight ? .forward : .reverse
            
            pagingViewController.setViewControllers([new], direction: direction, animated: true, completion: nil)
        } else {
            currentWeekdayIndex = daysFrom
            centerView.selectedDate = newDate
            centerView.selectedIndex = currentWeekdayIndex
        }
    }
}

// MARK: UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension DayHeaderView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let selector = viewController as? DaySelectorController {
            let previousDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selector.startDate)!
            return makeSelectorController(startDate: previousDate)
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let selector = viewController as? DaySelectorController {
            let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selector.startDate)!
            return makeSelectorController(startDate: nextDate)
        }
        return nil
    }

    // MARK: UIPageViewControllerDelegate

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {return}
        if let selector = pageViewController.viewControllers?.first as? DaySelectorController {
            selector.selectedIndex = currentWeekdayIndex
            if let selectedDate = selector.selectedDate {
                state?.client(client: self, didMoveTo: selectedDate)
            }
        }
        // Deselect all the views but the currently visible one
        (previousViewControllers as? [DaySelectorController])?.forEach{$0.selectedIndex = -1}
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        (pendingViewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(style.daySelector)}
    }
}

// MARK: DaySelectorViewDelegate
extension DayHeaderView : DaySelectorViewDelegate {
    public func dateSelectorDidSelectDate(_ date: Date) {
        state?.move(to: date)
        self.selectedDate = date
    }
    
    public func daySelectorShouldShowDotOn(date: Date) -> Bool {
        return self.headerDelegate?.shouldShowDotOn(date: date) ?? false
    }
}
