//
//  ImageAPIManager.swift
//  Diary
//
//  Created by 이현호 on 2022/08/23.
//

import Foundation

import Alamofire
import SwiftyJSON

class ImageAPIManager {
    
    static let shared = ImageAPIManager()
    
    private init() {}
    
    func callRequest(query: String, handler: @escaping ([String]) -> ()) {
        
        guard let text = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        let url = "\(EndPoint.imageURL)\(text)&client_id=\(ACCESSKey.unsplash)"
        
        AF.request(url, method: .get).validate().responseData { response in
            switch response.result {
                //성공케이스에 대한 설정
            case .success(let value):
                
                let json = JSON(value)
                print(json)

                let urls = json["results"].arrayValue.map { $0["urls"]["thumb"].stringValue }
                handler(urls)
                
                //실패케이스에 대한 설정
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
