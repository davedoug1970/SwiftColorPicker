//
//  RGBPixel.swift
//  SwiftColorPicker
//
//  Created by David Douglas on 5/19/23.
//

import Foundation
import UIKit

struct RGBPixel {
    var r: CUnsignedChar
    var g: CUnsignedChar
    var b: CUnsignedChar
    
    init(r: CUnsignedChar, g: CUnsignedChar, b: CUnsignedChar) {
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(h: CGFloat, s: CGFloat, v: CGFloat) {
        
        let color = UIColor(hue: h, saturation: s, brightness: v, alpha: 1.0)
        let components = color.cgColor.components
        
        self.r = CUnsignedChar(0)
        self.g = CUnsignedChar(0)
        self.b = CUnsignedChar(0)
        
        if let components = components {
            if components.count > 2 {
                self.r = CUnsignedChar(components[0] * 255.0)
                self.g = CUnsignedChar(components[1] * 255.0)
                self.b = CUnsignedChar(components[2] * 255.0)
            }
        }
    }
}
