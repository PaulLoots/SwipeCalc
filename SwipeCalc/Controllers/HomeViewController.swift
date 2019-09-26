//
//  ViewController.swift
//  SwipeCalc
//
//  Created by Paul Loots on 2019/09/26.
//  Copyright © 2019 Paul Loots. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    //Calculation Vars
    var calculationString = ""
    var currentAnswer = ""
    
    //Numbers
    var numberViews = [UIView]()
    @IBOutlet var number4: DesignableView!
    
    
    //Operators
    var operatorViews = [UIView]()
    @IBOutlet var operatorPlus: DesignableView!
    
    
    //Views
    @IBOutlet var keypadOverlayView: UIView!
    
    //Gesture vars
    var numberTouching = false
    var operatorTouching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //User Moving Action
    @IBAction func userMoveFinger(_ sender: UIPanGestureRecognizer) {

        //Start Moving
        if sender.state == UIGestureRecognizer.State.began {
            numberTouching = false
            operatorTouching = false
            calculationString = ""
            
            showKeypadOverlay()
            numberViews = [number4]
            operatorViews = [operatorPlus]
        }
        
        //Cancel Moving
        if sender.state == UIGestureRecognizer.State.cancelled{
            UIView.animate(withDuration: 0, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            })
            hideKeypadOverlay()
            return
        }

        //End Moving
        if sender.state == UIGestureRecognizer.State.ended{
            print(calculationString)
            calculateResult()
            hideKeypadOverlay()
            return
        }
        
        //Check Number Touching
        for view in numberViews {
            if isTouchingView(view: view, x: Int(sender.location(ofTouch: 0, in: self.view).x), y: Int(sender.location(ofTouch: 0, in: self.view).y)) {
                if !numberTouching {
                    addCalculationItem(tag: view.tag)
                }
                numberTouching = true
            } else {
                numberTouching = false
            }
        }
        
        //Check Operator Touching
        for view in operatorViews {
            if isTouchingView(view: view, x: Int(sender.location(ofTouch: 0, in: self.view).x), y: Int(sender.location(ofTouch: 0, in: self.view).y)) {
                if !operatorTouching {
                    addCalculationItem(tag: view.tag)
                }
                operatorTouching = true
            } else {
                operatorTouching = false
            }
        }
    }
    
    //Check if touching view
    func isTouchingView(view: UIView, x: Int, y: Int) -> Bool{
        return view.frame.contains(CGPoint(x: x, y: y))
    }
    
    //Add item to calculation string
    func addCalculationItem(tag:Int) {
        print(tag)
        var addValue = ""
        
        switch tag {
        case 10:
            addValue = "+"
        default:
            addValue = String(tag)
        }
        calculationString = calculationString + addValue
    }
    
    func calculateResult() {
        
        guard calculationString != "" else { return }
        
        let expression = NSExpression(format: calculationString)
        guard let mathValue = expression.expressionValue(with: nil, context: nil) as? Double else { return }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        guard let value = formatter.string(from: NSNumber(value: mathValue)) else { return }
        
        currentAnswer = String(value)
        print(currentAnswer)
    }
    
    //UI Funcs
    
    //Show Calculator Input Overlay
    func showKeypadOverlay(){
        self.view.addSubview(keypadOverlayView)
        keypadOverlayView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    //Hide Calculator Input Overlay
    func hideKeypadOverlay(){
        keypadOverlayView.removeFromSuperview()
    }
}

