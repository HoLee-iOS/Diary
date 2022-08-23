//
//  BaseView.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit

import SnapKit

class BaseView: UIView {
    
    //코드베이스로 UI 짤 때 XIB가 없을때 호출
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setConstraints()
    }
    
    //실행되지 않음
    //required이기 때문에 코드베이스로 UI를 짜더라도 반드시 호출헤줘야함
    //XIB로 만든다면 실행되기 때문에 사용하지 않아야함
    //XIB사용 할 때 configureUI() setConstaints()의 호출은 required init에 해줘야함
    //스토리보드로 UI 짤 때 XIB 파일 사용할 경우 호출
    required init?(coder: NSCoder) {
        //fatalError가 아닌 아래와 같이 처리 가능
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented") //런타임 오류
    }
    
    func configureUI() { }
    
    func setConstraints() { }
    
}
