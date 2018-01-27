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
    @IBOutlet weak var btnOption: UIButton!
    var delegate: NestedItemViewDelegate?
    var index = 0
    var stackIndex = 0
    
    @IBAction func btnOptionTap(_ sender: UIButton) {
        delegate?.nestedItemViewDidTapOption(itemIndex: index, stackIndex: stackIndex)
    }

}
