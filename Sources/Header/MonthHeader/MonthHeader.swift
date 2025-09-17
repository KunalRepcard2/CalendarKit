//
//  MonthHeaderView.swift
//  CalendarKit
//
//  Created by Prakash Jha on 17/09/25.
//

import UIKit

class MonthHeaderView: UIView {
    public let calendar: Calendar
    private let daySymbolsView: DaySymbolsView

    private var daySymbolsViewHeight: Double = 20
    private var pagingScrollViewHeight: Double = 45 * 5
    private var swipeLabelViewHeight: Double = 20
    
    private var pagingViewController = UIPageViewController(transitionStyle: .scroll,
                                                            navigationOrientation: .horizontal,
                                                            options: nil)
    
    private var style = DayHeaderStyle()
    private var dateClickCompletion: ((Date?) -> Void)?


    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = SystemColors.systemSeparator
        return separator
    }()
    
    public init(calendar: Calendar) {
        self.calendar = calendar
        let symbols = DaySymbolsView(calendar: calendar)
//        let swipeLabel = SwipeLabelView(calendar: calendar)
        self.daySymbolsView = symbols

        super.init(frame: .zero)
        configure()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        var yy: CGFloat = 5
        daySymbolsView.frame = CGRect(origin: CGPoint(x: 0, y: yy),
                                      size: CGSize(width: bounds.width, height: daySymbolsViewHeight))
        yy += daySymbolsViewHeight + 5
        
        pagingViewController.view?.frame = CGRect(origin: CGPoint(x: 0, y: yy),
                                                  size: CGSize(width: bounds.width, height: pagingScrollViewHeight))
//        swipeLabelView.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - 5 - swipeLabelViewHeight),
//                                      size: CGSize(width: bounds.width, height: swipeLabelViewHeight))

        let separatorHeight = 1 / UIScreen.main.scale
        separator.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - separatorHeight),
                                 size: CGSize(width: bounds.width, height: separatorHeight))
    }
    
    func setDateClickCompletion(_ block: @escaping (Date?) -> Void) {
        self.dateClickCompletion = block
    }
    
    private func configure() {
        [daySymbolsView, separator].forEach(addSubview)
        backgroundColor = style.backgroundColor
        configurePagingViewController()
    }
    
    func reloadDotsOnPage() {
        guard let pageC = pagingViewController.viewControllers?.first as? MonthSelectorController else { return }
        pageC.reloadDots()
    }
}

private extension MonthHeaderView {
     func configurePagingViewController() {
        let selectedDate = Date()
        let monthSelectorController = makeSelectorController()

        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let direction: UIPageViewController.NavigationDirection = leftToRight ? .forward : .reverse

        pagingViewController.setViewControllers([monthSelectorController], direction: direction, animated: false, completion: nil)
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        addSubview(pagingViewController.view!)
         monthSelectorController.setDateClickCompletion { date in
             self.dateClickCompletion?(date)
         }
    }
    
    func makeSelectorController() -> MonthSelectorController {
        let monthSelectorController = MonthSelectorController()
//        monthSelectorController.calendar = calendar
//        daySelectorController.transitionToHorizontalSizeClass(currentSizeClass)
//        daySelectorController.updateStyle(style.daySelector)
//        daySelectorController.startDate = startDate
//        daySelectorController.delegate = self
        return monthSelectorController
    }
}


extension MonthHeaderView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // UIPageViewControllerDataSource
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let selector = viewController as? DaySelectorController {
            let previousDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selector.startDate)!
            return makeSelectorController() // previous
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let selector = viewController as? DaySelectorController {
            let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selector.startDate)!
            return makeSelectorController() // next
        }
        return nil
    }

    // MARK: UIPageViewControllerDelegate

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {return}
//        if let selector = pageViewController.viewControllers?.first as? DaySelectorController {
//            selector.selectedIndex = currentWeekdayIndex
//            if let selectedDate = selector.selectedDate {
//                state?.client(client: self, didMoveTo: selectedDate)
//            }
//        }
//        // Deselect all the views but the currently visible one
//        (previousViewControllers as? [DaySelectorController])?.forEach{$0.selectedIndex = -1}
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        (pendingViewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(style.daySelector)}
    }
}
