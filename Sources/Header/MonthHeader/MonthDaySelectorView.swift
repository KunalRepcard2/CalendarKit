//
//  MonthDaySelectorView.swift
//  CalendarKit
//
//  Created by Prakash Jha on 18/09/25.
//

import UIKit

public class MonthDaySelectorView: CalHeaderDaySelecterView {
    private var rows : [MonthCalDateCellLabel] = []
    private(set) var month = 1
    private(set) var year = 2025
    private var daysInMonth: Int = 30
    private let cellSize: CGFloat = 40
    private var emptyDaysBeforeFirstDay : Int = 0 // begin from sun
    private var style = DaySelectorStyle()

    var selectedDateIndex: Int = 1
    private(set) var rowInLineCount: Int = 5
    
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
    
    public init() {
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
    
    public func updateStyle(_ newStyle: DaySelectorStyle) {
        style = newStyle
        rows.filter({$0.isSelected}).forEach{$0.updateStyle(style)}
    }
    
    private func dateWith(day: Int) -> Date? {
       return Date.dateFrom(string: "\(day)-\(month)-\(year)", formate: "dd-MM-yyyy")
    }
    
    @objc public func dateLabelDidTap(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view as? MonthCalDateCellLabel,
          let aDate = dateWith(day: cell.dayNumber) {
            self.delegate?.dateSelectorDidSelectDate(aDate, isManualMove: false)
        }
    }
    
    public func manualDateTap(aDate: Date) {
        self.delegate?.dateSelectorDidSelectDate(aDate, isManualMove: false)
    }
    
    private func initializeViews() {
        // Remove previous Items
        rows.forEach { $0.removeFromSuperview() }
        rows.removeAll()
        
        // Create new with corresponding class
        for i in 1...daysInMonth {
            let cell = MonthCalDateCellLabel.cellWith(day: i, month: month, year: year,
                                                      selected: i == selectedDateIndex)
            rows.append(cell)
            addSubview(cell)

            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(MonthDaySelectorView.dateLabelDidTap(_:)))
            cell.addGestureRecognizer(recognizer)
        }
        
        reloadDots()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let cellW = frame.width/7 // devide the width in 7 parts
            
        let emptyXMargin = cellW * CGFloat(emptyDaysBeforeFirstDay)
        var xx = emptyXMargin
        var yy: CGFloat = 5.0
        let sz = CGSize(width: cellSize, height: cellSize)
        
        var inlineR = 1
        for indx in 0..<rows.count {
            let cellV = rows[indx]
            let xVal = xx + (cellW - cellSize) / 2.0 // add margin half of the gap
            cellV.frame = CGRect(origin: CGPoint(x: xVal, y: yy), size: sz)
            xx += cellW
            
            let weekIndx = indx + emptyDaysBeforeFirstDay + 1 // add gap from start
            
            if weekIndx > 0, (weekIndx) % 7 == 0 { // last row reset
                xx = 0
                yy += cellSize
                inlineR += 1
            }
        }
        rowInLineCount = inlineR
    }
    
    func reloadDots() {
        rows.forEach {
            if let aDate = dateWith(day: $0.dayNumber) {
                $0.showDot = self.delegate?.daySelectorShouldShowDotOn(date:aDate) ?? false
            } else {
                $0.showDot = false
            }
        }
    }
}

