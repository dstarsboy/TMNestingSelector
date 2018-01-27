//
//  NestingSelector.swift
//  FullPageNestingSelector
//
//  Created by Travis Ma on 1/17/18.
//  Copyright © 2018 Travis Ma. All rights reserved.
//

import UIKit

class NestingSelectorView: UIView {
    var stackViews = [UIStackView]()
    var dataTree = [[[String: Any]]]()
    var itemSize = CGSize(width: 240, height: 128)
    var horizontalSpacing: CGFloat = 0
    var mainConstraint: NSLayoutConstraint?
    
    func setup(data: [[String: Any]]) {
        if let defaultView = Bundle.main.loadNibNamed("NestedItemView", owner: self, options: nil)?.first as? NestedItemView {
            defaultView.delegate = self
            defaultView.index = 0
            defaultView.stackIndex = 0
            defaultView.labelTitle.text = "Select a Territory"
            let defaultStack = UIStackView()
            defaultStack.distribution = .equalSpacing
            defaultStack.alignment = .fill
            defaultStack.axis = .vertical
            defaultStack.addArrangedSubview(defaultView)
            self.addSubview(defaultStack)
            defaultStack.translatesAutoresizingMaskIntoConstraints = false
            defaultStack.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
            let height = defaultStack.heightAnchor.constraint(equalToConstant: itemSize.height)
            height.isActive = true
            let leading = (self.frame.width / 2) - (itemSize.width / 2)
            mainConstraint = defaultStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading)
            mainConstraint?.isActive = true
            defaultStack.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
            stackViews.append(defaultStack)
        }
        loadNextStackView(data: data, delay: 1)
    }
    
    func loadNextStackView(data: [[String: Any]], delay: TimeInterval) {
        dataTree.append(data)
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
//        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        let stackView = UIStackView()
        let stackIndex = stackViews.count
        stackView.tag = stackIndex
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.axis = .vertical
        self.addSubview(stackView)
        if let lastStackView = stackViews.last {
            if horizontalSpacing == 0 {
                print("\(self.frame.width)")
                horizontalSpacing = (self.frame.width - (itemSize.width * 3)) / 4
            }
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
            let height = stackView.heightAnchor.constraint(equalToConstant: CGFloat(data.count) * (itemSize.height + 10))
            height.priority = .defaultLow
            height.isActive = true
            height.identifier = "StackViewHeight"
            let leading = stackView.leadingAnchor.constraint(equalTo: lastStackView.trailingAnchor, constant: self.frame.width / 2)
            leading.isActive = true
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
            self.layoutIfNeeded()
            UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                leading.constant = self.horizontalSpacing
                self.layoutIfNeeded()
            }, completion: nil)
        }
        for i in 0 ..< data.count {
            if let itemView = Bundle.main.loadNibNamed("NestedItemView", owner: self, options: nil)?.first as? NestedItemView {
                let item = data[i]
                itemView.labelTitle.text = item["name"] as? String
                itemView.delegate = self
                itemView.index = i
                itemView.stackIndex = stackIndex
                itemView.imageViewArrow.isHidden = (item["children"] as? [Any] ?? []).count == 0
                stackView.addArrangedSubview(itemView)
                itemView.translatesAutoresizingMaskIntoConstraints = false
                itemView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
                let h = itemView.heightAnchor.constraint(equalToConstant: itemSize.height)
                h.priority = .defaultLow
                h.isActive = true
            }
        }
        stackViews.append(stackView)
    }
    
}

extension NestingSelectorView: NestedItemViewDelegate {
    func nestedItemViewDidTapOption(itemIndex: Int, stackIndex: Int) {
        if stackIndex == self.stackViews.count - 2 {
            return
        }
        if stackIndex == stackViews.count - 1 {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.mainConstraint?.constant -= (self.itemSize.width + self.horizontalSpacing)
                if let lastStackView = self.stackViews.last {
                    for view in lastStackView.arrangedSubviews {
                        if let v = view as? NestedItemView {
                            if v.index != itemIndex {
                                v.isHidden = true
                                v.alpha = 0
                            }
                        }
                    }
                    if let index = lastStackView.constraints.index(where: { $0.identifier == "StackViewHeight" }) {
                        lastStackView.constraints[index].constant = self.itemSize.height
                    }
                }
                self.layoutIfNeeded()
            }, completion: nil)
            if let last = self.dataTree.last, let data = last[itemIndex]["children"] as? [[String: Any]] {
                self.loadNextStackView(data: data, delay: 0)
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.mainConstraint?.constant += (self.itemSize.width + self.horizontalSpacing)
                let lastStackView = self.stackViews[stackIndex + 1]
                if let index = lastStackView.constraints.index(where: { $0.identifier == "StackViewHeight" }) {
                    lastStackView.constraints[index].constant = CGFloat(lastStackView.arrangedSubviews.count) * (self.itemSize.height + 10)
                }
                self.layoutIfNeeded()
                for view in lastStackView.arrangedSubviews {
                    if let v = view as? NestedItemView {
                        v.isHidden = false
                        v.alpha = 1
                    }
                }
            }, completion: {
                _ in
                if let lastStackView = self.stackViews.last {
                    lastStackView.removeFromSuperview()
                }
                self.dataTree.removeLast()
                self.stackViews.removeLast()
            })
        }
    }
}
