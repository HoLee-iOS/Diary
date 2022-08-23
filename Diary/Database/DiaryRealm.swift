//
//  RealmSwift.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import Foundation
import RealmSwift

//UserDiary: 테이블 이름
//@Persisted: 컬럼
class UserDiary: Object {
    //PK(필수): Int, UUID, ObjectID
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    @Persisted var diaryTitle: String //제목(필수)
    @Persisted var diaryContent: String? //내용(옵션)
    @Persisted var diaryDate = Date() //작성 날짜(필수)
    @Persisted var regdate = Date() //등록 날짜(필수)
    @Persisted var favorite: Bool //즐겨찾기(필수)
    @Persisted var photo: String? //사진 String(옵션)
    
    convenience init(diaryTitle: String, diaryContent: String?, diaryDate: Date, regdate: Date, photo: String?) {
        self.init()
        self.diaryTitle = diaryTitle
        self.diaryContent = diaryContent
        self.diaryDate = diaryDate
        self.regdate = regdate
        self.favorite = false
        self.photo = photo
    }
}


