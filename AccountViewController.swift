//
//  AccountViewController.swift
//  deabeteplus
//
//  Created by pasin on 14/12/2562 BE.
//  Copyright © 2562 Ji Ra. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, BaseViewController {
    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
}


/// MARK: Function
extension AccountViewController {
    @IBAction func doChangeProfile() {
        Navigator.shared.showSelectProfileView(self, type: .selectFromAccount)
    }
    
    @IBAction func doLogout() {
        showLogutAction()
    }
    
    func configureView() {
        guard let user = UserManager.shared.currentUser, let profile = user.currentProfile else { return }
        nameLabel.text = profile.name
        if let image = profile.image {
            profileImageView.kf.setImage(with: URL(string: image))
        } else {
            profileImageView.image = UIImage(named: "user")
        }
    }
}
