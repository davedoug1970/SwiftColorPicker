//
//  ColorWheel.swift
//  SwiftColorPicker
//
//  Created by David Douglas on 5/19/23.
//

import UIKit

struct ColorWheel {
    private var hueImage:CGImage? = nil
    private var hueImageData:UnsafeMutablePointer<RGBPixel>? = nil
    private var hueImageDataLength:Int = 0
    private var hueRadius:Int = 0
    private var satImage:CGImage? = nil
    private var satImageData:UnsafeMutablePointer<RGBPixel>? = nil
    private var satImageDataLength:Int = 0
    private var satRadius:Int = 0
    
    func getImage() -> UIImage? {
        if let image = self.hueImage {
            return UIImage(cgImage: image)
        }
        
        return nil
    }
    
    func getSatImage() -> UIImage? {
        if let image = self.satImage {
            return UIImage(cgImage: image)
        }
        
        return nil
    }
    
    mutating func generateHueImage(size: CGSize) {
        guard size.width > 0 &&
                size.height > 0 else {
            return
        }

        self.hueRadius = Int(size.width/2)
                
        if self.hueImage != nil {
            self.hueImage = nil
        }
        
        let width = self.hueRadius * 2
        let height = width
        
        let dataLength = MemoryLayout<RGBPixel>.size * width * height
        
        if (dataLength != hueImageDataLength) {
            if hueImageData != nil {
                hueImageData?.deallocate()
            }
            
            hueImageData = UnsafeMutablePointer.allocate(capacity: dataLength)
            hueImageDataLength = dataLength
        }
        
        for y in 0...height {
            for x in 0...width {
                hueImageData![x + y * width] = colorAtPoint(point: CGPoint(x: x, y: y))
            }
        }
        
        let ref = CGDataProvider(dataInfo: nil, data: hueImageData!, size: dataLength) { umrp, urp, length in }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
    
        self.hueImage = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: width * 3, space: colorSpace, bitmapInfo: .byteOrderDefault, provider: ref!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        

    }
    
    mutating func generateSatImage(size: CGSize, hue: CGFloat) {
        guard size.width > 0 &&
                size.height > 0 else {
            return
        }

        self.satRadius = Int(size.width/2)
                
        if self.satImage != nil {
            self.satImage = nil
        }
        
        let width = Int(size.width)
        let height = width
        
        let dataLength = MemoryLayout<RGBPixel>.size * width * height
        
        if (dataLength != satImageDataLength) {
            if satImageData != nil {
                satImageData?.deallocate()
            }
            
            satImageData = UnsafeMutablePointer.allocate(capacity: dataLength)
            satImageDataLength = dataLength
        }
        
        for y in 0...height {
            for x in 0...width {
                satImageData![x + y * width] = hueAtPoint(point: CGPoint(x: x, y: y), maxSize: CGFloat(width), hue: hue )
            }
        }
        
        let ref = CGDataProvider(dataInfo: nil, data: satImageData!, size: dataLength) { umrp, urp, length in }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        self.satImage = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 24, bytesPerRow: width * 3, space: colorSpace, bitmapInfo: .byteOrderDefault, provider: ref!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }
    
    private func colorAtPoint(point: CGPoint) -> RGBPixel {
        let center = CGPoint(x: hueRadius, y: hueRadius)
        let angle = atan2(point.x - center.x, point.y - center.y)
        let angleDeg = radiansToDegrees(angle: angle) + 180
        let dist = calcPointDistance(p1: point, p2: center)
        
        var hue = CGFloat(angleDeg/360.0)
        hue = min(hue, 1.0 - 0.0000001)
        hue = max(hue, 0.0)
        
        var sat = dist/CGFloat(hueRadius)
        sat = min(sat, 1.0)
        sat = max(sat, 0.0)
        
        return RGBPixel(h: hue, s: CGFloat(1.0), v: CGFloat(1.0))
    }
    
    private func hueAtPoint(point: CGPoint, maxSize: CGFloat, hue: CGFloat) -> RGBPixel {
        let sat = 1 - (point.x/maxSize)
        let brightness = 1 - (point.y/maxSize)
        
        return RGBPixel(h: hue, s: sat, v: brightness)
    }
    
    private func calcPointDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        
        let xDistance = Float(p1.x - p2.x)
        let yDistance = Float(p1.y - p2.y)
        
        return CGFloat(sqrtf(xDistance * xDistance + yDistance * yDistance))
    }
    
    public func radiansToDegrees(angle: CGFloat) -> CGFloat {
        // PI * 180
        return angle * 57.29577951
    }
    
    private func degreesToRadians(angle: CGFloat) -> CGFloat {
        // PI / 180
        return angle * 0.01745329252
    }
}
