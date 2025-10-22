//
//  MonthHeaderView.swift
//  CalendarKit
//
//  Created by Prakash Jha on 17/09/25.
//

import UIKit


private extension MonthHeaderView {
    static let daySymbolsViewHeight: Double = 20
    static let monthSelectorViewHeight: Double = 60
}

class MonthHeaderView: CalHeaderView {
    private var monthSelectorView: MonthSelectorView
    private let viewModel = MonthSelectorViewModel() // common view model in between Months list at bottom and this view
   
    var totalHeight: Double {
        return 5 + MonthHeaderView.daySymbolsViewHeight + 5 + pagingScrollViewHeight + 5 + MonthHeaderView.monthSelectorViewHeight + 5
    }
    
    private var pagingScrollViewHeight: Double  = 205
    private var dateClickCompletion: ((Date?) -> Void)?
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = SystemColors.systemSeparator
        return separator
    }()
    
    override init(calendar: Calendar) {
        monthSelectorView = MonthSelectorView()
        super.init(calendar: calendar)
        configure()
    }
    
    public override func updateStyle(_ newStyle: DayHeaderStyle) {
        super.updateStyle(newStyle)
//        (pagingViewController.viewControllers as? [MonthSelectorController])?.forEach{$0.updateStyle(newStyle.daySelector)}
        backgroundColor = style.backgroundColor
        separator.backgroundColor = style.separatorColor
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        var yy: CGFloat = 5
        daySymbolsView.frame = CGRect(origin: CGPoint(x: 0, y: yy),
                                      size: CGSize(width: bounds.width, height: MonthHeaderView.daySymbolsViewHeight))
        
        yy += MonthHeaderView.daySymbolsViewHeight + 5
        pagingViewController.view?.frame = CGRect(origin: CGPoint(x: 0, y: yy),
                                                  size: CGSize(width: bounds.width, height: pagingScrollViewHeight))
        
        yy += self.pagingScrollViewHeight + 5
        monthSelectorView.frame = CGRect(origin: CGPoint(x: 0, y: yy),
                                         size: CGSize(width: bounds.width, height: MonthHeaderView.monthSelectorViewHeight))
        
        let separatorHeight = 1 / UIScreen.main.scale
        separator.frame = CGRect(origin: CGPoint(x: 0, y: bounds.height - separatorHeight),
                                 size: CGSize(width: bounds.width, height: separatorHeight))
    }
    
    public override func reloadDotsOnPage() {
        super.reloadDotsOnPage()
        guard let pageC = pagingViewController.viewControllers?.first as? MonthSelectorController else { return }
        pageC.reloadDots()
    }
    
    public override func reloadOnDateChange() {
        self.viewModel.calculateSelectedMonthIndex(date: selectedDate)
        self.monthSelectorView.updateSelectedMonth()
        configurePagingViewController()
        reloadDotsOnPage()
    }
    
    func setDateClickCompletion(_ block: @escaping (Date?) -> Void) {
        self.dateClickCompletion = block
    }
    
    private func selectedDayFor(index: Int) -> Int  {
        guard index >= 0 && index < viewModel.displayMonths.count else { return 0 }
        if viewModel.displayMonths[index] == selectedDate
            .stringWith(formate: MonthSelectorViewModel.storageFormate) {
            return Calendar.current.component(.day, from: selectedDate)
        }
        return 0
    }
}

private extension MonthHeaderView {
    func configure() {
        self.viewModel.prepareList(date: selectedDate)
        monthSelectorView.viewModel = self.viewModel
        [daySymbolsView, monthSelectorView, separator].forEach(addSubview)
        backgroundColor = style.backgroundColor
        configurePagingViewController()
        monthSelectorView.onChangeOfMonth = { [weak self] index in
            // scrol to selected month..
            self?.goToPage(index: index)
        }
    }
    
    func goToPage(index: Int, animated: Bool = true) {
        guard index >= 0, index < viewModel.displayMonths.count else { return }
        let vc = viewControllerAt(index: index)
        
        var direction: UIPageViewController.NavigationDirection = .forward
        if let visibleVC = self.pagingViewController.viewControllers?.first as? MonthSelectorController {
            direction = visibleVC.pageIndex > index ? .reverse : .forward
        }
        
        pagingViewController.setViewControllers([vc], direction: direction, animated: animated) { completed in
            if completed {
                self.updateHeightAsPerRow()
            }
        }
    }
}


private extension MonthHeaderView {
    func configurePagingViewController() {
        let monthSelectorController = viewControllerAt(index: self.viewModel.selectedMonthIndex)

        let leftToRight = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
        let direction: UIPageViewController.NavigationDirection = leftToRight ? .forward : .reverse

        pagingViewController.setViewControllers([monthSelectorController], direction: direction, animated: false, completion: nil)
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        addSubview(pagingViewController.view!)
        monthSelectorController.updateStyle(style.daySelector)
    }
    
    func viewControllerAt(index: Int) -> MonthSelectorController {
        let monthSelController = MonthSelectorController()
        monthSelController.delegate = self
        monthSelController.pageIndex = index
        monthSelController.selectedDateIndex = selectedDayFor(index: index)
        monthSelController.monthRepresentDate = viewModel.dateAtIndex(index)
        return monthSelController
    }
    
    func updateHeightAsPerRow() {
        var rCount = 5
        if let pageC = pagingViewController.viewControllers?.first as? MonthSelectorController {
            rCount = pageC.rowInLineCount
        }
       
        self.pagingScrollViewHeight = Double(40 * rCount) + 5
        self.layoutSubviews()
        self.headerDelegate?.refreshOnHeightChange()
        (pagingViewController.viewControllers as? [MonthSelectorController])?.forEach{$0.updateStyle(style.daySelector)}

    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension MonthHeaderView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // UIPageViewControllerDataSource
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let selector = viewController as? MonthSelectorController,
            selector.pageIndex > 0 else {
            return nil
        }
        
        return viewControllerAt(index: selector.pageIndex - 1) // previous
    }
    

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let selector = viewController as? MonthSelectorController,
              selector.pageIndex < self.viewModel.displayMonths.count - 1 else {
            return nil
        }
            
        let indx = selector.pageIndex + 1
        return viewControllerAt(index: indx) // next
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        (pendingViewControllers as? [MonthSelectorController])?.forEach{$0.updateStyle(style.daySelector)}
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
       
        guard completed, let currentVC = pageViewController.viewControllers?.first as? MonthSelectorController else { return }
        self.viewModel.selectedMonthIndex = currentVC.pageIndex
        self.monthSelectorView.updateSelectedMonth()
        self.updateHeightAsPerRow()
    }
}

// MARK: DaySelectorViewDelegate
extension MonthHeaderView : DaySelectorViewDelegate {
    public func dateSelectorDidSelectDate(_ date: Date) {
        print(date.stringWith(formate: "dd-MM-yyyy"))
        self.selectedDate = date
        self.dateClickCompletion?(date)
    }
    
    public func daySelectorShouldShowDotOn(date: Date) -> Bool {
        return self.headerDelegate?.shouldShowDotOn(date: date) ?? false
    }
}


// MARK: DayViewStateUpdating
extension MonthHeaderView: DayViewStateUpdating {
    public func move(from oldDate: Date, to newDate: Date) {
    }
}

