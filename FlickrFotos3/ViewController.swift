//
//  ViewController.swift
//  FlickrFotos3
//
//  Created by Supervisor on 30/06/2021.
//  Copyright © 2021 Supervisor. All rights reserved.
//

import UIKit

struct APIResposta: Codable{
    let photos: Resultado
}

struct Resultado: Codable{
    let photo: [Resultado2]
}

struct Resultado2: Codable{
    let id: String
}

//--------------------------//

struct APIRespostaPhoto: Codable{
    let sizes: ResultadoPhoto
}

struct ResultadoPhoto: Codable{
    let size: [ResultadoPhoto2]
}

struct ResultadoPhoto2: Codable{
    let label: String
    let source: String
}

var api_key = "7bdb03d29144dbbabc9c71fd173ac356"

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(api_key)&tags=bird&page=1&format=json&nojsoncallback=1"
    
    private var collectionView: UICollectionView?
    
    var results: [ResultadoPhoto2] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width / 2, height: view.frame.size.width / 2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.collectionView = collectionView
        buscaPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    func buscaPhotos(){
        
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let jsonData = data, error == nil else {
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(APIResposta.self, from: jsonData)
                DispatchQueue.main.async {
                let total = jsonResult.photos.photo.count - 1
                    for id in 1...total{
                        let foto = jsonResult.photos.photo[id].id
                        self?.mostraPhotos(photo_id: foto)
                    }
                }
            }catch{
                print(error)
            }
        }
        task.resume()
    }
    
    func mostraPhotos(photo_id: String){
        
        let urlPhoto = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=7bdb03d29144dbbabc9c71fd173ac356&photo_id=\(photo_id)&format=json&nojsoncallback=1"
        
        guard let url = URL(string: urlPhoto) else {
            return
        }
        let taskPhoto = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let dataPhoto = data, error == nil else {
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(APIRespostaPhoto.self, from: dataPhoto)
                DispatchQueue.main.async {
                let total = jsonResult.sizes.size.count - 1
                    for id in 1...total{
                        if(jsonResult.sizes.size[id].label == "Original"){
                            print(jsonResult.sizes.size[id])
                            print(jsonResult.sizes.size.count)
                            self?.results.append(jsonResult.sizes.size[id])
                            self?.collectionView?.reloadData()
                        }
                        self?.collectionView?.reloadData()
                    }
                    //self?.results = jsonResult.sizes.size
                    self?.collectionView?.reloadData()
                }
            }catch{
                print(error)
            }
        }
        taskPhoto.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = results[indexPath.row].source
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: photo)
        return cell
    }
}

