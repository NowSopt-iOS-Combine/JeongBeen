//
//  ViewController.swift
//  2nd assignment
//
//  Created by 왕정빈 on 2024/04/07.
//

import UIKit
import Combine
import CombineCocoa

class LoginViewController: UIViewController {
    
    let loginView = LoginView()
    let viewModel = LoginViewModel()
    private var subsscriptions = Set<AnyCancellable>()
    let nickNameViewModel = CreateNickNameViewModel()
    
    var nickName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        setAdditionalTextFieldSetting()
        setLoginButton()
        createNickName()
        
        loginView.idTextField.textPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.emailInput, on: viewModel)
            .store(in: &subsscriptions)
        
        viewModel.emailValidationPublisher
            .receive(on: RunLoop.main)
            .sink { isMatched in
                print(isMatched ? "유효한 이메일 형식입니다." : "유효하지 않은 이메일 형식입니다.")
            }
            .store(in: &subsscriptions)
        
        nickNameViewModel.nickNameSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] nickName in
                guard let self else { return }
                self.loginView.combineLabel.text = nickName
            }
            .store(in: &subsscriptions)
    }
    
    override func loadView() {
        view = loginView
    }
    
    // MARK: - set loginButton
    private func setLoginButton() {
        loginView.loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
    }
    
    @objc func tappedLoginButton() {
        viewModel.validityCheck()
    }
    
    private func updateLoginButtonState() {
        let id = loginView.idTextField.text ?? ""
        let password = loginView.passwordField.text ?? ""
        let isEnabled = !id.isEmpty && !password.isEmpty
        setButtonAttribute(button: loginView.loginButton,
                           isEnabled: isEnabled,
                           backgroundColor: isEnabled ? .red : nil,
                           titleColor: isEnabled ? .white : .lightGray
        )
    }
    
    private func setButtonAttribute(button: UIButton, isEnabled: Bool, backgroundColor: UIColor?, titleColor: UIColor) {
        button.isEnabled = isEnabled
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
    }
    
    // MARK: - set createNickName
    private func createNickName() {
        loginView.createNickNameButton.addTarget(self, action: #selector(showModalView), for: .touchUpInside)
    }
    
    @objc private func showModalView() {
        let createNickNameVC = CreateNickNameViewController(viewModel: nickNameViewModel)
        
        if let sheet = createNickNameVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        
        createNickNameVC.dataBind = { [weak self] nickName in
            guard let self = self else { return }
            self.nickName = nickName
        }
        
        self.present(createNickNameVC, animated: true)
    }
    
    private func toMakeNickNameAlert() {
        let alert = UIAlertController(title: nil, message: "닉네임을 생성하세요", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    // MARK: - additional setting
    private func setDelegate() {
        loginView.idTextField.delegate = self
        loginView.passwordField.delegate = self
    }
    
    private func setAdditionalTextFieldSetting() {
        let eyeButton = loginView.passwordEyeButton
        let clearButtonForID = loginView.clearTextButtonForID
        let clearButtonForPW = loginView.clearTextButtonForPW
        
        clearButtonForID.addTarget(self, action: #selector(tappedClearButtonForID), for: .touchUpInside)
        clearButtonForPW.addTarget(self, action: #selector(tappedClearButtonForPW), for: .touchUpInside)
        eyeButton.addTarget(self, action: #selector(tappedEyeButton), for: .touchUpInside)
    }
}

// MARK: - set textField
extension LoginViewController: UITextFieldDelegate {
    //textField 클릭하면 테두리 변경
    func textFieldDidBeginEditing(_ textField: UITextField) {
        highlightBorder(textField, color: .white)
    }
    
    //textField editing 끝나면 테두리 원상태
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
    }
    
    //키보드 return 클릭시 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        setAdditionalButton()
    }
    
    //화면 터치시 키보드 내려감
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setAdditionalButton() {
        let idTextfield = loginView.idTextField
        let pwTextfield = loginView.passwordField
        
        updateButtonVisibility(id: idTextfield.text, password: pwTextfield.text)
        
        updateLoginButtonState()
    }
    
    private func updateButtonVisibility(id: String?, password: String?) {
        guard let id = id else { return }
        guard let password = password else { return }
        
        let isIdEmpty = id.isEmpty
        let isPasswordEmpty = password.isEmpty
        
        loginView.clearTextButtonForID.isHidden = isIdEmpty
        loginView.clearTextButtonForPW.isHidden = isPasswordEmpty
        loginView.passwordEyeButton.isHidden = isPasswordEmpty
    }
    
    @objc func tappedEyeButton() {
        let eyeButton = loginView.passwordEyeButton
        let passwordField = loginView.passwordField
        
        if passwordField.isSecureTextEntry == true {
            eyeButton.setImage(UIImage.init(systemName: "eye"), for: .normal)
            passwordField.isSecureTextEntry = false
        } else {
            eyeButton.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
            passwordField.isSecureTextEntry = true
        }
    }
    
    @objc func tappedClearButtonForID() {
        loginView.idTextField.text = ""
        textFieldDidChangeSelection(loginView.idTextField)
    }
    
    @objc func tappedClearButtonForPW() {
        loginView.passwordField.text = ""
        textFieldDidChangeSelection(loginView.passwordField)
    }
    
    func highlightBorder(_ textField: UITextField, color: UIColor) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = color.cgColor
    }
}
