//
//  ViewController.swift
//  Calculator
//
//  Created by Kunal Patel on 3/7/15.
//  Copyright (c) 2015 Kunal Patel. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, GraphViewDataSource
{

    @IBOutlet weak var display     : UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    let brain = CalculatorBrain()

    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if (((digit == ".") && (display.text!.rangeOfString(".") == nil)) ||
            (userIsInTheMiddleOfTypingANumber && (digit != "."))){
            display.text = display.text! + digit
        } else if (digit != ".") {
            display.text = digit
        }
        userIsInTheMiddleOfTypingANumber = true

    }
    
    @IBAction func storageButtonPressed(sender: UIButton) {
        if let storageButtonText = sender.currentTitle{
            if (storageButtonText == "→M") {
                brain.variableValues["M"] = displayValue
                userIsInTheMiddleOfTypingANumber = false
                displayValue = brain.evaluate()
            } else {
                if(userIsInTheMiddleOfTypingANumber){
                    enter()
                }
                brain.pushOperand(storageButtonText)
                updateHistoryLabel()
                if(brain.variableValues[storageButtonText] == nil)
                {
                    display.text = nil
                }
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }

        if let operation = sender.currentTitle {
            switch (operation){
            case "C": brain.clear()
            default:  brain.performOperation(operation)
            }
        }
        displayValue = brain.evaluate()

    }
    
    
    @IBAction func constPressed(sender: UIButton) {
        if let constant = sender.currentTitle{
            if(userIsInTheMiddleOfTypingANumber){
                enter()
            }
            display.text = constant
            brain.pushConstant(constant)
            userIsInTheMiddleOfTypingANumber = false
            updateHistoryLabel()
        }
    }
    
    func enterConstant(newConst: Double){
        if(userIsInTheMiddleOfTypingANumber){
            enter()
        }
        displayValue = newConst
        enter()
    }

    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false

        displayValue = brain.pushOperand(displayValue!)

    }
    
    var displayValue: Double? {
        get{
            if let displayVal = NSNumberFormatter().numberFromString(display.text!) {
                return displayVal.doubleValue
            } else {
                return nil
            }
        } set {
            if let newVal = newValue {
                display.text = "\(newVal)"
            } else {
                display.text = " "
            }
            userIsInTheMiddleOfTypingANumber = false
            updateHistoryLabel()
        }
    }

    func updateHistoryLabel (){
        historyLabel.text = "\(brain)"
    }
    
    func evaulateFunctionForPoints(input: [Double]) -> [Double]? {
        return brain.evaulateFunctionForPoints(input)
    }
    
    func getTitleforGraph() -> String? {
        return "\(brain)"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController
        }
        
        if let gvc = destination as? GraphViewController{
            gvc.dataSource = self
        }
        
    }
    
    
}

