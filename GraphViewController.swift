//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by Kunal Patel on 7/30/15.
//  Copyright (c) 2015 Kunal Patel. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    weak var dataSource: GraphViewDataSource?
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            
            var tapGesture = UITapGestureRecognizer(target: graphView, action: "setOrigin:")
            tapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBAction func translateGraphInView(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(graphView)
            
            var graphOrigin = graphView.axesOrigin
            graphOrigin?.y += translation.y
            graphOrigin?.x += translation.x
            graphView.axesOrigin = graphOrigin
            
            gesture.setTranslation(CGPointZero, inView: graphView)
        default: break
        }
    }
    
    
    func evaulateFunctionForPoints(input: [Double]) -> [Double]? {
        let ret_val = dataSource?.evaulateFunctionForPoints(input)
        if let graph_title = dataSource?.getTitleforGraph() {
            self.title = graph_title
        }
        return ret_val
    }
    
    func getTitleforGraph() -> String? {
        if let graph_title = dataSource?.getTitleforGraph() {
            self.title = graph_title
        }
        return ""
    }
    


}