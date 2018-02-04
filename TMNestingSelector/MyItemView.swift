//
//  MyItemView.swift
//  TMNestingSelector
//
//  Created by Travis Ma on 2/3/18.
//  Copyright © 2018 Travis Ma. All rights reserved.
//

import UIKit

class MyItemView: UIView {
    @IBOutlet weak var viewIconArea: UIView!
    @IBOutlet weak var viewTitleArea: UIView!
    @IBOutlet weak var imageViewType: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewIconArea.layer.cornerRadius = viewIconArea.frame.width / 2
        viewIconArea.layer.masksToBounds = true
        viewTitleArea.layer.cornerRadius = 12
        viewTitleArea.layer.borderColor = viewIconArea.backgroundColor?.cgColor
        viewTitleArea.layer.borderWidth = 1
        imageViewType.tintColor = .white
        imageViewType.backgroundColor = .clear
    }
}
