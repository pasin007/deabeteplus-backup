//
//  FoodDetailViewController.swift
//  deabeteplus
//
//  Created by pasin on 15/12/2562 BE.
//  Copyright © 2562 Ji Ra. All rights reserved.
//

import UIKit

protocol FoodDetailViewControllerDelegate {
    var statusScan: Bool { get set }
    var foodImage: UIImage? { get set }
}

class FoodDetailViewController: UIViewController, BaseViewController {
    
    var food: Food!
    var delegate: FoodDetailViewControllerDelegate!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carboLabel: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    @IBOutlet weak var foodImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }

}

/// MARK: Pass Data form delegate
extension FoodDetailViewController {
    private func initView() {
        nameLabel.text = "name : " + food.name
        proteinLabel.text = "protein : \(food.protein) กรัม"
        carboLabel.text = "carbo : \(food.carbo) กรัม"
        sodiumLabel.text = "sodium : \(food.sodium) มิลลิกรัม"
        kcalLabel.text = "kcal : \(food.kcal) กิโลเเคลอรี่"
        fatLabel.text = "fat : \(food.fat) กรัม"
        
        foodImageView.image = delegate.foodImage
    }
}


/// MARK: Function
extension FoodDetailViewController {
    @IBAction func doClose() {
        dismiss(animated: true) { [weak self] in
            self?.delegate.statusScan = true
        }
    }
}
