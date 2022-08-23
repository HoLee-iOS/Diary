//
//  WriteViewController.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit

import RealmSwift
import Kingfisher
import SnapKit

class WriteViewController: BaseViewController {
    
    var mainView = WriteView()
    let localRealm = try! Realm()
    
    var imageURL = ""
    
    var setImage: ((String)->())?
    
    //뷰컨의 루트뷰를 설정하는 코드
    //뷰디드로드 호출하기 전에 자동으로 loadView를 호출함
    //super.loadView X => 기본값인 nil이 호출됨
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configure() {
        
        mainView.titleTextField.addTarget(self, action: #selector(titleTextFieldClicked(_:)), for: .editingDidEndOnExit)
        
        mainView.addPhotoButton.addTarget(self, action: #selector(addPhotoButtonClicked), for: .touchUpInside)
        
        let cancelButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(cancelButtonClicked))
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonClicked))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc func saveButtonClicked() {
        let task = UserDiary(diaryTitle: mainView.titleTextField.text!, diaryContent: mainView.contentTextView.text, diaryDate: Date(), regdate: Date(), photo: self.imageURL)
        
        try! localRealm.write {
            localRealm.add(task)
        }
        
        print(print("Realm is located at:", localRealm.configuration.fileURL!))
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func titleTextFieldClicked(_ textField: UITextField) {
        guard let text = textField.text, text.count > 0 else {
            showToastMessage(message: "값을 입력해주세요.")
            return
        }
    }
    
    @objc func addPhotoButtonClicked() {
        let vc = ImageSearchViewController()
        vc.setImage = { image in
            self.imageURL = image
            self.mainView.photoImageView.kf.setImage(with: URL(string: image))
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
