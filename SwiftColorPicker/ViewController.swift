//
//  ViewController.swift
//  SwiftColorPicker
//
//  Created by David Douglas on 5/19/23.
//

import UIKit

class ViewController: UIViewController, colorPanelDelegate {
    func updateColor(color: UIColor) {
        self.view.backgroundColor = color
    }
    
    private var colorPanel: ColorPanel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.colorPanel = ColorPanel(parent: self.view, frame: CGRect(x: self.view.center.x - 150, y: self.view.center.y - 150, width: 300, height: 300))
        self.colorPanel.delegate = self
        self.colorPanel.showColorPanel()

    }


}

