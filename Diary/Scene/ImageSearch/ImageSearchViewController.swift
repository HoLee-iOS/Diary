//
//  ImageSearchViewController.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit
import Kingfisher

class ImageSearchViewController: BaseViewController {
    
    let mainView = ImageSearchView()
    
    //3. 프로토콜 타입으로 공간 만듦
    var delegate: SelectImageDelegate?
    
    var setImage: ((String) -> ())?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "chevron.backward"), primaryAction: UIAction(handler: { _ in
            self.dismiss(animated: true)
        }), menu: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", image: nil, primaryAction: UIAction(handler: { _ in
//            self.setImage?(ImageData.selectImage)
            
            guard let selectImage = self.mainView.selectImage else {
                //nil값일때 실행
                self.showToastMessage(message: "사진을 선택해주세요")
                return
            }
            //값이 있을때 실행
            self.delegate?.sendImageData(image: selectImage)
            
            self.dismiss(animated: true)
            
        }), menu: nil)
        
    }
    
}
 



