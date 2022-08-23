//
//  BaseViewController.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit

import Toast

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        setConstraints()
        
    }
    
    func configure() { }
    
    func setConstraints() { }
    
    func showToastMessage(message: String) {
        self.view.makeToast(message, position: .center)
    }
}
