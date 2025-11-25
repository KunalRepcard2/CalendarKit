//
//  MonthSelectorView.swift
//  CalendarKit
//
//  Created by Prakash Jha on 18/09/25.
//
import UIKit

// only for month boxes
public class MonthSelectorViewModel {
    public private(set) var displayMonths = [String]()
    public static let storageFormate = "MMM-yyyy" // e.g. Jan, Feb, Mar
    public var selectedMonthIndex: Int = -1
    private let totalMonths: Int = 96 // <-12 to + 48> 75
    private let startMonth: Int = -24
    
    public func prepareList(date: Date = Date()) {
        displayMonths.removeAll()
        let calendar = Calendar.current
        let lastMonth: Date = calendar.date(byAdding: .month, value: startMonth, to: date) ?? date
        for i in 0..<totalMonths {
            if let nextMonth = calendar.date(byAdding: .month, value: i, to: lastMonth) {
                let dtStr = nextMonth.stringWith(formate: MonthSelectorViewModel.storageFormate)
                displayMonths.append(dtStr)
            }
        }
    }
     
    public func calculateSelectedMonthIndex(date: Date) {
        let calendar = Calendar.current
        guard let aDt = calendar.date(byAdding: .month, value: 0, to: date) else {
            selectedMonthIndex = -1
            return
        }

        let dtStr = aDt.stringWith(formate: MonthSelectorViewModel.storageFormate)
        print("Month selector - > \(dtStr)")
        let indx = displayMonths.firstIndex(of: dtStr) ?? -1
        selectedMonthIndex = indx
    }
    
    public func dateAtIndex(_ index: Int) -> Date {
        guard index >= 0 && index < displayMonths.count else { return Date() }
        return Date.dateFrom(string: displayMonths[index],
                             formate: MonthSelectorViewModel.storageFormate) ?? Date()
    }
}

// MARK: - MonthSelectorView
public class MonthSelectorView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var monthButtons: [MonthButton] = []
    private var yearsLabels: [YearLabel] = []
    
    public var viewModel = MonthSelectorViewModel() {
        didSet {
            self.addMonthsButtons()
        }
    }
    
    private let buttonSize: CGSize = CGSize(width: 65, height: 40)
    
    public func updateSelectedMonth() {
        self.updateSelection()
        self.scrollToSelectedMonth()
    }
    
    public var onChangeOfMonth: ((_ index: Int) -> Void)? // 1-month-year
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func scrollToSelectedMonth() {
        self.scrollToMonth(at: viewModel.selectedMonthIndex)
    }
}

private extension MonthSelectorView {
    func setupView() {
        // ScrollView setup
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // StackView setup
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12), // ✅ Needed!
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    func addMonthsButtons() {
        monthButtons.forEach{$0.removeFromSuperview()}
        monthButtons.removeAll()
        
        yearsLabels.forEach{$0.removeFromSuperview()}
        yearsLabels.removeAll()
        
        var lastYear = viewModel.displayMonths[0].components(separatedBy: "-").last ?? ""
        
        for (index, dtStr) in viewModel.displayMonths.enumerated() {
            // check and add Year.
            let anYear = dtStr.components(separatedBy: "-").last ?? ""
            if anYear != "", anYear != lastYear {
                let yrLabel = YearLabel()
                yrLabel.configure(year: anYear)
                yearsLabels.append(yrLabel)
                
                yrLabel.translatesAutoresizingMaskIntoConstraints = false
                yrLabel.setContentHuggingPriority(.required, for: .horizontal)
                yrLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: buttonSize.width).isActive = true
                yrLabel.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true
                stackView.addArrangedSubview(yrLabel)
                
                lastYear = anYear
            }
            
            
            let monthView = MonthButton()
            monthView.configureMonth(dtStr)
            monthView.tag = index
            monthView.onMonthButtonTap = {
                print("Tapped: \(dtStr)  - \(index)")
                self.viewModel.selectedMonthIndex = index
                self.updateSelectedMonth()
                self.onChangeOfMonth?(index)
            }
            
            monthView.setContentHuggingPriority(.required, for: .horizontal)
            monthView.widthAnchor.constraint(greaterThanOrEqualToConstant: buttonSize.width).isActive = true
            monthView.heightAnchor.constraint(equalToConstant: buttonSize.height).isActive = true

            
            monthButtons.append(monthView)
            stackView.addArrangedSubview(monthView)
            
            updateSelection()
        }
    }
    
    
   
    
    private func scrollToMonth(at index: Int, animated: Bool = true) {
        guard index >= 0, index < monthButtons.count else { return }
        
        let targetView = monthButtons[index]
        let targetFrame = targetView.frame
        
        // Scroll so that target is visible (with some padding if you like)
        scrollView.scrollRectToVisible(targetFrame.insetBy(dx: -16, dy: 0), animated: animated)
    }
    
    func updateSelection() {
        for (index, monthBtn) in monthButtons.enumerated() {
            monthBtn.isSelected = index == viewModel.selectedMonthIndex
        }
    }
}



// MARK: - MonthButton
public class MonthButton : UIView {
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor(hex: "3F3F46")
        label.textAlignment = .center
        return label
    }()
    
    public var isSelected: Bool = false {
        didSet {
            monthLabel.textColor = isSelected ? UIColor(hex: "FFFFFF") : UIColor(hex: "3F3F46")
            self.backgroundColor = isSelected ? UIColor(hex: "2E90FA") : .clear
            self.layer.borderColor = isSelected ? UIColor(hex: "2E90FA").cgColor : UIColor(hex: "D0D5DD").cgColor
        }
    }
    
    public var onMonthButtonTap: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        // Make clickable
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex: "D0D5DD").cgColor
    }
    
    public func configureMonth(_ month: String) {
        let arr = month.components(separatedBy: "-")
        monthLabel.text = arr.first
    }
    
    @objc private func handleTap() {
        self.monthLabel.alpha = 0.5
        self.backgroundColor = .gray.withAlphaComponent(0.3)
        onMonthButtonTap?()
        
        // reset after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.monthLabel.alpha = 1.0
        }
    }
}


// MARK: - YearLabel
public class YearLabel: UIView {
    
    private let yrLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor(hex: "2E90FA")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leftLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "E4E4E7")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rightLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "E4E4E7")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(leftLine)
        addSubview(rightLine)
        addSubview(yrLabel)
        
        NSLayoutConstraint.activate([
            // Center label
            yrLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            yrLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            yrLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            yrLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            
            // Left vertical line
            leftLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftLine.widthAnchor.constraint(equalToConstant: 1),
            leftLine.heightAnchor.constraint(equalTo: heightAnchor),
            
            // Right vertical line
            rightLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightLine.widthAnchor.constraint(equalToConstant: 1),
            rightLine.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
    
    public func configure(year: String) {
        yrLabel.text = year
    }
    
    public override var intrinsicContentSize: CGSize {
        let labelSize = yrLabel.intrinsicContentSize
        return CGSize(width: labelSize.width + 24, height: labelSize.height + 8)
    }
}

