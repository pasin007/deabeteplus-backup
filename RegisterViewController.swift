//
//  RegisterViewController.swift
//  deabeteplus
//
//  Created by pasin on 14/12/2562 BE.
//  Copyright © 2562 Ji Ra. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, BaseViewController {

    enum Gender: Int, CaseIterable {
        case male = 0, female
        
        var title: String {
            switch self {
            case .male:
                return "ชาย"
            case .female:
                return "หญิง"
            }
        }
    }
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var dateTextfield: UITextField!
    @IBOutlet weak var genderTextfield: UITextField!
    
    private var viewModel: UserViewModel = UserViewModel()
    
    private var pickerGender: UIPickerView = UIPickerView()
    
    private var pickerDate: UIDatePicker = UIDatePicker()
    
    private var isShowPassword: Bool = false {
        didSet {
            passwordTextfield.isSecureTextEntry = !isShowPassword
        }
    }
    private var birthdate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        createDatePicker()
        createGenderPicker()
    }


}

/// MARK: Function
extension RegisterViewController {
    @IBAction func doShowPassword() {
        isShowPassword = !isShowPassword
    }
    
    @IBAction func navigatorToLogin() {
        Navigator.shared.navigatorToLogin(self)
    }
    
    @IBAction func register() {
        guard let email = emailTextfield.text,
            let password = passwordTextfield.text,
            let name = nameTextfield.text,
            let gender = genderTextfield.text,
            !email.trim.isEmpty,
            !password.trim.isEmpty,
            !name.trim.isEmpty,
            !birthdate.trim.isEmpty,
            !gender.trim.isEmpty else { return }
        
        let parms: [String:Any] = [
            "email": email,
            "password": password,
            "name": name,
            "gender": gender,
            "birthdate": birthdate
        ]
        
        viewModel.register(parms, onSuccess: { [weak self] (user) in
            UserManager.shared.login(user)
            self?.dismiss(animated: true)
        }) { (error) in
            // do something ....
        }
    }
    

}

/// MARK: Date Picker
extension RegisterViewController {
    func createDatePicker() {
        // 1 - configure Date Picker
        pickerDate.datePickerMode = .date
        pickerDate.calendar = Calendar(identifier: .buddhist)
        pickerDate.locale = Locale(identifier: "th")
        
        // 2 - create tool bar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // 3 - add toolbar action
        let done = UIBarButtonItem(title: "done", style: .plain, target: nil, action: #selector(self.showdate))
        toolbar.setItems([done], animated: false)
        
        // 4 - set inputView
        dateTextfield.inputAccessoryView = toolbar
        dateTextfield.inputView = pickerDate
    }
    
    @objc func showdate(){
//        print("date : \(pickerDate.date)")
        
        // 5 - create formatter to text field
        let dateformate = DateFormatter()
        dateformate.locale = Locale(identifier: "th")
        dateformate.dateFormat = "dd MMMM yyyy"
        
        // 6 - formatter date
        let string = dateformate.string(from: pickerDate.date)
        dateTextfield.text = string
        
        
          // 5 - create formatter to database
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        formater.locale = Locale(identifier: "th")
        
        birthdate = formater.string(from: pickerDate.date)
        
        
        view.endEditing(true)
    }
}

/// MARK: PickView
extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        /// row
        guard let gender = Gender(rawValue: row) else { return nil }
        return gender.title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let gender = Gender(rawValue: row) else { return }
        genderTextfield.text = gender.title
    }
    
    func createGenderPicker() {
        // set delegate & dataSource
        pickerGender.delegate = self
        pickerGender.dataSource = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let done = UIBarButtonItem(title: "done", style: .plain, target: nil, action: #selector(self.done))
        toolbar.setItems([done], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        genderTextfield.inputAccessoryView = toolbar
        genderTextfield.inputView = pickerGender
    }
    
    @objc func done() {
        if genderTextfield.text == "" {
            genderTextfield.text = Gender.male.title
        }
        view.endEditing(true)
    }
    
}
