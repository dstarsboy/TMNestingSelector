//
//  NestingSelector.swift
//  FullPageNestingSelector
//
//  Created by Travis Ma on 1/17/18.
//  Copyright © 2018 Travis Ma. All rights reserved.
//

import UIKit

class NestedStackView: UIStackView {
    var constraintTop: NSLayoutConstraint?
    var constraintCenterY: NSLayoutConstraint?
    var constraintHeight: NSLayoutConstraint?
    
    func setUpAndConstrainToSuperView() {
        self.distribution = .equalSpacing
        self.alignment = .fill
        self.axis = .vertical
        self.translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            self.widthAnchor.constraint(equalToConstant: superview.frame.width)
            constraintTop = self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0)
            constraintTop?.isActive = false
            constraintCenterY = self.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: 0)
            constraintCenterY?.isActive = true
            constraintHeight = self.heightAnchor.constraint(equalToConstant: 128)
            constraintHeight?.isActive = true
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        }
    }
}

protocol NestingSelectorViewDelegate {
    func nestingSelector(_ nestingSelector: NestingSelectorView, viewFor dataItem: [String: Any]) -> UIView
    func viewForEntryItem(in nestingSelector: NestingSelectorView) -> UIView
    func viewForExitItem(in nestingSelector: NestingSelectorView) -> UIView
    func nestingSelector(_ nestingSelector: NestingSelectorView, didSelectFinalItem dataItem: [String: Any])
}

class NestingSelectorView: UIView {
    var scrollViews = [UIScrollView]()
    var dataTree = [[[String: Any]]]()
    var currentSelection = [String: Any]()
    var itemSize: CGSize!
    var horizontalSpacing: CGFloat = 0
    var mainConstraint: NSLayoutConstraint?
    var nestedKey: String!
    let kStackViewTag = 10
    var delegate: NestingSelectorViewDelegate?
    let kSpringDamping: CGFloat = 0.7
    let kSpringVelocity: CGFloat = 0.5
    
    func addScrollViewWithNoLeadingConstraintContainingStackView() -> (UIScrollView, NestedStackView) {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        let stackView = NestedStackView()
        scrollView.addSubview(stackView)
        stackView.setUpAndConstrainToSuperView()
        stackView.tag = kStackViewTag
        return (scrollView, stackView)
    }
    
    func itemRect() -> CGRect {
        return CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
    }
    
    func setup(data: [[String: Any]], nestedKey: String, itemSize: CGSize, delegate: NestingSelectorViewDelegate) {
        self.itemSize = itemSize
        self.nestedKey = nestedKey
        self.delegate = delegate
        let itemView = NestedItemView(frame: itemRect(), stackIndex: 0, itemIndex: 0)
        itemView.delegate = self
        let (scrollView, stackView) = addScrollViewWithNoLeadingConstraintContainingStackView()
        stackView.addArrangedSubview(itemView)
        itemView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
        if let topView = self.delegate?.viewForEntryItem(in: self) {
            itemView.addSubview(topView)
            topView.translatesAutoresizingMaskIntoConstraints = false
            topView.topAnchor.constraint(equalTo: itemView.topAnchor).isActive = true
            topView.leftAnchor.constraint(equalTo: itemView.leftAnchor).isActive = true
            topView.rightAnchor.constraint(equalTo: itemView.rightAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: itemView.bottomAnchor).isActive = true
        }
        let leading = (self.frame.width / 2) - (itemSize.width / 2)
        mainConstraint = scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading)
        mainConstraint?.isActive = true
        adjustStackConstraints(stackView: stackView, numberOfItems: 1)
        self.layoutIfNeeded()
        scrollView.contentSize = stackView.frame.size
        scrollViews.append(scrollView)
        loadNextStackView(data: data, delay: 1)
    }
    
    func loadFinalStackView() {
        let (scrollView, stackView) = addScrollViewWithNoLeadingConstraintContainingStackView()
        if let lastScrollView = scrollViews.last {
            if horizontalSpacing == 0 {
                horizontalSpacing = (self.frame.width - (itemSize.width * 3)) / 4
            }
            let leading = scrollView.leadingAnchor.constraint(equalTo: lastScrollView.trailingAnchor, constant: self.frame.width / 2)
            leading.isActive = true
            adjustStackConstraints(stackView: stackView, numberOfItems: 1)
            self.layoutIfNeeded()
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: kSpringDamping, initialSpringVelocity: kSpringVelocity, options: .curveEaseOut, animations: {
                leading.constant = self.horizontalSpacing
                self.layoutIfNeeded()
            }, completion: {
                _ in
                scrollView.contentSize = stackView.frame.size
            })
        }
        let itemView = NestedItemView(frame: itemRect(), stackIndex: -1, itemIndex: 0)
        itemView.delegate = self
        stackView.addArrangedSubview(itemView)
        itemView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
        if let topView = self.delegate?.viewForExitItem(in: self) {
            itemView.addSubview(topView)
            topView.translatesAutoresizingMaskIntoConstraints = false
            topView.topAnchor.constraint(equalTo: itemView.topAnchor).isActive = true
            topView.leftAnchor.constraint(equalTo: itemView.leftAnchor).isActive = true
            topView.rightAnchor.constraint(equalTo: itemView.rightAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: itemView.bottomAnchor).isActive = true
        }
        dataTree.append([[:]])
        scrollViews.append(scrollView)
    }
    
    func loadNextStackView(data: [[String: Any]], delay: TimeInterval) {
        let (scrollView, stackView) = addScrollViewWithNoLeadingConstraintContainingStackView()
        let stackIndex = scrollViews.count
        for i in 0 ..< data.count {
            let itemView = NestedItemView(frame: itemRect(), stackIndex: stackIndex, itemIndex: i)
            itemView.delegate = self
            stackView.addArrangedSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
            let h = itemView.heightAnchor.constraint(equalToConstant: itemSize.height)
            h.priority = .defaultHigh
            h.isActive = true
            if let topView = delegate?.nestingSelector(self, viewFor: data[i]) {
                itemView.addSubview(topView)
                topView.translatesAutoresizingMaskIntoConstraints = false
                topView.topAnchor.constraint(equalTo: itemView.topAnchor).isActive = true
                topView.leftAnchor.constraint(equalTo: itemView.leftAnchor).isActive = true
                topView.rightAnchor.constraint(equalTo: itemView.rightAnchor).isActive = true
                topView.bottomAnchor.constraint(equalTo: itemView.bottomAnchor).isActive = true
            }
        }
        if let lastScrollView = scrollViews.last {
            if horizontalSpacing == 0 {
                horizontalSpacing = (self.frame.width - (itemSize.width * 3)) / 4
            }
            let leading = scrollView.leadingAnchor.constraint(equalTo: lastScrollView.trailingAnchor, constant: self.frame.width / 2)
            leading.isActive = true
            adjustStackConstraints(stackView: stackView, numberOfItems: data.count)
            self.layoutIfNeeded()
            scrollView.contentSize = stackView.frame.size
            UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: kSpringDamping, initialSpringVelocity: kSpringVelocity, options: .curveEaseOut, animations: {
                leading.constant = self.horizontalSpacing
                self.layoutIfNeeded()
            }, completion: nil)
        }
        dataTree.append(data)
        scrollViews.append(scrollView)
    }
    
    func adjustStackConstraints(stackView: NestedStackView, numberOfItems: Int) {
        let newHeight = CGFloat(numberOfItems) * (itemSize.height + 10)
        if newHeight > self.frame.height {
            stackView.constraintCenterY?.isActive = false
            stackView.constraintTop?.isActive = true
        } else {
            stackView.constraintTop?.isActive = false
            stackView.constraintCenterY?.isActive = true
        }
        stackView.constraintHeight?.constant = newHeight
    }
    
}

