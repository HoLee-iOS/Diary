//
//  DiaryImageView.swift
//  Diary
//
//  Created by 이현호 on 2022/08/23.
//

import UIKit

class DiaryImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupView() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = Constants.Desgin.cornerRadius
        layer.borderWidth = Constants.Desgin.borderWidth
        layer.borderColor = Constants.BaseColor.border
    }

}

