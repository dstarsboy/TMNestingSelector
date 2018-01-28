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
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewArrow: UIImageView!
    var delegate: NestedItemViewDelegate?
//    let itemIndex: Int
//    let stackIndex: Int
    var itemIndex = 0
    var stackIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.optionTap))
        self.addGestureRecognizer(tapGesture)
    }
    
//    init(frame: CGRect, stackIndex: Int, itemIndex: Int) {
//        self.itemIndex = itemIndex
//        self.stackIndex = stackIndex
//        super.init(frame: frame)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    @objc func optionTap() {
        delegate?.nestedItemViewDidTapOption(itemIndex: itemIndex, stackIndex: stackIndex)
    }

}
