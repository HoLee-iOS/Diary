//
//  WriteView.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit

//루트뷰를 코드로 따로 짠 후에 뷰컨에서 아래에서 짠 뷰를 로드해오는 형태
final class WriteView: BaseView {
    
    let photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGreen
        return view
    }()
    
    let titleTextField: CustomTextField = {
        let view = CustomTextField()
        view.placeholder = "제목을 입력해주세요"
        return view
    }()
    
    let dateTextField: CustomTextField = {
        let view = CustomTextField()
        view.placeholder = "날짜를 입력해주세요"
        return view
    }()
    
    let contentTextView: UITextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    let addPhotoButton: UIButton = {
        let button = UIButton()
        let size = UIImage.SymbolConfiguration(pointSize: 30)
        button.setImage(UIImage(systemName: "plus", withConfiguration: size), for: .normal)
        return button
    }()
    
    let tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func configureUI() {
        
        [photoImageView, titleTextField, dateTextField, contentTextView, addPhotoButton].forEach {
            self.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.leadingMargin.equalTo(20)
            make.trailingMargin.equalTo(-20) //오른쪽에서 띄고 싶을때는 - 줘야함 주의!
            make.height.equalTo(self).multipliedBy(0.3) //view의 equalHeight 비율로 높이 주는 것과 같음
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(20)
            make.leadingMargin.equalTo(20)
            make.trailingMargin.equalTo(-20) //오른쪽에서 띄고 싶을때는 - 줘야함 주의!
            make.height.equalTo(50)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leadingMargin.equalTo(20)
            make.trailingMargin.equalTo(-20) //오른쪽에서 띄고 싶을때는 - 줘야함 주의!
            make.height.equalTo(50)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(dateTextField.snp.bottom).offset(20)
            make.leadingMargin.equalTo(20)
            make.trailingMargin.equalTo(-20) //오른쪽에서 띄고 싶을때는 - 줘야함 주의!
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        
        addPhotoButton.snp.makeConstraints { make in
            make.bottom.equalTo(photoImageView.snp.bottom).offset(-8)
            make.trailing.equalTo(photoImageView.snp.trailing).offset(-8)
        }
        
    }
    
}
