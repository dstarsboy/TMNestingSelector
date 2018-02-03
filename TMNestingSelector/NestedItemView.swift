//
//  NestedItemView.swift
//  FullPageNestingSelector
//
//  Created by Travis Ma on 1/17/18.
//  Copyright © 2018 Travis Ma. All rights reserved.
//

import UIKit

protocol NestedItemViewDelegate {
    func nestedItemViewDidTapOption(itemIndex: Int, stackIndex: Int)
}

class NestedItemView: UIView {
    var delegate: NestedItemViewDelegate?
    var itemIndex = 0
    var stackIndex = 0
    
    init(frame: CGRect, stackIndex: Int, itemIndex: Int) {
        super.init(frame: frame)
        self.itemIndex = itemIndex
        self.stackIndex = stackIndex
        self.backgroundColor = .blue
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.optionTap))
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func optionTap() {
        delegate?.nestedItemViewDidTapOption(itemIndex: itemIndex, stackIndex: stackIndex)
    }

}
