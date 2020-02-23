//
//  FoodViewController.swift
//  deabeteplus
//
//  Created by pasin on 19/1/2563 BE.
//  Copyright © 2563 Ji Ra. All rights reserved.
//

import UIKit

class FoodViewController: UIViewController, BaseViewController {

    // MARK: Outlet
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Properties
    private var food: Food!
    
    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        configureView()
        // Do any additional setup after loading the view.
    }


}

// MARK: COnfiguration
extension FoodViewController {
    func configure(_ food: Food) {
        self.food = food
    }
    
    func configureView() {
        titleLabel.text = food.name
    }
}
