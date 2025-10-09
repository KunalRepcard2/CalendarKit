//
//  UIViewExtn.swift
//  CalendarKit
//
//  Created by Prakash Jha on 09/10/25.
//

import UIKit

extension UIView  {
    func addDotTag(_ add: Bool,  color: UIColor) {
        self.removeDotTag()
        if !add { return }
        
        let dotView = UIView()
        dotView.backgroundColor = color
        dotView.layer.cornerRadius = 2
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.tag = 67890
        // Add dot inside the label
        self.addSubview(dotView)
        
        NSLayoutConstraint.activate([
            dotView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dotView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5), // little below
            dotView.widthAnchor.constraint(equalToConstant: 4),
            dotView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func removeDotTag() {
        if let tagV = self.viewWithTag(67890) {
            tagV.removeFromSuperview()
        }
    }
}


extension UIView {
    // with stick width.
    func circular(border: CGFloat, color: UIColor?) {
        self.roundWith(border: border, color: color, rad: self.bounds.size.height/2.0)
    }
    
    func roundWith(border: CGFloat, color: UIColor?, rad: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = rad
        self.clipsToBounds = true
        
        self.layer.borderWidth = border
        if color != nil {
            self.layer.borderColor = color?.cgColor
        }
    }
}
