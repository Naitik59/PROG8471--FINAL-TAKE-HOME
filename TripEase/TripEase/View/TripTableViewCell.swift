//
//  TripTableViewCell.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 18/08/24.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tripNameLbl: UILabel!
    @IBOutlet weak var destinationLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
    }
    
    func configureCell(title: String, fromDestination: String, toDestination: String, date: String) {
        tripNameLbl.text = title
        destinationLbl.text = "• From: \(fromDestination) • To: \(toDestination)"
        dateLbl.text = date
    }
}
