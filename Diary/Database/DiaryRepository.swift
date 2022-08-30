//
//  DiaryRepository.swift
//  Diary
//
//  Created by 이현호 on 2022/08/26.
//

import Foundation
import RealmSwift

// 여러 개의 테이블 => CRUD
protocol DiaryRepositoryType {
    func fetch() -> Results<UserDiary>
    func fetchSort(_ sort: String) -> Results<UserDiary>
    func fetchFilter() -> Results<UserDiary>
    func fetchDate(date: Date) -> Results<UserDiary>
    func updateFavorite(item: UserDiary)
    func deleteItem(item: UserDiary)
    func addItem(item: UserDiary)
}

class DiaryRepository: DiaryRepositoryType {
    
    func fetchDate(date: Date) -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).filter("diaryDate >= %@ AND diaryDate < %@", date, Date(timeInterval: 86400, since: date)) //NSPredicate
    }
    
    
    func addItem(item: UserDiary) {
        
    }
    
    //아무리 많이 생성하더라도 내부적으로는 구조체 형태로 하나의 인스턴스만 보게 만들어져있음
    let localRealm = try! Realm()
    
    func fetch() -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).sorted(byKeyPath: "diaryTitle", ascending: true)
    }
    
    func fetchSort(_ sort: String) -> Results<UserDiary> {
        localRealm.objects(UserDiary.self).sorted(byKeyPath: sort, ascending: true)
    }
    
    func fetchFilter() -> Results<UserDiary> {
        localRealm.objects(UserDiary.self).filter("diaryTitle CONTAINS[c] '이현호'")
    }
    
    func updateFavorite(item: UserDiary) {
        
        try! localRealm.write {
            
            //값을 변경하는 방법은 다양하기 때문에 모든 방법을 외우기보다는 때에 맞게 API를 활용해서 보고 사용하면 됨
            
            //하나의 레코드에서 특정 컬럼 하나만 변경
//            item.favorite = !item.favorite
            item.favorite.toggle() //반대의 Bool 타입으로 변경해주는 코드로 위와 같음
            
            //하나의 테이블에 특정 컬럼 전체 값을 변경
            //self.tasks.setValue(true, forKey: "favorite")
            
            //하나의 레코드에서 여러 컬럼들을 변경
            //self.localRealm.create(UserDiary.self, value: ["objectId": self.tasks[indexPath.row].objectId, "diaryContent": "변경 테스트", "diaryTitle": "제목임"], update: .modified)
            
            //열린 상태에서 변경하는 형태는 UX적으로 좋지 않음
            //1. 스와이프한 셀 하나만 ReloadRows 코드를 구현 => 상대적 효율성
//            tableView.reloadRows(at: [indexPath], with: .none)
            //2. 데이터가 변경되었으니 다시 Realm에서 데이터를 가져오기 => didSet 일관적 형태로 갱신
            //            self.fetchRealm()
            
            print("Realm Update")
        }
        
    }
    
    //도큐먼트의 이미지 제거
    func removeImageFromDocument(fileName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return } //Document 경로
        let fileURL = documentDirectory.appendingPathComponent(fileName) //세부 경로. 이미지를 저장할 위치
    
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            print(error)
        }
    }
    
    func deleteItem(item: UserDiary) {
        
        removeImageFromDocument(fileName: "\(item.objectId).jpg")
        
        try! localRealm.write {
            localRealm.delete(item)
        }
    }
    
    
    
}
