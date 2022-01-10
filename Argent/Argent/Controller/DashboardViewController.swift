//
//  DashboardViewController.swift
//  Argent
//
//  Created by Christine Ong on 12/31/21.
//

import Foundation
import UIKit
import Firebase
import SwiftUI
import Charts

struct Constants{
static var date = Date()
}

class DashboardViewController: UIViewController{
    
    var currDateString: String = ""
    
    @IBAction func afterDayPressed(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        Constants.date = Constants.date.dayAfter
        currDateString = formatter.string(from: Constants.date)
        if Calendar.current.isDateInToday(Constants.date){
            currDateLabel.text = "Today"
        }else{
            currDateLabel.text = currDateString
            }
        customizeChart(dataPoints: [], values: [0.0].map{ Double($0) })
        totalSpent.text = String(0.0)
        loadMessages()
    }
    
    @IBAction func beforeDayPressed(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        Constants.date = Constants.date.dayBefore
        currDateString = formatter.string(from: Constants.date)
        if Calendar.current.isDateInToday(Constants.date){
            currDateLabel.text = "Today"
        }else{
            currDateLabel.text = currDateString
            }
        customizeChart(dataPoints: [], values: [0.0].map{ Double($0) })
        totalSpent.text = String(0.0)
        loadMessages()
        
    }
    
    @IBOutlet weak var currDateLabel: UILabel!
    
    @IBOutlet weak var totalSpent: UILabel!
    var returnVals2: [Double] = []
    
    @IBOutlet weak var viewPieChart: PieChartView!
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
      var colors: [UIColor] = []
      for _ in 0..<numbersOfColor {
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))
        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
        colors.append(color)
      }
      return colors
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
      
      // 1. Set ChartDataEntry
      var dataEntries: [ChartDataEntry] = []
      for i in 0..<dataPoints.count {
        let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
        dataEntries.append(dataEntry)
      }
      // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
      pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
      // 3. Set ChartData
      let pieChartData = PieChartData(dataSet: pieChartDataSet)
      let format = NumberFormatter()
        format.numberStyle = .currency
      let formatter = DefaultValueFormatter(formatter: format)
      pieChartData.setValueFormatter(formatter)
        pieChartData.setValueFont(NSUIFont(name: "Futura", size: 0)!)
      // 4. Assign it to the chart’s data
        self.viewPieChart.legend.enabled = true
        viewPieChart.legend.formSize = 15
        viewPieChart.legend.textColor = UIColor.white
        viewPieChart.legend.font = NSUIFont(name: "Futura", size: 15)!
        viewPieChart.legend.horizontalAlignment = Legend.HorizontalAlignment.center
      viewPieChart.data = pieChartData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMessages()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        currDateString = formatter.string(from: Constants.date)
        if Calendar.current.isDateInToday(Constants.date){
            currDateLabel.text = "Today"
        }else{
            currDateLabel.text = currDateString
            }
        
        //Looks for single or multiple taps.
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    

    
    func loadMessages(){
        let dateString = NSDate().timeIntervalSince1970
        var categories: [String] = []
        var totalExpenses: [Double] = []
        let db = Firestore.firestore()
                db.collection("expenses")
                    .order(by: "date")
                    .addSnapshotListener { [self] (querySnapshot, error) in
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if data["user"] as! String == (Auth.auth().currentUser?.email)! && data["currDate"] != nil && data["currDate"] as! String==currDateString{
                            let newMessage = Expense(amount: data["amount"] as! Double, category: data["category"] as! String, date: dateString, iden: data["iden"] as? String ?? NSUUID().uuidString, user: Auth.auth().currentUser?.email ?? "random@email.com" ,
                                                     currDate: currDateString)
                            var sum = 0.0
                            categories.append(newMessage.category)
                            totalExpenses.append(newMessage.amount)
                            print(categories)
                            print(totalExpenses)
                            for i in totalExpenses{
                                sum+=i
                            }
                            if let totalSpent0 = totalSpent{
                                totalSpent0.text = String(sum)
                            }
                            
                            if totalExpenses.count>0{
                                customizeChart(dataPoints: categories, values: totalExpenses.map{ Double($0) })
                            }else{
                                customizeChart(dataPoints: [], values: [])
                            }
                        }
                            }
                    
                }
                    }}
    }
    
    @IBAction func menuButton(_ sender: UIButton) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(
            .init(title: "Dashboard", style: .default) { _ in
                
            }
        )

        alert.addAction(
            .init(title: "View all expenses", style: .default) { _ in
                self.performSegue(withIdentifier: "DashToAllSegue", sender: self)
            }
        )
        
        alert.addAction(
            .init(title: "Log Out", style: .default){
                _ in
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                    self.performSegue(withIdentifier: "LogoutSegue", sender: self)
                } catch let signOutError as NSError {
                  print("Error signing out: %@", signOutError)
                }
            }
        )

        
        present(alert, animated: true)
        
    }
    
    
}

extension Date {
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}
