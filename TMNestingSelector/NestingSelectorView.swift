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

//protocol NestingSelectorViewDelegate {
//    func nestingSelector(_ selector: NestingSelectorView, viewFor dataItem: [String: Any]) -> UIView
//}

class NestingSelectorView: UIView {
    var scrollViews = [UIScrollView]()
    var dataTree = [[[String: Any]]]()
    var itemSize: CGSize!
    var horizontalSpacing: CGFloat = 0
    var mainConstraint: NSLayoutConstraint?
    var nestedKey: String!
    let kStackViewTag = 10
    var isSetup = false
    //var delegate: NestingSelectorViewDelegate?
    
    func addScrollViewWithNoLeadingConstraintContainingStackView() -> (UIScrollView, NestedStackView) {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        //scrollView.backgroundColor = .red
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
    
    func setup(data: [[String: Any]], nestedKey: String, itemSize: CGSize) {
        isSetup = true
        self.itemSize = itemSize
        self.nestedKey = nestedKey
        //self.delegate = delegate
        if let defaultView = Bundle.main.loadNibNamed("NestedItemView", owner: self, options: nil)?.first as? NestedItemView {
            defaultView.delegate = self
            defaultView.itemIndex = 0
            defaultView.stackIndex = 0
            defaultView.labelTitle.text = "Select a Territory"
            let (scrollView, stackView) = addScrollViewWithNoLeadingConstraintContainingStackView()
            stackView.addArrangedSubview(defaultView)
            defaultView.translatesAutoresizingMaskIntoConstraints = true
            defaultView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
            let leading = (self.frame.width / 2) - (itemSize.width / 2)
            mainConstraint = scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading)
            mainConstraint?.isActive = true
            self.layoutIfNeeded()
            scrollView.contentSize = stackView.frame.size
            scrollViews.append(scrollView)
        }
        loadNextStackView(data: data, delay: 1)
    }
    
    func loadNextStackView(data: [[String: Any]], delay: TimeInterval) {
        dataTree.append(data)
        let (scrollView, stackView) = addScrollViewWithNoLeadingConstraintContainingStackView()
        let stackIndex = scrollViews.count
        if let lastScrollView = scrollViews.last {
            if horizontalSpacing == 0 {
                horizontalSpacing = (self.frame.width - (itemSize.width * 3)) / 4
            }
            let leading = scrollView.leadingAnchor.constraint(equalTo: lastScrollView.trailingAnchor, constant: self.frame.width / 2)
            leading.isActive = true
            adjustStackConstraints(stackView: stackView, numberOfItems: data.count)
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            self.layoutIfNeeded()
            UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                leading.constant = self.horizontalSpacing
                self.layoutIfNeeded()
            }, completion: {
                _ in
                scrollView.contentSize = stackView.frame.size
            })
        }
        for i in 0 ..< data.count {
            if let itemView = Bundle.main.loadNibNamed("NestedItemView", owner: self, options: nil)?.first as? NestedItemView {
                let item = data[i]
                itemView.labelTitle.text = item["name"] as? String
                itemView.delegate = self
                itemView.itemIndex = i
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
        if stackIndex == self.scrollViews.count - 2 { //skip tapping item if it's in the center column
            return
        }
        if stackIndex == scrollViews.count - 1 { //go forward
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
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
            if let last = self.dataTree.last, let data = last[itemIndex][nestedKey] as? [[String: Any]] {
                self.loadNextStackView(data: data, delay: 0)
            } else {
                //load last button
            }
        } else { //go back
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
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
                self.dataTree.removeLast()
                self.scrollViews.removeLast()
            })
        }
    }
}
