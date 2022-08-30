//
//  BackUpViewController.swift
//  Diary
//
//  Created by 이현호 on 2022/08/24.
//

import Foundation
import UIKit

import RealmSwift
import Zip

class BackUpViewController: BaseViewController {
    
    let tableView: UITableView = {
        let view = UITableView()
        view.rowHeight = 100
        return view
    }()
    
    var urls: [URL] = []
    
    var zipFiles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BackUpTableViewCell.self, forCellReuseIdentifier: BackUpTableViewCell.reuseIdentifier)
        
    }
    
    override func configure() {
        view.addSubview(tableView)
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BackUpViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        zipFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BackUpTableViewCell.reuseIdentifier) as? BackUpTableViewCell else { return UITableViewCell() }
        
        zipFiles.forEach {
            cell.titleLabel.text = $0
        }        
        
        return cell        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        let selectFileURL = urls[indexPath.row]
        
        
        
        //선택한 파일의 URL 가져오기
        guard let selectedFileURL = urls.first else {
            showToastMessage(message: "선택하신 파일을 찾을 수 없습니다")
            return
        }
        

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
                    
//                    let realm = try! Realm()
//                    try! realm.write {
//                      realm.deleteAll()
//                    }
//
//                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//                    let sceneDelegate = windowScene?.delegate as? SceneDelegate
//
//                    let vc = HomeViewController()
//                    let nav = UINavigationController(rootViewController: vc)
//
//                    sceneDelegate?.window?.rootViewController = nav
//                    sceneDelegate?.window?.makeKeyAndVisible()
                    
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






