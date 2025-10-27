//
//  QuickFilterView.swift
//  CalendarKit
//
//  Created by Prakash Jha on 22/10/25.
//

import UIKit

public final class QuickFilterView: UIView {

    public enum FilterType: Int, CaseIterable {
        case all, mine, unassigned
        
        func titleWith(count: Int) -> String {
            switch self {
            case .all: return "All Appts(\(count))"
            case .mine: return "My Appts(\(count))"
            case .unassigned: return "Unassigned(\(count))"
            }
        }
    }

    private var buttons: [UIButton] = []
    public var selectedFilter: FilterType = .all {
        didSet { updateSelection() }
    }
    
    public var onSelectionChanged: ((FilterType) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func updateCounts(_ numbers: [Int]) {
        let allFilters = FilterType.allCases
        for button in buttons {
            if allFilters.count > button.tag, numbers.count > button.tag {
                let filter = FilterType.allCases[button.tag]
                button.setTitle(filter.titleWith(count: numbers[button.tag]), for: .normal)
            }
        }
    }

    private func setupView() {
        backgroundColor = .clear
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
        // Create buttons
        for (index, filter) in FilterType.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(filter.titleWith(count: 0), for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            button.layer.cornerRadius = 12
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
            buttons.append(button)
        }
        
        updateSelection()
    }

    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            let filter = FilterType(rawValue: index)!
            if filter == selectedFilter {
                button.setTitleColor(.systemBlue, for: .normal)
                button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.clear.cgColor
            } else {
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .clear
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor(hex: "E4E4E7").cgColor
            }
        }
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let newFilter = FilterType(rawValue: sender.tag) else { return }
        selectedFilter = newFilter
        onSelectionChanged?(newFilter)
    }
}
