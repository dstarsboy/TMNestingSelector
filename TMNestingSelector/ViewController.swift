//
//  ViewController.swift
//  FullPageNestingSelector
//
//  Created by Travis Ma on 1/17/18.
//  Copyright © 2018 Travis Ma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var nestingSelectorView: NestingSelectorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func generateTestJson(_ childCount: Int) -> [[String: Any]] {
        var data = [[String: Any]]()
        for a in 0 ..< childCount {
            var aData = [[String: Any]]()
            for b in 0 ..< childCount {
                var bData = [[String: Any]]()
                for c in 0 ..< childCount {
                    var cData = [[String: Any]]()
                    for d in 0 ..< childCount {
                        let dData = [[String: Any]]()
                        cData.append(
                            [
                                "name": "option \(d)",
                                "children": dData
                            ]
                        )
                    }
                    bData.append(
                        [
                            "name": "option \(c)",
                            "children": cData
                        ]
                    )
                }
                aData.append(
                    [
                        "name": "option \(b)",
                        "children": bData
                    ]
                )
            }
            data.append(
                [
                    "name": "option \(a)",
                    "children": aData
                ]
            )
        }
        return data
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var json: [[String: Any]]?
        if let path = Bundle.main.path(forResource: "MobileUserInfo", ofType: "json") {
            do {
                let fileData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: fileData, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: Any] {
                    json = jsonResult["territoryHierarchy"] as? [[String: Any]]
                }
            } catch {
                print(error)
            }
        }
        nestingSelectorView.setup(data: json ?? generateTestJson(10), nestedKey: "children", itemSize: CGSize(width: 240, height: 128), delegate: self)
    }
    
}

extension ViewController: NestingSelectorViewDelegate {
    func viewForEntryItem(in nestingSelector: NestingSelectorView) -> UIView {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }
    
    func viewForExitItem(in nestingSelector: NestingSelectorView) -> UIView {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }
    
    func nestingSelector(_ nestingSelector: NestingSelectorView, didSelectFinalItem dataItem: [String : Any]) {
        if let name = dataItem["name"] as? String {
            let alert = UIAlertController(title: "Selected!", message: "\(name)", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            )
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func nestingSelector(_ selector: NestingSelectorView, viewFor dataItem: [String : Any]) -> UIView {
        guard let myItemView = Bundle.main.loadNibNamed("MyItemView", owner: self, options: nil)?.first as? MyItemView else {
            preconditionFailure()
        }
        myItemView.labelTitle.text = dataItem["name"] as? String
        myItemView.imageViewArrow.isHidden = (dataItem["children"] as? [Any] ?? []).count == 0
        return myItemView
    }
    
}

