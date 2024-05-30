//
//  CreateNickNameViewModel.swift
//  CombineStudy
//
//  Created by 왕정빈 on 5/31/24.
//

import Foundation
import Combine

final class CreateNickNameViewModel {
    
    let nickNameSubject = PassthroughSubject<String, Never>()
    
    func setNickName(_ nickName: String) {
        nickNameSubject.send(nickName)
    }
}
