//
//  BackUpTableViewCell.swift
//  Diary
//
//  Created by 이현호 on 2022/08/24.
//

import Foundation
import UIKit

class BackUpTableViewCell: BaseTableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        [titleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(8)
            make.centerY.equalTo(contentView)
        }
    }
}
