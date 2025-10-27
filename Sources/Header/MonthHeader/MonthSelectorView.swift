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
    private let totlaMonths: Int = 60 // <-12 to + 48>
    
    func prepareList(date: Date = Date()) {
        displayMonths.removeAll()
        let calendar = Calendar.current
        let lastMonth: Date = calendar.date(byAdding: .month, value: -12, to: date) ?? date
        for i in 0..<totlaMonths {
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

class MonthSelectorView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var monthButtons: [MonthButton] = []
    
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
        
        for (index, dtStr) in viewModel.displayMonths.enumerated() {
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


class MonthButton : UIView {
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor(hex: "#3F3F46")
        label.textAlignment = .center
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8, weight: .regular)
        label.textColor = UIColor(hex: "#3F3F46")
        label.textAlignment = .center
        return label
    }()
    
    var isSelected: Bool = false {
        didSet {
            monthLabel.textColor = isSelected ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#3F3F46")
            yearLabel.textColor = isSelected ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#3F3F46")
            self.backgroundColor = isSelected ? UIColor(hex: "#2E90FA") : .clear
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
        addSubview(yearLabel)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            yearLabel.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 2),
            yearLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            yearLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
//            yearLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//            yearLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        
        // Make clickable
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex: "#D0D5DD").cgColor
    }
    
    func configureMonth(_ month: String) {
        let arr = month.components(separatedBy: "-")
        monthLabel.text = arr.first
        yearLabel.text = arr.last
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
