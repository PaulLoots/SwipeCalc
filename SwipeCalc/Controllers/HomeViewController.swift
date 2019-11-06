//
//  ViewController.swift
//  SwipeCalc
//
//  Created by Paul Loots on 2019/09/26.
//  Copyright © 2019 Paul Loots. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    //Haptics
    let impact = UIImpactFeedbackGenerator()
    let notificationTap = UINotificationFeedbackGenerator()
    let selectionTap = UISelectionFeedbackGenerator()
    
    //Calculation Vars
    var calculationString = ""
    var currentAnswer = ""
    
    //Numbers
    var numberViews = [UIView]()
    @IBOutlet var number4: DesignableView!
    @IBOutlet var number5: DesignableView!
    @IBOutlet var number0: DesignableView!
    @IBOutlet var number3: DesignableView!
    @IBOutlet var number2: DesignableView!
    @IBOutlet var number1: DesignableView!
    @IBOutlet var number6: DesignableView!
    @IBOutlet var number7: DesignableView!
    @IBOutlet var number8: DesignableView!
    @IBOutlet var number9: DesignableView!
    
    //Operators
    var possibleOperators: Array<Character> = ["+","-","/","*"]
    var operatorViews = [UIView]()
    @IBOutlet var operatorPlus: DesignableView!
    @IBOutlet var operatorMinus: DesignableView!
    @IBOutlet var operatorDevide: DesignableView!
    @IBOutlet var operatorMultiply: DesignableView!
    
    //Other Functions
    var functionViews = [UIView]()
    @IBOutlet var functionHistiry: DesignableView!
    var history : [Any] = []
    
    //History
    var isHistoryActive = false
    
    //Labels
    @IBOutlet var overlayCalculationLabel: UILabel!
    @IBOutlet var currentCalculationLabel: UILabel!
    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var historyCalculationLabel: UILabel!
    
    //Views
    @IBOutlet var keypadOverlayView: UIView!
    @IBOutlet var historyView: UIView!
    @IBOutlet var historyTableView: UITableView!
    
    //Gesture vars
    var numberTouching = [false,false,false,false,false,false,false,false,false]
    var operatorTouching = false
    var functionTouching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let history = UserDefaults.standard.array(forKey: "history"){
            self.history = history
        }
        answerLabel.text = ""
        currentCalculationLabel.text = ""
    }
    
    //User Moving Action
    @IBAction func userMoveFinger(_ sender: UIPanGestureRecognizer) {

        // TODO: - Have a way to continue equasion
        
        //Start Moving
        if sender.state == UIGestureRecognizer.State.began {
            numberTouching = [false,false,false,false,false,false,false,false,false,false]
            operatorTouching = false
            functionTouching = false
            calculationString = ""
            updateOverlayCalculationLabel()
            
            showKeypadOverlay()
            numberViews = [number5,number4,number0,number1,number2,number3,number6,number7,number8,number9]
            operatorViews = [operatorPlus, operatorMinus, operatorDevide, operatorMultiply]
            functionViews = [functionHistiry]
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
                if !numberTouching[view.tag] {
                    animateNumberSelected(numberView: view)
                    addCalculationItem(tag: view.tag)
                }
                numberTouching[view.tag] = true
            } else {
                print(view.tag)
                numberTouching[view.tag] = false
            }
        }
        
        //Check Operator Touching
        for view in operatorViews {
            if isTouchingView(view: view, x: Int(sender.location(ofTouch: 0, in: self.view).x), y: Int(sender.location(ofTouch: 0, in: self.view).y)) {
                let velcoityX = sender.velocity(in: view).x
                let velcoityY = sender.velocity(in: view).y
                if velcoityX < 5 && velcoityY < 5 {
                    if !operatorTouching {
                        if !possibleOperators.contains(calculationString.last ?? " ") && calculationString.count > 0 {
                                animateOperatorSelected(numberView: view)
                                addCalculationItem(tag: view.tag)
                        }
                    }
                    operatorTouching = true
                }
            } else {
                operatorTouching = false
            }
        }
        
        //Check Function Touching
        for view in functionViews {
            if isTouchingView(view: view, x: Int(sender.location(ofTouch: 0, in: self.view).x), y: Int(sender.location(ofTouch: 0, in: self.view).y)) {
                if !functionTouching {
                    animateOperatorSelected(numberView: view)
                    showHistoryOverlay()
                }
                functionTouching = true
            } else {
                functionTouching = false
            }
        }
    }
    
    //Check if touching view
    func isTouchingView(view: UIView, x: Int, y: Int) -> Bool{
        if isHistoryActive {
            return false
        } else {
            return view.frame.contains(CGPoint(x: x, y: y-60))
        }
    }
    
    //Add item to calculation string
    func addCalculationItem(tag:Int) {
        print(tag)
        var addValue = ""
        
        switch tag {
        case 10:
            addValue = "+"
        case 11:
            addValue = "-"
        case 12:
            addValue = "*"
        case 13:
            addValue = "/"
        default:
            addValue = String(tag)
        }
        calculationString = calculationString + addValue
        
        //Set Calulation Label
        updateOverlayCalculationLabel()
    }
    
    func calculateResult() {
        
        guard calculationString != "" else { return }
        
        if possibleOperators.contains(calculationString.last ?? " ") {
            calculationString = String(calculationString.dropLast())
        }
        
        let expression = NSExpression(format: calculationString)
        guard let mathValue = expression.expressionValue(with: nil, context: nil) as? Double else { return }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        guard let value = formatter.string(from: NSNumber(value: mathValue)) else { return }
        
        currentAnswer = String(value)
        if history.count > 10 {
            history = Array(history.dropFirst())
        }
        history.append(calculationString + " = " + String(value))
        UserDefaults.standard.set(history, forKey: "history")
        
        //Update Labels
        updateCurrentCalculationLabel()
        updateAnswerLabel()
    }
    
    // MARK: - Animations
    
    //Show Calculator Input Overlay
    func showKeypadOverlay(){
        self.view.addSubview(keypadOverlayView)
        keypadOverlayView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        self.keypadOverlayView.alpha = 0
        self.keypadOverlayView.transform = CGAffineTransform.init(scaleX: 4, y: 4)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
                self.keypadOverlayView.transform = .identity
                self.keypadOverlayView.alpha = 1
            })
        }
        self.impact.impactOccurred()
    }
    
    //Hide Calculator Input Overlay
    func hideKeypadOverlay(){
        hideHistoryOverlay()
        selectionTap.selectionChanged()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
             self.keypadOverlayView.transform = .init(scaleX: 2, y: 2)
            self.keypadOverlayView.alpha = 0
         })
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
             self.keypadOverlayView.transform = .identity
             self.keypadOverlayView.removeFromSuperview()
         }

    }
    
    //Show History Overlay
    func showHistoryOverlay(){
        isHistoryActive = true
        self.view.addSubview(historyView)
        historyView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: self.view.frame.height)
        updateHistoryCalculationLabel()
        historyTableView.reloadData()
        self.historyView.alpha = 0
        self.historyView.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.historyView.transform = .identity
                self.historyView.alpha = 1
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impact.impactOccurred()
        }
    }
    
    //Hide History Overlay
    func hideHistoryOverlay(){
        isHistoryActive = false
        if let historyView = historyView {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                historyView.transform = .init(scaleX: 1.5, y: 1.5)
                historyView.alpha = 0
             })
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                 historyView.transform = .identity
                 historyView.removeFromSuperview()
             }
        }
    }
    
    //Label Updates
    func updateOverlayCalculationLabel() {
        overlayCalculationLabel.text = calculationString
    }
    
    func updateCurrentCalculationLabel() {
        currentCalculationLabel.text = calculationString
    }
    
    func updateHistoryCalculationLabel() {
        historyCalculationLabel.text = calculationString
    }
    
    func updateAnswerLabel() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.answerLabel.transform = .init(scaleX: 1.5, y: 1.5)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impact.impactOccurred()
            self.answerLabel.text = self.currentAnswer
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.answerLabel.transform = .identity
            })
        }
    }
    
    //Button Animations
    func animateNumberSelected(numberView: UIView) {
        selectionTap.selectionChanged()
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            numberView.transform = .init(scaleX: 1.5, y: 1.5)
            numberView.backgroundColor = UIColor.init(named: "selectedBackground")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                numberView.transform = .identity
                numberView.backgroundColor = .clear
            })
        }
    }
    
    func animateOperatorSelected(numberView: UIView) {
        impact.impactOccurred()
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            numberView.transform = .init(scaleX: 1.5, y: 1.5)
            numberView.backgroundColor =  UIColor.init(named: "operatorSelectedBackground")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                numberView.transform = .identity
                numberView.backgroundColor = .clear
            })
        }
    }
}

// MARK: - Table View Delegates

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        cell.historyLabel.text = history[indexPath.row] as? String ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snippet = history[indexPath.item] as? String ?? "0"
        selectionTap.selectionChanged()
        if let range = snippet.range(of: "= ") {
            calculationString = calculationString + snippet[range.upperBound...]
            updateOverlayCalculationLabel()
            hideHistoryOverlay()
        }
    }
    
}

