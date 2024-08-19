//
//  HomeViewController.swift
//  TripEase
//
//  Created by Naitik Ratilal Patel on 16/08/24.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var featuredImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @IBAction func addTripDidTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AddTripViewController") as! AddTripViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func listTripsDidTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "TripListViewController") as! TripListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Private Methods
extension HomeViewController {
    
    private func setupView() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        featuredImg.layer.cornerRadius = 40
        featuredImg.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

