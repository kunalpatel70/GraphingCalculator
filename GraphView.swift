//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Kunal Patel on 7/30/15.
//  Copyright (c) 2015 Kunal Patel. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func evaulateFunctionForPoints([Double]) -> [Double]?
    func getTitleforGraph() -> String?
}

@IBDesignable
class GraphView: UIView {
    
    var axesDrawer = AxesDrawer(color: UIColor.redColor())
    
    func getXValues() -> [Double]{
        var x_values = [Double]()
        
        var start = (0-axesOrigin!.x)/scale
        let delta = (((bounds.size.width-axesOrigin!.x)/scale) - ((0-axesOrigin!.x)/scale))/bounds.size.width
        let end = (bounds.size.width-axesOrigin!.x)/scale
        
        while (start <= end) {
            x_values.append(Double(start))
            start += delta
        }
        
        return x_values
    }
    
    var axesOrigin: CGPoint? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var scale: CGFloat = 100 { didSet { setNeedsDisplay() }}
    
    weak var dataSource: GraphViewDataSource?
    
    override func drawRect(rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesOrigin = axesOrigin ?? CGPointMake(bounds.size.width/2, bounds.size.height/2)
        axesDrawer.drawAxesInRect(rect, origin: axesOrigin! , pointsPerUnit: scale)
        
        drawGraph(rect)
        
    }
    
    func drawGraph(rect:CGRect) {
                
        if let y_normalized = dataSource!.evaulateFunctionForPoints(getXValues()) {
            
            var y_values = y_normalized.map({ Double(self.axesOrigin!.y) - ($0 * Double(self.scale))})
            
            let functionPath = UIBezierPath()
            
            var normalYFound = false
            
            for x_value in 1...y_values.count {
                if !normalYFound {
                    if y_values.first!.isNormal {
                        functionPath.moveToPoint(CGPoint(x: CGFloat(x_value), y: CGFloat(y_values.first!)))
                        normalYFound = true
                    }
                } else {
                    if y_values.first!.isNormal {
                        functionPath.addLineToPoint(CGPoint(x: CGFloat(x_value), y: CGFloat(y_values.first!)))
                    } else {
                        normalYFound = false
                    }
                }
                y_values.removeAtIndex(0)
                functionPath.stroke()
            }
            functionPath.stroke()
        }
    }
    
    func scale(gesture: UIPinchGestureRecognizer){
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    func setOrigin(gesture: UITapGestureRecognizer) {
        axesOrigin = gesture.locationInView(self)
    }


}
