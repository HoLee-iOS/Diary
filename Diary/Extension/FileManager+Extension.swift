//
//  FileManager+Extension.swift
//  Diary
//
//  Created by 이현호 on 2022/08/24.
//

import Foundation
import UIKit

extension UIViewController {
    
    //파일앱의 백업파일 경로
    func fileDirectoryPath() -> String? {
        return  "file:///Users/ihyeonho/Library/Developer/CoreSimulator/Devices/080C60FA-4C76-48DD-8F1F-1433174FE3BF/data/Containers/Data/Application/7855B45A-5251-43D9-93CE-D26444DE9DF8/tmp/com.skylerLee.Diary-Inbox"
        
   
    }
    
    func documentDirectoryPath() -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil } //Document 경로
        return documentDirectory
    }
    
    //도큐먼트의 이미지 로드
    func loadImageFromDocument(fileName: String) -> UIImage? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil } //Document 경로
        let fileURL = documentDirectory.appendingPathComponent(fileName) //세부 경로. 이미지를 저장할 위치
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return UIImage(systemName: "heart.fill")
        }
    }
    
    
    
    func saveImageToDocument(fileName: String, image: UIImage) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return } //Document 경로
        let fileURL = documentDirectory.appendingPathComponent(fileName) //세부 경로. 이미지를 저장할 위치
        guard let data = image.jpegData(compressionQuality: 0.5) else { return } //이미지의 용량 줄이기(압축)
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("file save error", error)
        }
        
    }
    
    func fetchDocumentZipFile() -> [String] {
        
        do {
            let path = documentDirectoryPath()!
            
            //includingPropertiesForKeys: 더 추가적인 정보를 가져오는 것 [.으로 가져올 수 있음]
            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            print("docs: \(docs)")
            
            //확장자가 zip인 애를 가져오기
            let zip = docs.filter { $0.pathExtension == ".zip" }
            print("zip: \(zip)")
            
            let result = zip.map { $0.lastPathComponent }
            print("result: \(result)")
            
            return result
            
        } catch {
            print("Error")
            
            return [""]
        }
    }
}
