//
//  LoginViewController.swift
//  deabeteplus
//
//  Created by pasin on 14/12/2562 BE.
//  Copyright © 2562 Ji Ra. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, BaseViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    private var viewModel: UserViewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }


}

extension LoginViewController {
    @IBAction func doLogin() {
        guard let email = emailTextfield.text,
            let password = passwordTextfield.text,
            !email.trim.isEmpty,
            !password.trim.isEmpty else { return }
        
        let parms: [String:Any] = [
            "email": email,
            "password": password
        ]
//        viewModel.login(pa
        viewModel.login(parms, onSuccess: { [weak self] user in
            UserManager.shared.login(user)
            self?.dismiss(animated: true)
        }, onError: { error in
            
        })
    }
    
    @IBAction func navigatorToRegister() {
        Navigator.shared.navigatorToRegister(self)
    }
}
