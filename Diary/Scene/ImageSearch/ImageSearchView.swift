//
//  ImageSearchView.swift
//  Diary
//
//  Created by 이현호 on 2022/08/22.
//

import UIKit

import SnapKit
import Kingfisher


class ImageSearchView: BaseView {
    
    var selectImage: UIImage? //1. 공간 만들어줌
    
    var selectIndexPath: IndexPath?
    
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionViewLayout())
        return view
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    override func configureUI() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageSearchCollectionViewCell.self, forCellWithReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier)
        
        searchBar.delegate = self
        
        [searchBar, collectionView].forEach {
            self.addSubview($0)
        }
        
    }
    
    override func setConstraints() {
        
        searchBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    static func imageCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let deviceWidth: CGFloat = UIScreen.main.bounds.width
        let itemWidth: CGFloat = deviceWidth / 2
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.scrollDirection = .vertical
        return layout
    }
    
    
}

extension ImageSearchView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageData.images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageSearchCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageSearchCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        
        cell.layer.borderWidth = selectIndexPath == indexPath ? 4 : 0
        cell.layer.borderColor = selectIndexPath == indexPath ? UIColor.red.cgColor : nil
        cell.searchImageView.kf.setImage(with: URL(string: ImageData.images[indexPath.item]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        ImageData.selectImage = ImageData.images[indexPath.item]
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageSearchCollectionViewCell else { return }
        selectImage = cell.searchImageView.image
        
        selectIndexPath = indexPath
        collectionView.reloadData()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(#function)
        selectIndexPath = nil
        selectImage = nil
        collectionView.reloadData()
        
    }
    
}

extension ImageSearchView: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        ImageData.images.removeAll()
        guard let text = searchBar.text else { return }
        ImageAPIManager.shared.callRequest(query: text) { value in
            ImageData.images.append(contentsOf: value)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        self.endEditing(true)
    }
}

