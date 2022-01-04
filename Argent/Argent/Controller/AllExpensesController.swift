//
//  AllExpensesController.swift
//  Argent
//
//  Created by Christine Ong on 12/31/21.
//

import Foundation
import UIKit
import Firebase
import SwiftUI

class AllExpensesController: UIViewController, UITableViewDelegate{
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [Expense] = []
    var identifiers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false

            view.addGestureRecognizer(tap)
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell1")
        
        loadMessages()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func loadMessages() {
        let dateString = NSDate().timeIntervalSince1970
        
        db.collection("expenses")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in
            
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    self.messages = []
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if data["user"] as! String == (Auth.auth().currentUser?.email ?? "nil"){
                        let newMessage = Expense(amount: data["amount"] as! Double, category: data["category"] as! String, date: dateString, iden: data["iden"] as? String ?? NSUUID().uuidString, user: Auth.auth().currentUser?.email as! String)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                   self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func menuButton(_ sender: UIButton) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(
            .init(title: "Dashboard", style: .default) { _ in
                self.performSegue(withIdentifier: "AllToDashSegue", sender: self)
            }
        )

        alert.addAction(
            .init(title: "View all expenses", style: .default) { _ in
            }
        )        
        present(alert, animated: true)
        
    }
    @IBAction func addExpense(_ sender: UIButton) {
        let dated = NSDate().timeIntervalSince1970
        var tfieldAmount = 0.00
        var tfieldCategory = "General"
        let alert = UIAlertController(title: "New Expense", message: "Enter a decimal number, eg. 5.00, then enter a category for your expense", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = "0.00"
        }
        alert.addTextField { (textField2) in
            textField2.text = "General"
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self, weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if let tfield = textField?.text{
                tfieldAmount = Double(tfield) ?? 0.00
            }
            let textField2 = alert?.textFields![1] // Force unwrapping because we know it exists.
            if let tfield2 = textField2?.text{
                tfieldCategory = tfield2
            }
            
            let dataiden = "\(NSUUID().uuidString)"
            
            self.db.collection("expenses").document("\(dataiden)").setData([
                    "iden": dataiden,
                    "amount": tfieldAmount,
                    "category": tfieldCategory,
                    "date": dated,
                    "user": Auth.auth().currentUser?.email
                ]) { (error) in
                    if let e = error {
                        print("There was an issue saving data to firestore, \(e)")
                    } else {
                        print("Successfully saved data.")
                    }
                }
            
        }))
        present(alert, animated: true, completion: nil)    }
}

extension AllExpensesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            db.collection("expenses").document("\(messages[indexPath.row].iden)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            messages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateString = NSDate().timeIntervalSince1970
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell1", for: indexPath) as! CustomCell
        cell.amountCell.text = "\(message.amount)"
        cell.categoryCell.text = message.category
      
      
        return cell
    }
}

