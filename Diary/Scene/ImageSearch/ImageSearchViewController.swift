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
    
    var setImage: ((String) -> ())?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = ""
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "선택", image: nil, primaryAction: UIAction(handler: { _ in
            self.setImage?(ImageData.selectImage)
            self.navigationController?.popViewController(animated: true)
        }), menu: nil)
        
    }
    
}
 



