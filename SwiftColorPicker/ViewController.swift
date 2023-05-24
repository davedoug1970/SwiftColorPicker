//
//  ViewController.swift
//  SwiftColorPicker
//
//  Created by David Douglas on 5/19/23.
//

import UIKit

class ViewController: UIViewController {
    private var colorPanel: ColorPanel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.colorPanel = ColorPanel()
        self.colorPanel.delegate = self
    }
    
    @IBAction func showColorPicker(_ sender: Any) {
        self.colorPanel.showColorPanel()
    }
}

extension ViewController: colorPanelDelegate {
    func dismissColorPanel() {
        UIView.animate(withDuration: 0.6) {
            self.colorPanel.view.alpha = 0
        }
    }
    
    func colorChanged(color: UIColor) {
        self.view.backgroundColor = color
    }
}
