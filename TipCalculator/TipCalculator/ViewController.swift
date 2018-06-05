//
//  ViewController.swift
//  TipCalculator
//
//  Created by Landry Achia Ndong on 2018-06-03.
//  Copyright © 2018 Landry Achia Ndong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    //label for user final tip
    @IBOutlet weak var tipAmountLabel: UILabel!
    
    //text field for user bill
    @IBOutlet weak var billAmountTextField: UITextField!
    
    //user desired tip amount
    @IBOutlet weak var tipPercentTextField: UITextField!
    
    //action to execute
    @IBAction func calculateTipButton(_ sender: UIButton) {
        print("calculate tip button pressed")
        hideTexFieldKeyboard()
        hidePercentTextField()
        calculateTips()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View loaded")
        //setting delegate to fix keyboard obscuring calculate tip button
        billAmountTextField.delegate = self
        
        //setting delegate to fix keyboard obscuring calculate tip button
        tipPercentTextField.delegate = self
        
        
        
        //listening keyboard events
        NotificationCenter.default.addObserver(ViewController.keyboardWillChange(self), selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(ViewController.keyboardWillChange(self), selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(ViewController.keyboardWillChange(self), selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    
        
    }
    
    //removing observers/listeners using deinit to avoid continuous running of observers for events
    deinit {
        NotificationCenter.default.removeObserver(ViewController.keyboardWillChange(self), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(ViewController.keyboardWillChange(self), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(ViewController.keyboardWillChange(self), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


  
    
    //method to make the textField to give up focus once return key is hit
    func hideTexFieldKeyboard() {
        billAmountTextField.resignFirstResponder()
    }
    
    func hidePercentTextField() {
        tipPercentTextField.resignFirstResponder()
    }
    
    //objective C method to receive notification  for event from system before keyboard shows e.g keyboardWillShow
    @objc func keyboardWillChange(notification: Notification) {
        //getting the exact height of keyboard by setting a guarded value which is returned as NSValue
        guard let sysKeyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name  == Notification.Name.UIKeyboardWillChangeFrame {
            
            //taking keyboard along the y-axis by negative value so it shows up
            view.frame.origin.y = -sysKeyboardHeight.height
        }else{
            //resets the keyboard back to position o on  xy axis along the y-axis
            view.frame.origin.y = 0
        }
        
    }
    
    //function takes two parameters to evaluate tip math
    func calculateTip(valueToGiveTip: Double, percentageOfTip: Double) -> Double {
        return valueToGiveTip * (percentageOfTip / 100.0)
    }
    
    //method to calculate user tips
    func calculateTips() {
        //type casting textField from text to Double
        let tipPercent = Double(tipPercentTextField.text!)
//            else {
//            print("Invalid percent: \(tipPercentTextField.text!)")
//            return
//        }
        
        guard let tipAmount = convertToCurrency(input: billAmountTextField.text!)else{
            print("Invalid Amount: \(billAmountTextField.text!)")
            return
        }
        var tipWithValueInput = calculateTip(valueToGiveTip: tipAmount, percentageOfTip: 15.0)
        
        
        
        //update the tipAmountLabel on UI
        if tipPercentTextField.text?.isEmpty ?? true {
            print("tip percent field is empty")
            tipAmountLabel.text = "$" + String(tipWithValueInput)
        } else {
            tipWithValueInput = calculateTip(valueToGiveTip: tipAmount, percentageOfTip: (tipPercent)!)
            tipAmountLabel.text = "$" + String(tipWithValueInput)
            print("Calculating tip based on tip percent input by user")
        }
        

    }
    
    //format number to style that matches local currency and return as an optional double
    func convertToCurrency(input:String) -> Double? {
        let currencyType = NumberFormatter()
        currencyType.numberStyle = .currency
        //using gps to assing current currency of user location
        currencyType.locale = Locale.current
        
        return currencyType.number(from: input)?.doubleValue
    }
    
    
    
    //implementing UITextFieldDelegate to ensure return button perfoms the optional method  (from UITextFieldDelegate
    //optional func textFieldShouldReturn(_ textField: UITextField) -> Bool
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("keyboard return key pressed")
        textField.resignFirstResponder()
        
        calculateTips()
        return true
    }
}

