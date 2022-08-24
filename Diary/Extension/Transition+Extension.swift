//
//  Transition+Extension.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit

extension UIViewController {
    
    enum TransitionStyle {
        case present //네비게이션 없이 Present
        case presentNavigation //네비게이션 임베드 Present
        case presentFullScreen //네비게이션 풀스크린
        case push
    }
    
    func transition<T: UIViewController>(_ viewController: T, transitionStyle: TransitionStyle) {
        
        //만약 T가 아닌 T()를 사용한다면 전달받은 뷰컨트롤러가 아닌 새로 초기화된 뷰컨트롤러를 사용하게 됨
        //T()
        switch transitionStyle {
        case .present:
            self.present(viewController, animated: true)
        case .presentNavigation:
            let nav = UINavigationController(rootViewController: viewController)
            self.present(nav, animated: true)
        case .push:
            self.navigationController?.pushViewController(viewController, animated: true)
        case .presentFullScreen:
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
}
