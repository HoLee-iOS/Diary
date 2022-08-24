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

//1.프로토콜 선언
protocol SelectImageDelegate {
    func sendImageData(image: UIImage)
}

class WriteViewController: BaseViewController {
    
    var mainView = WriteView()
    let localRealm = try! Realm() //도큐먼트 접근 코드 내장
    
    var image: UIImage?
    
    var setImage: ((String)->())?
    
    //뷰컨의 루트뷰를 설정하는 코드
    //뷰디드로드 호출하기 전에 자동으로 loadView를 호출함
    //super.loadView X => 기본값인 nil이 호출됨
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Realm is located at", localRealm.configuration.fileURL!)
    }
    
    override func configure() {
        
        mainView.addPhotoButton.addTarget(self, action: #selector(addPhotoButtonClicked), for: .touchUpInside)
        
        let cancelButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(cancelButtonClicked))
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonClicked))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // Realm + 이미지 도큐먼트 저장
    @objc func saveButtonClicked() {
        
        //타이틀 유무 체크
        guard let title = mainView.titleTextField.text else {
            showToastMessage(message: "제목을 입력해주세요")
            return
        }
        
        let task = UserDiary(diaryTitle: title, diaryContent: mainView.contentTextView.text, diaryDate: Date(), regdate: Date(), photo: nil)
        
        do {
            try localRealm.write {
                localRealm.add(task)
            }
        } catch let error {
            print(error)
        }
        
        //이미지 유무 체크후 도큐먼트에 이미지 저장
        if let image = mainView.photoImageView.image {
            saveImageToDocument(fileName: "\(task.objectId).jpg", image: image)
        }
        
        dismiss(animated: true)
    }
    
    @objc func cancelButtonClicked() {
        dismiss(animated: true)
    }
    
    @objc func addPhotoButtonClicked() {
        let vc = ImageSearchViewController()
        //        vc.setImage = { image in
        //            self.imageURL = image
        //            self.mainView.photoImageView.kf.setImage(with: URL(string: image))
        //        }
        //4. 빈공간에 할당
        vc.delegate = self
        image = vc.mainView.selectImage
        transition(vc, transitionStyle: .presentFullScreen)
    }
    
}

//2. 프로토콜 채택
extension WriteViewController: SelectImageDelegate {
    
    func sendImageData(image: UIImage) {
        mainView.photoImageView.image = image
        print(#function)
    }
    
}
