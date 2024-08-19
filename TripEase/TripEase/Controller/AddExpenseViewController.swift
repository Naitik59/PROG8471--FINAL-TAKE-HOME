//
//  AddExpenseViewController.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 16/08/24.
//

import UIKit

class AddExpenseViewController: UIViewController {
    
    @IBOutlet weak var expenseTitleTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var totalExpenseLbl: UILabel!
    @IBOutlet weak var emptyDataLbl: UILabel!
    
    var trip: Trip?
    var expenses: [Expense] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchExpenseList()
        setupView()
    }
    
    @IBAction func resetDidTapped(_ sender: UIButton) {
        amountTextField.text = ""
        expenseTitleTextField.text = ""
        errorLbl.isHidden = true
    }
    
    @IBAction func addExpense() {
        
        if expenseTitleTextField.text?.isEmpty == true || amountTextField.text?.isEmpty == true {
            errorLbl.text = "Please fill all the required fields!"
            errorLbl.isHidden = false
            return
        }
    
        guard let amount = Double(amountTextField.text ?? "") else {
            self.presentAlert(with: "Oops", message: "Expense must be in a formate of number.")
            return
        }
        
        let expense = Expense(tripId: trip?.id ?? "", title: expenseTitleTextField.text ?? "", amount: amount)
        
        CoreDataMethods.shared.addExpense(expense: expense) { success in
            self.presentAlert(with: success ? "Success" : "Error", message: success ? "\(self.expenseTitleTextField.text ?? "") added successfully into the list" : "Error while adding \(self.expenseTitleTextField.text ?? "") into the list")
            
            if success {
                DispatchQueue.main.async { [self] in
                    expenseTitleTextField.text = ""
                    amountTextField.text = ""
                    emptyDataLbl.isHidden = true
                    expensesTableView.isHidden = false
                    expenses.append(expense)
                    calculateTotalExpense()
                    expensesTableView.reloadData()
                }
            }
        }
    }
}

//MARK: - Private Methods
extension AddExpenseViewController {
    
    private func setupView() {
        self.title = "Add Expense"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        tripTitle.text = trip?.title
        
        expenseTitleTextField.delegate = self
        amountTextField.delegate = self
        
        expensesTableView.delegate = self
        expensesTableView.dataSource = self
        expensesTableView.separatorStyle = .none
    }
    
    private func fetchExpenseList() {
        expenses = CoreDataMethods.shared.fetchExpenses(for: trip?.id ?? "")
        
        if expenses.count > 0 {
            calculateTotalExpense()
        } else {
            totalExpenseLbl.text = "Total expense: 0"
            expensesTableView.isHidden = true
            emptyDataLbl.isHidden = false
        }
    }
    
    private func calculateTotalExpense() {
        var totalExpense: Double = 0
        
        expenses.forEach { expense in
            totalExpense += expense.amount
        }
        
        errorLbl.isHidden = true
        totalExpenseLbl.text = "Total expense: \(totalExpense)"
    }
}


//MARK: - TableViewDelegate
extension AddExpenseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ExpenseTableViewCell
        cell.configureCell(title: expenses[indexPath.row].title, expense: expenses[indexPath.row].amount)
        cell.selectionStyle = .none
        return cell
    }
}


//MARK: - UITextFieldDelegate
extension AddExpenseViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLbl.isHidden = true
    }
}
