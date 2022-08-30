//
//  HomeViewController.swift
//  Diary
//
//  Created by 이현호 on 2022/08/23.
//

import UIKit

import SnapKit
import RealmSwift //Realm 1. import
import Zip
import FSCalendar

class HomeViewController: BaseViewController {
    
    //    let localRealm = try! Realm() // Realm 2.
    //repository 생성으로 다른 코드로 대체
    let repository = DiaryRepository()
    
    lazy var calendar: FSCalendar = {
        let view = FSCalendar()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        return view
    }()
    
    //나중에 초기화를 해도 괜찮음
    //필요한 시점에 지연으로 프로퍼티를 만드는 것
    let tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        //self는 초기화가 된 후에 사용이 가능함
        
        return view
    }() //let으로 선언한다면 즉시 실행 클로저
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter
    }()
    
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
        
        //아래의 코드를 이용하면 2초 후에 code를 실행가능
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //            code
        //        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        
        fetchRealm()
        tableView.reloadData()
    }
    
    func fetchRealm() {
        //Realm 3. Realm 데이터를 정렬해 tasks 에 담기
        tasks = repository.fetch()
    }
    
    override func configure() {
        view.addSubview(tableView)
        view.addSubview(calendar)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonClicked))
        
        let sortButton = UIBarButtonItem(title: "정렬", style: .plain, target: self, action: #selector(sortButtonClicked))
        let filterButton = UIBarButtonItem(title: "필터", style: .plain, target: self, action: #selector(filterButtonClicked))
        
        //백업 버튼
        let backUpButton = UIBarButtonItem(title: "백업", image: nil, primaryAction: UIAction(handler: { _ in
            
            var urlPaths = [URL]()
            
            //1. 도큐먼트 위치에 백업 파일 확인
            
            //도큐먼트 위치 가져오기
            guard let path = self.documentDirectoryPath() else {
                self.showToastMessage(message: "도큐먼트 위치에 오류가 있습니다")
                return
            }
            //도큐먼트 내부의 백업할 Realm 파일에 대한 세부 경로를 추가해줌
            let realmFile = path.appendingPathComponent("default.realm")
            
            //파일이 없으면 토스트 띄우고 아니면 배열에 URL 추가해줌
            guard FileManager.default.fileExists(atPath: realmFile.path) else {
                self.showToastMessage(message: "백업할 파일이 없습니다")
                return
            }
            
            urlPaths.append(URL(string: realmFile.path)!)
            
            //백업 파일을 압축: URL
            do {
                let zipFilePath = try Zip.quickZipFiles(urlPaths , fileName: "Diary_1")
                print("Archive Location: \(zipFilePath)")
                //성공 했을 경우에만 ActivityViewController를 불러오기 위해 do구문 안에 배치함
                self.showActivityViewController()
            } catch {
                self.showToastMessage(message: "압축을 실패했습니다")
            }
            
            //            let vc = BackUpViewController()
            //            self.transition(vc, transitionStyle: .present)
            
        }), menu: nil)
        
        
        //복구 버튼
        let restoreButton = UIBarButtonItem(title: "복구", image: nil, primaryAction: UIAction(handler: { _ in
            
            let vc = BackUpViewController()

            do {

                guard let path = self.documentDirectoryPath() else {
                    self.showToastMessage(message: "파일 위치에 오류가 있습니다")
                    return
                }

                //includingPropertiesForKeys: 더 추가적인 정보를 가져오는 것 [.으로 가져올 수 있음]
                let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
                print("docs: \(docs)")

                //확장자가 zip인 애를 가져오기
                let zip = docs.filter { $0.pathExtension == "zip" }
                print("zip: \(zip)")

                let result = zip.map { $0.lastPathComponent }
                print("result: \(result)")

                vc.zipFiles = result

                vc.urls = zip

            } catch {
                print("Error")
            }


            self.present(vc, animated: true)
            
            //            //asCopy를 이용해서 백업 파일을 복사해서 가져올 것인지를 정함
//                        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
//                        documentPicker.delegate = self
//                        documentPicker.allowsMultipleSelection = false
//            documentPicker.modalPresentationStyle = .formSheet
//                        self.present(documentPicker, animated: true)
            
        }), menu: nil)
        
        
        navigationItem.leftBarButtonItems = [sortButton, filterButton, backUpButton, restoreButton]
    }
    
    func showActivityViewController() {
        
        //도큐먼트 위치 가져오기
        guard let path = self.documentDirectoryPath() else {
            self.showToastMessage(message: "도큐먼트 위치에 오류가 있습니다")
            return
        }
        //도큐먼트 내부의 백업할 Realm 파일에 대한 세부 경로를 추가해줌
        let backUpFileURL = path.appendingPathComponent("Diary_1.zip")
        
        
        let vc = UIActivityViewController(activityItems: [backUpFileURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    
    override func setConstraints() {
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.topMargin.equalTo(300)
        }
        
        calendar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(300)
        }
        
    }
    
    @objc func plusButtonClicked() {
        let vc = WriteViewController()
        
        transition(vc, transitionStyle: .presentFullScreen)
    }
    
    @objc func sortButtonClicked() {
        tasks = repository.fetchSort("regdate")
    }
    
    //realm filter query, NSPredicate
    @objc func filterButtonClicked() {
        
        //CONTAINS[c]를 사용하면 대소문자 구분없이 필터링 해줌
        //CONTAINS 'String값'으로 필터나 검색 기능 구현시 많이 사용함
        tasks = repository.fetchFilter()
        //realm 에서 String 값을 가져올 때 ''로 가져와야함
        //            .filter("diaryTitle = '오늘의 일기 14'")
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as? HomeTableViewCell else { return UITableViewCell() }
        
        cell.diaryImageView.image = loadImageFromDocument(fileName: "\(tasks[indexPath.row].objectId).jpg")
        
        cell.setData(data: tasks[indexPath.row])
        
        return cell
    }
    
    //참고. TableView Editing Mode
    
    //테이블뷰 셀 높이가 작을 경우, 이미지가 없을 때, 시스템 이미지가 아닌 경우
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favorite = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            
            //realm data update
            self.repository.updateFavorite(item: self.tasks[indexPath.row])
            self.fetchRealm()
            
        }
        //realm 데이터 기준
        let image = tasks[indexPath.row].favorite ? "star.fill" : "star"
        favorite.image = UIImage(systemName: image)
        favorite.backgroundColor = .systemPink
        
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "삭제") { action, view, completionHandler in
            self.repository.deleteItem(item: self.tasks[indexPath.row])
            self.fetchRealm()
        }
        
        delete.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
}

extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    //하루 당 이벤트의 점 갯수 몇개 보이게할지
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return repository.fetchDate(date: date).count
    }
    
    
    //    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
    //        return "새싹"
    //    }
    
    
    //    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
    //        return UIImage(systemName: "heart.fill")
    //    }
    
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return formatter.string(from: date) == "220907" ? "오프라인 행사" : nil
    }
    
    
    //    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
    //        <#code#>
    //    }
    
    //100 -> 25일 3 -> 3 =>
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        tasks = repository.fetchDate(date: date)
    }
}

extension HomeViewController: UIDocumentPickerDelegate  {
    
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        //documentPicker에서 선택한 파일의 URL 가져오기
        guard let selectedFileURL = urls.first else {
            showToastMessage(message: "선택하신 파일을 찾을 수 없습니다")
            return
        }
        
        print("selectFileURL:\(selectedFileURL)")
        print(urls)
        
        //도큐먼트 위치 가져오기
        guard let path = self.documentDirectoryPath() else {
            self.showToastMessage(message: "도큐먼트 위치에 오류가 있습니다")
            return
        }
        
        //도큐먼트 위치 내부에서 documentPicker에서 선택한 파일의 URL을 가져오기
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        //documentPicker에서 선택한 해당 파일이 존재하면 파일 압축 풀기
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            
            print(sandboxFileURL)
            let fileURL = path.appendingPathComponent("Diary_1.zip")
            
            do {
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile: \(unzippedFile)")
                    self.showToastMessage(message: "복구가 완료되었습니다")
                })
                
            } catch {
                showToastMessage(message: "압축 해제 실패했습니다")
            }
            
        } else {
            
            //파일이 존재하지 않을 때
            do {
                //파일 앱의 zip -> 도큐먼트 폴더에 복사
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                let fileURL = path.appendingPathComponent("Diary_1.zip") //폴더 생성, 폴더 안에 파일 저장
                
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unzippedFile: \(unzippedFile)")
                    self.showToastMessage(message: "복구가 완료되었습니다")
                })
                
            } catch {
                showToastMessage(message: "압축 해제에 실패했습니다.")
            }
            
        }
        
        
    }
    
}


