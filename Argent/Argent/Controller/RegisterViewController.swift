//
//  RegisterViewController.swift
//  Argent
//
//  Created by Christine Ong on 12/31/21.
//

import Foundation
import UIKit
import Firebase
import SwiftUI

class RegisterViewController: UIViewController, UITextFieldDelegate{
    
   
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordRetyped: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        self.email.delegate = self
        self.password.delegate = self
        self.passwordRetyped.delegate = self
        
        //Looks for single or multiple taps.
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    
@objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
}

@objc func keyboardWillHide(notification: NSNotification) {
    if self.view.frame.origin.y != 0 {
        self.view.frame.origin.y = 0
    }
}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.email:
            self.password.becomeFirstResponder()
        case self.password:
            self.passwordRetyped.becomeFirstResponder()
        default:
            self.email.resignFirstResponder()
        }
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    @IBAction func registerToDashboard(_ sender: UIButton) {
        if let passwordText = password.text, let emailText = email.text, let passwordReText = passwordRetyped.text{
            if passwordText != passwordReText{
                let alert = UIAlertController(title: "Error", message: "Password and password retyped do not match", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else{
                Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
                    if error != nil{
                        let alert = UIAlertController(title: "Error", message: "Error creating user. Please try again later.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "Success", message: "Your account was successfully created.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.performSegue(withIdentifier: "registerToDashboardSegue", sender: self)
                    }
                }
            }
        }
        
    }
}
