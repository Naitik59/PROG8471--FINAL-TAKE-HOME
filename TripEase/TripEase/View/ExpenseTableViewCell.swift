//
//  ExpenseTableViewCell.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 18/08/24.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var expenseLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
    }
    
    func configureCell(title: String, expense: Double) {
        titleLbl.text = title
        expenseLbl.text = "\(expense)"
    }
}
