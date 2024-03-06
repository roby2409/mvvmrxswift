//
//  LoginViewController.swift
//  MVVMApp
//
//  Created by MTPC-99 on 05/04/22.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class LoginViewController : UIViewController {
    
    //Create textfield
    lazy var textFiledEmail:UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var textFieldPassword :UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var btnLogin : UIButton = {
        let btn = UIButton()
        btn.setTitle("Login", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(onTapBtnLogin), for: .touchUpInside)
        return btn
    }()
    
    var bag = DisposeBag()
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createObservables()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(textFiledEmail)
        self.view.addSubview(textFieldPassword)
        self.view.addSubview(btnLogin)
        
        NSLayoutConstraint.activate([
            textFiledEmail.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,constant: 20),
            textFiledEmail.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,constant: -20),
            textFiledEmail.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 20),
            textFieldPassword.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,constant: 20),
            textFieldPassword.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,constant: -20),
            textFieldPassword.topAnchor.constraint(equalTo: textFiledEmail.bottomAnchor,constant: 20),
            btnLogin.topAnchor.constraint(equalTo: textFieldPassword.bottomAnchor,constant: 20),
            btnLogin.widthAnchor.constraint(equalTo: textFiledEmail.widthAnchor),
            btnLogin.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
    }
    
    private func createObservables() {
        textFiledEmail.rx.text.map({$0 ?? ""}).bind(to: viewModel.email).disposed(by: bag)
        textFieldPassword.rx.text.map({$0 ?? ""}).bind(to: viewModel.password).disposed(by: bag)
        
        viewModel.isValidInput.bind(to: btnLogin.rx.isEnabled).disposed(by: bag)
        viewModel.isValidInput.subscribe( onNext: { [weak self] isValid in
            self?.btnLogin.backgroundColor = isValid ? .systemBlue :.red
        }).disposed(by: bag)
    }
    
    
    @objc func onTapBtnLogin() {
        
    }
    
}


class LoginViewModel  {
    
    var email:BehaviorSubject<String> = BehaviorSubject(value: "")
    var password:BehaviorSubject<String> = BehaviorSubject(value: "")
    
    var isValidEmail:Observable<Bool> {
        email.map{$0.isValidEmail()}
    }
    
    var isValidPassword:Observable<Bool> {
        password.map { password in
            return password.count < 6 ? false : true
        }
    }
    
    var isValidInput:Observable<Bool> {
        return Observable.combineLatest(isValidEmail, isValidPassword).map({ $0 && $1 })
    }
    //Our viewModel is ready
}


extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
