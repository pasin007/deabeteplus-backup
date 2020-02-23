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
    
    
    //MARK: Properties
    var food: Food!
    var delegate: FoodDetailViewControllerDelegate!
    
    var foodImageUrl: String = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carboLabel: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    @IBOutlet weak var foodImageView: UIImageView!
    private let imageViewModel: ImageViewModel = ImageViewModel()
    private let foodViewModel: FoodViewModel = FoodViewModel()
    
    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // Do any additional setup after loading the view.
    }

}


// MARK: Function
extension FoodDetailViewController {
    @IBAction func doClose() {
        dismiss(animated: true) { [weak self] in
            self?.delegate.statusScan = true
        }
    }
    
    @IBAction func doEat() {
        uploadImage(food.name)
    }
    
    @IBAction func dontEat() {
        dismissView()
    }
    
    private func uploadImage(_ name: String) {
        guard let image = foodImageView.image else { return }
        imageViewModel.uploadImage(image, path: "scan", onSuccess: { [weak self] (url) in
            print(url.absoluteString)
            self?.doSaveScanHistory(name,url.absoluteString)
            
        }) { (error) in
                
        }
    }
    
    private func doSaveScanHistory(_ name: String,_ imageUrl: String) {
        let parms: [String:Any] = [
            "user_id" : UserManager.shared.userId!,
            "image" : imageUrl,
            "name" : name
        ]
//        debugPrint(parms)
        foodViewModel.scanFood(parms, onSuccess: { (food) in
            print(food)
        }) { (error) in
                
        }
    }
}

// MARK: Pass Data form delegate
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

