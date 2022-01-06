//
//  LoginViewController.swift
//  Argent
//
//  Created by Christine Ong on 12/31/21.
//

import Foundation
import UIKit
import Firebase
import SwiftUI

class LoginViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTeztField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTeztField.delegate = self
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
        case self.emailTextField:
            self.passwordTeztField.becomeFirstResponder()
        default:
            self.emailTextField.resignFirstResponder()
        }
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    @IBAction func loginToDashboard(_ sender: UIButton) {
        if let emailtext = emailTextField.text, let passwordtext = passwordTeztField.text{
            Auth.auth().signIn(withEmail: emailtext, password: passwordtext) { [weak self] authResult, error in
                if error != nil{
                    let alert = UIAlertController(title: "Error", message: "Unable to login. Please try again.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self!.present(alert, animated: true, completion: nil)
                    
                }else{
                    self?.performSegue(withIdentifier: "loginToDasboardSegue", sender: self)
                }
              guard let strongSelf = self else { return }
              // ...
            }
        }
    }
    
}
