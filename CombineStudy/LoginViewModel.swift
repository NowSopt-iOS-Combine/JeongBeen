//
//  LoginViewModel.swift
//  2nd assignment
//
//  Created by 왕정빈 on 2024/05/09.
//

import Foundation
import Combine
import CombineCocoa

final class LoginViewModel {
    
    var emailInput: String?
    
    let emailValidationPublisher = PassthroughSubject<Bool, Never>()
    
    func validityCheck() {
        
        guard let email = emailInput,
              isValidEmail(emailID: email)
        else {
            emailValidationPublisher.send(false)
            return
        }
        
        emailValidationPublisher.send(true)
    }
    
    private func isValidEmail(emailID: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9]+@[A-Za-z0-9]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
}
