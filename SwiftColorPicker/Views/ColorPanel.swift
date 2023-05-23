//
//  ColorPanel.swift
//  SwiftColorPicker
//
//  Created by David Douglas on 5/19/23.
//

import UIKit

class ColorPanel: NSObject {
    private var parent: UIView
    private var view: UIView!
    private var colorWheelView: UIView!
    private var innerRidgeView: UIView!
    private var satWheelView: UIView!
    private var frame: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300)
    private var colorWheel = ColorWheel()
    private var bandWidth = 40.0
    private let ridgeWidth = 16
    private var hueSliderview: UIView!
    private var initialHueSliderCenter: CGPoint = .zero
    private var hueSliderLimit: Float = 0.0
    private var satImageView: UIImageView!
    private var satSliderView: UIView!
    private var satSliderLimit: Float = 0.0
    private var initialSatSliderCenter: CGPoint = .zero
    private var currentHue: CGFloat = 0.01
    private var currentSat: CGFloat = 0.50
    private var currentBri: CGFloat = 0.50
    var delegate: colorPanelDelegate?
    
    init(parent: UIView, frame: CGRect) {
        self.parent = parent
        
        if frame.width < 200 || frame.height < 200 {
            self.frame = CGRect(origin: frame.origin, size: CGSize(width: 200, height: 200))
        }
        
        if frame.width != frame.height {
            self.frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.width))
        }
        
        self.frame = frame
        
        super.init()
        
        if frame.width > 200 {
            bandWidth = bandWidth * (frame.width/200)
        }
        
        view = UIView(frame: self.frame)
        view.cornerRadius = self.frame.width/2
        view.backgroundColor = UIColor.systemBackground
        view.dropShadow(radius: 5)

        colorWheelView = UIView(frame: CGRect(x: ridgeWidth/2, y: ridgeWidth/2, width: Int(self.frame.width) - ridgeWidth, height: Int(self.frame.height) - ridgeWidth))
        colorWheelView.cornerRadius = (self.frame.width - CGFloat(ridgeWidth))/2
        colorWheelView.clipsToBounds = true
        
        colorWheel.generateHueImage(size: colorWheelView.frame.size)
        let imageView = UIImageView(image: colorWheel.getImage())
    
        innerRidgeView = UIView(frame: CGRect(x: bandWidth/2, y: bandWidth/2, width: colorWheelView.frame.width - bandWidth, height: colorWheelView.frame.height - bandWidth))
        innerRidgeView.cornerRadius = innerRidgeView.frame.width/2
        innerRidgeView.backgroundColor = UIColor.systemBackground
        innerRidgeView.dropShadow(radius: 5)
        
        colorWheelView.addSubview(imageView)
        colorWheelView.addSubview(innerRidgeView)
        
        satWheelView = UIView(frame: CGRect(x: ridgeWidth/2, y: ridgeWidth/2, width: Int(innerRidgeView.frame.width) - ridgeWidth, height: Int(innerRidgeView.frame.height) - ridgeWidth))
        satWheelView.cornerRadius = satWheelView.frame.width/2
        satWheelView.clipsToBounds = true
        
        colorWheel.generateSatImage(size: satWheelView.frame.size, hue: 0.01)
        satImageView = UIImageView(image: colorWheel.getSatImage())
        satWheelView.addSubview(satImageView)
        
        innerRidgeView.addSubview(satWheelView)
        
        view.addSubview(colorWheelView)
        
        // add hue slider...
        hueSliderview = createHueSliderView(size: Int(bandWidth) - (ridgeWidth * 2) + 4, frame: self.frame, ridgeWidth: ridgeWidth/2)
        view.addSubview(hueSliderview)
        
        // add sat slider...
        satSliderLimit = Float(satWheelView.frame.width/2)
        satSliderView = createSatSliderView(size: Int(bandWidth) - (ridgeWidth * 2) + 4, frame: self.frame)
        view.addSubview(satSliderView)
    }
    
    func showColorPanel() {
        self.parent.addSubview(self.view)
        
        // update color for delegate
        delegate?.updateColor(color: UIColor(hue: currentHue, saturation: currentSat, brightness: currentBri, alpha: 1.0))
    }
    
    private func createHueSliderView(size: Int, frame: CGRect, ridgeWidth: Int) -> UIView {
        let sliderView = createSliderView(frame: CGRect(x: Int(frame.width)/2 - (size/2), y: ridgeWidth - 1, width: size, height: size))
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanHueSlider(_:)))
        sliderView.addGestureRecognizer(panGestureRecognizer)
        
        hueSliderLimit = Float(view.frame.height/2 - sliderView.frame.height/2) - Float(ridgeWidth - 1)
        
        return sliderView
    }
    
    private func createSatSliderView(size: Int, frame: CGRect) -> UIView {
        let sliderView = createSliderView(frame: CGRect(x: Int(frame.width/2) - (size/2), y: Int(frame.width/2) - (size/2), width: size, height: size))
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanSatSlider(_:)))
        sliderView.addGestureRecognizer(panGestureRecognizer)
        
        return sliderView
    }

    private func createSliderView(frame: CGRect) -> UIView {
        let sliderView = UIView(frame: frame)
        sliderView.cornerRadius = CGFloat(sliderView.frame.width/2)
        sliderView.layer.borderWidth = 4
        sliderView.layer.borderColor = UIColor.systemBackground.cgColor
        sliderView.backgroundColor = UIColor.clear
        
        let innerRidge = UIView(frame: CGRect(x: 4, y: 4, width: Int(sliderView.frame.size.width) - 8, height: Int(sliderView.frame.size.width) - 8))
        innerRidge.cornerRadius = CGFloat(innerRidge.frame.width/2)
        innerRidge.layer.borderWidth = 1
        innerRidge.layer.borderColor = UIColor.gray.cgColor
        innerRidge.backgroundColor = UIColor.clear
        
        sliderView.addSubview(innerRidge)
        
        let innerPointer = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        innerPointer.center = CGPoint(x: sliderView.frame.width/2, y: sliderView.frame.height/2)
        innerPointer.cornerRadius = 3
        innerPointer.layer.borderWidth = 1
        innerPointer.layer.borderColor = UIColor.gray.cgColor
        innerPointer.backgroundColor = UIColor.clear
        
        sliderView.addSubview(innerPointer)
        
        return sliderView
    }
    
    
    @objc private func didPanHueSlider(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            initialHueSliderCenter = hueSliderview.center
        case .changed:
            let translation = sender.translation(in: view)

            let newPoint = CGPoint(x: initialHueSliderCenter.x + translation.x,
                                   y: initialHueSliderCenter.y + translation.y)
            
            let sliderInfo = newHueSliderPoint(point: newPoint)
            hueSliderview.center = sliderInfo.newPosition
            updateSatImageView(angle: sliderInfo.newAngle)
            currentHue = calculateHue(angle: sliderInfo.newAngle)
            delegate?.updateColor(color: UIColor(hue: currentHue, saturation: currentSat, brightness: currentBri, alpha: 1.0))
        default:
            break
        }
    }
    
    @objc private func didPanSatSlider(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            initialSatSliderCenter = satSliderView.center
        case .changed:
            let translation = sender.translation(in: view)

            let newPoint = CGPoint(x: initialSatSliderCenter.x + translation.x,
                                   y: initialSatSliderCenter.y + translation.y)
            
            // make sure we dont allow the slider to exit the center image view
            let adjustedPoint = newSatSliderPoint(point: newPoint)
            satSliderView.center = adjustedPoint
            
            // change to the correct coordinate system to calculate Saturation and Brightness.
            let wheelPoint = view.convert(adjustedPoint, to: satWheelView)

            currentSat = 1 - abs(wheelPoint.x/satWheelView.frame.width)
            currentBri = 1 - abs(wheelPoint.y/satWheelView.frame.height)
            
            delegate?.updateColor(color: UIColor(hue: currentHue, saturation: currentSat, brightness: currentBri, alpha: 1.0))
        default:
            break
        }
    }
    
    private func newHueSliderPoint(point: CGPoint) -> (newPosition: CGPoint, newAngle: Float) {
        // clamp the position of the icon within the circle
       
        // get the center point of the bkgd image
        let centerX  = Float(self.view.frame.size.width * 0.5)
        let centerY  = Float(self.view.frame.size.height * 0.5)
        
        // work out the limit to the distance of the picker when moving around the hue bar
        let limit = hueSliderLimit
        //Float(self.view.frame.size.width * 0.5)
        
        // work out the distance difference between the location and center
        let dx = Float(point.x) - centerX
        let dy = Float(point.y) - centerY
        
        // determine angle by using the direction of the location
        let angle = atan2f(dy, dx)
        
        // set new position of the slider
        let x = centerX + limit * cosf(angle)
        let y = centerY + limit * sinf(angle)
    
        return (newPosition: CGPoint(x: Double(x), y: Double(y)), newAngle: angle)
    }
    
    private func newSatSliderPoint(point: CGPoint) -> CGPoint {
        // clamp the position of the icon within the circle
       
        // get the center point of the bkgd image
        let centerX  = Float(self.view.frame.size.width * 0.5)
        let centerY  = Float(self.view.frame.size.height * 0.5)
        
        // work out the limit to the distance of the picker when moving around the hue bar
        let limit = satSliderLimit
        
        // work out the distance difference between the location and center
        let dx = Float(point.x) - centerX
        let dy = Float(point.y) - centerY
        let dist = sqrtf(dx*dx+dy*dy)
        
        var x = point.x
        var y = point.y
              
        if (dist > limit) {
            // determine angle by using the direction of the location
            let angle = atan2f(dy, dx)
            
            // set new position of the slider
            x = CGFloat(centerX + limit * cosf(angle))
            y = CGFloat(centerY + limit * sinf(angle))
        }
    
        return CGPoint(x: Double(x), y: Double(y))
    }
 
    private func updateSatImageView(angle: Float) {
        colorWheel.generateSatImage(size: satWheelView.frame.size, hue: calculateHue(angle: angle))
        satImageView.image = colorWheel.getSatImage()
    }
    
    private func calculateHue(angle: Float) -> CGFloat {
        var angleDeg = colorWheel.radiansToDegrees(angle: CGFloat(angle)) + 180
      
        // adjust the angle to reverse the direction of colors and rotate 90 degrees...
        angleDeg = (360 - angleDeg) + 90
        
        // if angle exceeds 360 after our adjustment, subtract 360...
        if angleDeg > 360 {
            angleDeg = angleDeg - 360
        }

        var hue = angleDeg/360.0
        hue = min(hue, 1.0 - 0.0000001)
        hue = max(hue, 0.0)
        
        return hue
    }
}

protocol colorPanelDelegate {
    func updateColor(color: UIColor)
}
