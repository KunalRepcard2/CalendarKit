//
//  MonthDaySelectorView.swift
//  CalendarKit
//
//  Created by Prakash Jha on 18/09/25.
//

import UIKit

class MonthDaySelectorView: UIView {
    private var rows : [MonthCalDateCellView] = []
    var totalHeight: CGFloat = 0
    var selectedDate: Date?
    
    private var month = 1
    private var year = 2025
    private var daysInMonth: Int = 30
    
    private let cellSize: CGFloat = 40
    
    private var emptyDaysBeforeFirstDay : Int = 0 // begin from sun
    var dateClickCompletion: ((Date?) -> Void)?
    
    var monthRepresentDate: Date = Date() {
        didSet{
            self.configureDate()
        }
    }
    
    func configureDate() {
        let aDate = monthRepresentDate
        let touple = aDate.monthIndexAndYear()
        self.month = touple.month
        self.year = touple.year
        self.daysInMonth = aDate.numberOfDaysInMonth() ?? 30
        self.emptyDaysBeforeFirstDay = Date.dateFrom(string: "1-\(self.month)-\(self.year)", formate: "dd-MM-yyyy")?.weekdayIndex() ?? 0
        self.initializeViews()
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        initializeViews()
    }
    
    @objc private func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view as? MonthCalDateCellView {
            dateClickCompletion?(Date.dateFrom(string: "\(cell)-\(month)-\(year)", formate: "dd-mm-yyyy"))
        }
    }
    
    private func initializeViews() {
        // Store last selected date
//        let lastSelectedDate = selectedDate
        
        // Remove previous Items
        rows.forEach{$0.removeFromSuperview()}
        rows.removeAll()
        
        // Create new with corresponding class
        for i in 1...daysInMonth {
            let cell = MonthCalDateCellView()
            cell.dayNumber = i
            //Date.dateFrom(string: "\(i)-\(month)-\(year)", formate: "dd-mm-yyyy") ?? Date()
            rows.append(cell)
            addSubview(cell)
            cell.updateState()
            
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(MonthDaySelectorView.dateLabelDidTap(_:)))
            cell.addGestureRecognizer(recognizer)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let accpiedW = cellSize * 7
        let gap = (frame.width -  accpiedW) / CGFloat(8) // counted 6 + start + end
        
        let max = daysInMonth + emptyDaysBeforeFirstDay
        
            
        let emptyXMargin = CGFloat(CGFloat(cellSize) + gap) * CGFloat(emptyDaysBeforeFirstDay)
        var xx = emptyXMargin + gap
        var yy: CGFloat = 5.0
        let sz = CGSize(width: cellSize, height: cellSize)
        
//        var weekIndx = emptyDaysBeforeFirstDay
        for indx in 0..<rows.count {
            let cellV = rows[indx]
            
            cellV.frame = CGRect(origin: CGPoint(x: xx, y: yy), size: sz)
            xx += cellSize + gap
            
            let weekIndx = indx + emptyDaysBeforeFirstDay // add gap from start
            
            if weekIndx > 0, (weekIndx) % 7 == 0 { // last row reset
                xx = gap
                yy += cellSize
            }
        }
    }
}

class MonthCalDateCellView: UILabel {
    private var style = DaySelectorStyle()
    
    var isSelected = false
    var isToday = false
    var isWeekend = false
    var showDot: Bool = false {
        didSet {
            addDotTag(showDot, color: isSelected ? style.selectedDotColor : style.dotColor)
        }
    }
    
    var dayNumber: Int = 0 {
        didSet {
            text = "\(dayNumber)"
        }
    }

    func updateState() {
        let today = isToday
        if isSelected {
            font = style.todayFont
            textColor = today ? style.todayActiveTextColor : style.activeTextColor
            backgroundColor = today ? style.todayActiveBackgroundColor : style.selectedBackgroundColor
        } else {
            let notTodayColor = isWeekend ? style.weekendTextColor : style.inactiveTextColor
            font = style.font
            textColor = today ? style.todayInactiveTextColor : notTodayColor
            backgroundColor = style.inactiveBackgroundColor
        }
    }
    
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
}
