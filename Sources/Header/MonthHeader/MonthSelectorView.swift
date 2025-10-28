//
//  MonthSelectorView.swift
//  CalendarKit
//
//  Created by Prakash Jha on 18/09/25.
//
import UIKit

// only for month boxes
class MonthSelectorViewModel {
    private(set) var displayMonths = [String]()
    static let storageFormate = "MMM-yyyy" // e.g. Jan, Feb, Mar
    var selectedMonthIndex: Int = -1
    private let totalMonths: Int = 72 // <-12 to + 48>
    private let startMonth: Int = -24
    
    func prepareList(date: Date = Date()) {
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
     
    func calculateSelectedMonthIndex(date: Date) {
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
    
    func dateAtIndex(_ index: Int) -> Date {
        guard index >= 0 && index < displayMonths.count else { return Date() }
        return Date.dateFrom(string: displayMonths[index],
                             formate: MonthSelectorViewModel.storageFormate) ?? Date()
    }
}

// MARK: - MonthSelectorView
class MonthSelectorView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var monthButtons: [MonthButton] = []
    private var yearsLabels: [UILabel] = []
    
    var viewModel = MonthSelectorViewModel() {
        didSet {
            self.addMonthsButtons()
        }
    }
    
    private let buttonSize: CGSize = CGSize(width: 65, height: 40)
    
    func updateSelectedMonth() {
        self.updateSelection()
        self.scrollToMonth(at: viewModel.selectedMonthIndex)
    }
    
    var onChangeOfMonth: ((_ index: Int) -> Void)? // 1-month-year
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
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
    
    private func addMonthsButtons() {
        monthButtons.forEach{$0.removeFromSuperview()}
        monthButtons.removeAll()
        
        yearsLabels.forEach{$0.removeFromSuperview()}
        yearsLabels.removeAll()
        
        var lastYear = viewModel.displayMonths[0].components(separatedBy: "-").last ?? ""
        
        for (index, dtStr) in viewModel.displayMonths.enumerated() {
            // check and add Year.
            let anYear = dtStr.components(separatedBy: "-").last ?? ""
            if anYear != "", anYear != lastYear {
                let yrLabel = UILabel()
                yrLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                yrLabel.textColor = UIColor(hex: "3F3F46")
                yrLabel.textAlignment = .center
                yrLabel.text = anYear
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
    
    func scrollToMonth(at index: Int, animated: Bool = true) {
        guard index >= 0, index < monthButtons.count else { return }
        
        let targetView = monthButtons[index]
        let targetFrame = targetView.frame
        
        // Scroll so that target is visible (with some padding if you like)
        scrollView.scrollRectToVisible(targetFrame.insetBy(dx: -16, dy: 0), animated: animated)
    }
    
    private func updateSelection() {
        for (index, monthBtn) in monthButtons.enumerated() {
            monthBtn.isSelected = index == viewModel.selectedMonthIndex
        }
    }
}



// MARK: - MonthButton
class MonthButton : UIView {
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor(hex: "3F3F46")
        label.textAlignment = .center
        return label
    }()
    
    var isSelected: Bool = false {
        didSet {
            monthLabel.textColor = isSelected ? UIColor(hex: "FFFFFF") : UIColor(hex: "3F3F46")
            self.backgroundColor = isSelected ? UIColor(hex: "2E90FA") : .clear
            self.layer.borderColor = isSelected ? UIColor(hex: "2E90FA").cgColor : UIColor(hex: "D0D5DD").cgColor
        }
    }
    
    var onMonthButtonTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
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
    
    func configureMonth(_ month: String) {
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
