//
//  ViewController.swift
//  TipCalculator
//
//  Created by Landry Achia Ndong on 2018-06-03.
//  Copyright © 2018 Landry Achia Ndong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //label for bill plus tip
    @IBOutlet weak var billPlusTip: UILabel!

    //label for user final tip
    @IBOutlet weak var tipAmountLabel: UILabel!
    
    //text field for user bill
    @IBOutlet weak var billAmountTextField: UITextField!
    
    //user desired tip amount
    @IBOutlet weak var tipPercentTextField: UITextField!
    
    //slider percent
    @IBOutlet weak var sliderPercent: UISlider!
    
    //action to execute
    @IBAction func calculateTipButton(_ sender: UIButton) {
        print("calculate tip button pressed")
        hideTexFieldKeyboard()
        hidePercentTextField()
        calculateTips()
    }
    
    
    //action for subTotal text field
    @IBAction func subTotalTextField(_ sender: UITextField) {
        print("calculate tip from subTotalTextField processed")
        calculateTips()
    }
    
    //action for percent text field
    @IBAction func perCentTextFieldAction(_ sender: UITextField) {
        print("calculate tip from percentTextField processed")
        calculateTips()
    }
    
    //disabling keyboard from TextFields once screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //action for slider
    @IBAction func percentTipSlider(_ sender: UISlider) {
        //getting value from slider and assigning to tip percent if needed
        let valueOfSlider = Int(sender.value)
//        let roundedSliderAmount = (valueOfSlider * 100).rounded() / 100
        //setting value from slider onto percent text field
        tipPercentTextField.text = String(valueOfSlider)
        
        //getting value from input field of total amount
        guard let tipAmount = convertToCurrency(input: billAmountTextField.text!)else{
            print("Invalid Amount: \(billAmountTextField.text!)")
            return
        }
        
        let tipWithValueInput = calculateTip(valueToGiveTip: tipAmount, percentageOfTip: (Double(valueOfSlider)))
//        let tipRounded = (tipWithValueInput * 100).rounded() / 100
        tipAmountLabel.text = "$" + String(tipWithValueInput)
        billPlusTip.text = "$" + String(tipAmount + tipWithValueInput)
        print("Calculating tip based on tip percent FROM SLIDER by user")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View loaded")
        //setting delegate to fix keyboard obscuring calculate tip button
        billAmountTextField.delegate = self
        self.billAmountTextField.keyboardType = UIKeyboardType.decimalPad
        
        //setting delegate to fix keyboard obscuring calculate tip button
        tipPercentTextField.delegate = self
        self.tipPercentTextField.keyboardType = UIKeyboardType.decimalPad
        
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
            billPlusTip.text = "$" + String(tipAmount + tipWithValueInput)
        } else {
            tipWithValueInput = calculateTip(valueToGiveTip: tipAmount, percentageOfTip: (tipPercent)!)
            tipAmountLabel.text = "$" + String(tipWithValueInput)
            billPlusTip.text = "$" + String(tipAmount + tipWithValueInput)
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