extension NestingSelectorView: NestedItemViewDelegate {
    func nestedItemViewDidTapOption(itemIndex: Int, stackIndex: Int) {
        if stackIndex == -1 { //this the final selection
            delegate?.nestingSelector(self, didSelectFinalItem: currentSelection)
            return
        }
        if stackIndex == self.scrollViews.count - 2 { //skip tapping item if it's in the center column
            return
        }
        if stackIndex == scrollViews.count - 1 { //go forward
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: kSpringDamping, initialSpringVelocity: kSpringVelocity, options: .curveLinear, animations: {
                self.mainConstraint?.constant -= (self.itemSize.width + self.horizontalSpacing)
                if let lastScrollView = self.scrollViews.last, let lastStackView = lastScrollView.viewWithTag(self.kStackViewTag) as? NestedStackView {
                    for view in lastStackView.arrangedSubviews {
                        if let v = view as? NestedItemView {
                            if v.itemIndex != itemIndex {
                                v.isHidden = true
                                v.alpha = 0
                            }
                        }
                    }
                    self.adjustStackConstraints(stackView: lastStackView, numberOfItems: 1)
                    lastScrollView.contentSize = CGSize(width: lastScrollView.frame.width, height: self.itemSize.height)
                }
                self.layoutIfNeeded()
            }, completion: nil)
            guard let last = self.dataTree.last else {
                return
            }
            currentSelection = last[itemIndex]
            if let data = currentSelection[nestedKey] as? [[String: Any]], data.count > 0 {
                self.loadNextStackView(data: data, delay: 0)
            } else {
                self.loadFinalStackView()
            }
        } else { //go back
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: kSpringDamping, initialSpringVelocity: kSpringVelocity, options: .curveLinear, animations: {
                self.mainConstraint?.constant += (self.itemSize.width + self.horizontalSpacing)
                let lastScrollView = self.scrollViews[stackIndex + 1]
                if let lastStackView = lastScrollView.viewWithTag(self.kStackViewTag) as? NestedStackView {
                    self.adjustStackConstraints(stackView: lastStackView, numberOfItems: lastStackView.arrangedSubviews.count)
                    lastScrollView.contentSize = CGSize(width: lastScrollView.frame.width, height: CGFloat(lastStackView.arrangedSubviews.count) * (self.itemSize.height + 10))
                    self.layoutIfNeeded()
                    for view in lastStackView.arrangedSubviews {
                        if let v = view as? NestedItemView {
                            v.isHidden = false
                            v.alpha = 1
                        }
                    }
                }
                if let lastScrollView = self.scrollViews.last {
                    lastScrollView.alpha = 0
                }
            }, completion: {
                _ in
                if let lastScrollView = self.scrollViews.last {
                    lastScrollView.removeFromSuperview()
                }
                self.currentSelection = [:]
                self.dataTree.removeLast()
                self.scrollViews.removeLast()
            })
        }
    }
}
