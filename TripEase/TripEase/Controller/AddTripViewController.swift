//
//  AddTripViewController.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 16/08/24.
//

import UIKit

class AddTripViewController: UIViewController {

    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var todoTextView: UITextView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        assignDelegates()
    }
    
    @IBAction func resetDidTapped(_ sender: UIButton) {
        resetFields()
    }
    
    @IBAction func addDidTapped(_ sender: UIButton) {
        
        if isAnyOfTextFieldEmpty() {
            errorLbl.isHidden = false
            return
        }
        
        addTrip()
    }
}

extension AddTripViewController {
    
    private func setupView() {
        self.title = "Add a Trip"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        startDateView.layer.cornerRadius = 10
        endDateView.layer.cornerRadius = 10
        
        todoTextView.layer.borderWidth = 0.5
        todoTextView.layer.borderColor = UIColor.black.cgColor
        todoTextView.layer.cornerRadius = 10
        
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = Date()
    }
    
    private func assignDelegates() {
        tripNameTextField.delegate = self
        fromTextField.delegate = self
        toTextField.delegate = self
        todoTextView.delegate = self
    }
    
    private func resetFields() {
        tripNameTextField.text = ""
        toTextField.text = ""
        fromTextField.text = ""
        todoTextView.text = ""
        errorLbl.isHidden = true
    }
    
    private func isAnyOfTextFieldEmpty() -> Bool {
        return todoTextView.text?.isEmpty == true || tripNameTextField.text?.isEmpty == true || toTextField.text?.isEmpty == true || fromTextField.text?.isEmpty == true
    }
    
    private func addTrip() {
        let tripName = tripNameTextField.text ?? ""
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let from = fromTextField.text ?? ""
        let to = toTextField.text ?? ""
        let thingsToDo = todoTextView.text ?? ""
        
        if startDate > endDate {
            self.presentAlert(with: "Oops!", message: "Your trip starting date is greater then the end date. Please, check and verify!")
            return
        }
        
        let trip = Trip(title: tripName, from: from, to: to, startDate: startDate, endDate: endDate, thingsToDo: thingsToDo)
        
        CoreDataMethods.shared.addTrip(trip: trip) { success in
            self.presentAlert(with: success ? "Success" : "Error", message: success ? "\(tripName) added successfully into the list" : "Error while adding \(tripName) into the list")
            self.resetFields()
        }
    }
}


//MARK: - UITextFieldDelegate, UITextViewDelegate
extension AddTripViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        errorLbl.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLbl.isHidden = true
    }
}


extension UIViewController {
    
    func presentAlert(with title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
