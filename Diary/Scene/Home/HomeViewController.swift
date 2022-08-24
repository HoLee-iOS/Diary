//
//  HomeViewController.swift
//  Diary
//
//  Created by 이현호 on 2022/08/23.
//

import UIKit

import SnapKit
import RealmSwift //Realm 1. import

class HomeViewController: BaseViewController {
    
    var imageURL = ""
    
    let localRealm = try! Realm() // Realm 2.
    
    //나중에 초기화를 해도 괜찮음
    //필요한 시점에 지연으로 프로퍼티를 만드는 것
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        //self는 초기화가 된 후에 사용이 가능함
        
        return view
    }() //let으로 선언한다면 즉시 실행 클로저
    
    var tasks: Results<UserDiary>! {
        didSet {
            //화면 갱신은 화면 전환 코드 및 생명 주기 실행 점검 필요!
            //present, overCurrentContext, overFullScreen > viewWillAppear X
            //데이터베이스의 값이 변경될때마다 테이블뷰를 갱신해줘야하기 때문에 didSet으로 한번에 처리해주는 것이 좋음
            tableView.reloadData()
            print("Tasks Changed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        
        fetchRealm()
    }
    
    func fetchRealm() {
        //Realm 3. Realm 데이터를 정렬해 tasks 에 담기
        tasks = localRealm.objects(UserDiary.self).sorted(byKeyPath: "diaryTitle", ascending: true)
    }
    
    override func configure() {
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
        
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        
        navigationItem.leftBarButtonItems = [sortButton, filterButton]
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc func plusButtonClicked() {
        let vc = WriteViewController()
        
        transition(vc, transitionStyle: .presentFullScreen)
    }
    
    @objc func sortButtonClicked() {
        tasks = localRealm.objects(UserDiary.self).sorted(byKeyPath: "regdate", ascending: true)
    }
    
    //realm filter query, NSPredicate
    @objc func filterButtonClicked() {
        
        //CONTAINS[c]를 사용하면 대소문자 구분없이 필터링 해줌
        //CONTAINS 'String값'으로 필터나 검색 기능 구현시 많이 사용함
        tasks = localRealm.objects(UserDiary.self).filter("diaryTitle CONTAINS[c] '이현호'")
        //realm 에서 String 값을 가져올 때 ''로 가져와야함
        //            .filter("diaryTitle = '오늘의 일기 14'")
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.diaryImageView.image = loadImageFromDocument(fileName: "\(tasks[indexPath.row].objectId).jpg")
        
        cell.setData(data: tasks[indexPath.row])
        
        return cell
    }
    
    //참고. TableView Editing Mode
    
    //테이블뷰 셀 높이가 작을 경우, 이미지가 없을 때, 시스템 이미지가 아닌 경우
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favorite = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            
            try! self.localRealm.write {
                
                //값을 변경하는 방법은 다양하기 때문에 모든 방법을 외우기보다는 때에 맞게 API를 활용해서 보고 사용하면 됨
                
                //하나의 레코드에서 특정 컬럼 하나만 변경
                self.tasks[indexPath.row].favorite = !self.tasks[indexPath.row].favorite
                
                //하나의 테이블에 특정 컬럼 전체 값을 변경
                //self.tasks.setValue(true, forKey: "favorite")
                
                //하나의 레코드에서 여러 컬럼들을 변경
                //self.localRealm.create(UserDiary.self, value: ["objectId": self.tasks[indexPath.row].objectId, "diaryContent": "변경 테스트", "diaryTitle": "제목임"], update: .modified)
                
                print("Realm Update")
            }
            
            //열린 상태에서 변경하는 형태는 UX적으로 좋지 않음
            //1. 스와이프한 셀 하나만 ReloadRows 코드를 구현 => 상대적 효율성
            tableView.reloadRows(at: [indexPath], with: .none)
            //2. 데이터가 변경되었으니 다시 Realm에서 데이터를 가져오기 => didSet 일관적 형태로 갱신
            //            self.fetchRealm()
            
        }
        
        //realm 데이터 기준
        let image = tasks[indexPath.row].favorite ? "star.fill" : "star"
        favorite.image = UIImage(systemName: image)
        favorite.backgroundColor = .systemPink
        
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskDelete = tasks[indexPath.row]
        
        if editingStyle == .delete {
            //도큐먼트 이미지 파일 삭제
            removeImageFromDocument(fileName: "\(tasks[indexPath.row].objectId).jpg")
            try! self.localRealm.write {
                self.localRealm.delete(taskDelete)
            }
            tableView.reloadData()
        }
    }
    
}
