//
//  ImageSearchViewCollectionCell.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit
import SnapKit
import Kingfisher

class ImageSearchCollectionViewCell: BaseCollectionViewCell {
    
    let searchImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        [searchImageView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        searchImageView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}

