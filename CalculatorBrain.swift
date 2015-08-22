//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Kunal Patel on 7/25/15.
//  Copyright (c) 2015 Kunal Patel. All rights reserved.
//

import Foundation


class CalculatorBrain: Printable
{
    private enum Op: Printable
    {
        case Operand(Double)
        case Variable(String)
        case Constant(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String
        {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let operand):
                    return operand
                case .Constant(let operand):
                    return operand
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    private var knownConstants = [String: Double]()
    
    var variableValues = [String: Double]()
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return opStack.map{ $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol]{
                        newOpStack.append(op)
                    } else if let constant = knownConstants[opSymbol] {
                        newOpStack.append(.Constant(opSymbol))
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    } else {
                        newOpStack.append(Op.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    init() {
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        
        
        knownConstants["∏"] = M_PI
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch (op) {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let operand):
                return (variableValues[operand], remainingOps)
            case .Constant(let operand):
                return (knownConstants[operand], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(operand: String) -> Double? {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    
    func pushConstant(symbol: String) -> Double? {
        opStack.append(Op.Constant(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    
    func clear()
    {
        opStack = [Op]()
    }
    
    private func descriptionHelper(ops: [Op]) -> (result: String?, remainingOps: [Op])
    {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch (op) {
            case .Operand(let operand):
                return ("\(op)", remainingOps)
            case .Variable(let operand):
                return ("\(op)", remainingOps)
            case .Constant(let operand):
                return ("\(op)", remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = descriptionHelper(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(op)(" + (operand) + ")", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = descriptionHelper(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = descriptionHelper(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("(" + operand2 + " \(op) " + operand1 + ")", op2Evaluation.remainingOps);
                    }
                }
            }
        }
        return (nil, ops)
    }

    var description: String {
        get {
            var result = " "
            var remainingOps = opStack
            while remainingOps.count != 0 {
                let (res_string, newStack) = descriptionHelper(remainingOps)
                remainingOps = newStack

                if (result == " "){
                    result = res_string!
                } else {
                    result = res_string! + ", " + result
                }
            }
            if(result != " "){
                result = result + " ="
            }
            println(result)
            return result
        }
    }
    
    func evaulateFunctionForPoints(input: [Double]) -> [Double]?
    {
        var x_values = input
        var y_values = [Double]()
        for x_value in x_values {
            variableValues["M"] = x_value
            y_values.append(evaluate()!)
        }
        return y_values
    }

}