//
//  HomewViewController.swift
//  deabeteplus
//
//  Created by Ji Ra on 1/12/2562 BE.
//  Copyright © 2562 Ji Ra. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, BaseViewController {
    
    // MARK: - Outlet
//    @IBOutlet weak var calPerDayStringLabel: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            configureTableView()
        }
    }

    
    // MARK: - Properties
    private var viewModel: FoodViewModel = FoodViewModel()
    private var foods: [Food] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    private var calToEat: Int = 0
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
//        setCal()
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        fetchFood()
        guard !UserManager.shared.isLogin else {
            // isLogin
            if UserManager.shared.currentUser?.currentProfile == nil {
                Navigator.shared.showSelectProfileView(self)
            }
            return
        }
        Navigator.shared.showLoginView(self)
        
    }

}

/// MARK : Function
extension HomeViewController {
    @IBAction func showMoreView() {
        Navigator.shared.showImageView(self)
    }
    
    @IBAction func navigatorToMoreView() {
        Navigator.shared.navigateToMoreView(self)
    }
    
    func setCal() {
        guard let user = UserManager.shared.currentUser else { return }
        let calPerDayString = "\(user.cal_perday)"
//        calPerDayStringLabel.text = "\(calPerDayString)"
        print(calPerDayString)
    }
    
    func fetchFood() {
        viewModel.recommendFood(onSuccess: setFood) { (_) in
            
        }
    }
    
    func setFood(_ recommendFood: RecommendFood) {
        calToEat = recommendFood.cal_today
        self.foods = recommendFood.foods
//        calPerDayStringLabel.text = "\(foods.cal_today)"
    }
}

// MARK: - Configuration
extension HomeViewController {
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register Header
        tableView.register(HomeHeaderViewCell.nib, forHeaderFooterViewReuseIdentifier: HomeHeaderViewCell.identifier)
        
        // Register Cells
        tableView.register(FoodViewCell.nib, forCellReuseIdentifier: FoodViewCell.identifier)
    }
}

// MARK: UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell()
            
            cell.textLabel?.text = "เมนูอาหารแนะนำ"
            cell.textLabel?.textAlignment = .center
            if let font = UIFont(name: "Kodchasan-SemiBold", size: 18) {
                cell.textLabel?.font = font
            }
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .clear
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodViewCell.identifier, for: indexPath) as? FoodViewCell else { return UITableViewCell() }
        let food = foods[indexPath.row - 1]
        cell.configure(food)
        return cell
    }
    
    
}

// MARK: UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 0 else { return }
        let food = foods[indexPath.row - 1]
        Navigator.shared.navigatorToFood(self, food: food)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeHeaderViewCell.identifier) as? HomeHeaderViewCell else { return nil }
        header.configure("\(calToEat)")
        return header
    }
}
