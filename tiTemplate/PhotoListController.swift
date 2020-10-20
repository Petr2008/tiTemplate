//
//  PhotoListController.swift
//  Interior
//
//  Created by Petr Gusakov on 27/07/2019.
//  Copyright © 2019 Petr Gusakov. All rights reserved.
//

import UIKit
import Photos

protocol PhotoListDelegate: class {
    func didSelectPhotoName(localIdentifier: String)
//    func didSelectPhotoName(localIdentifier: String)
//    func didSelectStickerName(localIdentifier: String)
    func didMultiSelectPhotoName(identifierList: [String])
}


class PhotoListController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver {
    //}, SelectPhotoOfAlbumDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    @IBOutlet var layoutAlbumsDist: NSLayoutConstraint!
    @IBOutlet var layoutAlbumsHeight: NSLayoutConstraint!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    @IBOutlet var photoBank: UIBarButtonItem!
    @IBOutlet var selectAlbums: UIBarButtonItem!
    //@IBOutlet var addButtonItem: UIBarButtonItem!
    weak var delegate: PhotoListDelegate? = nil
    
    let documentUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)

    var fetchResult: PHFetchResult<PHAsset>!
    var albumName = ""
    var selectList : Array<Bool>!
    var selectNameList : [Int: String] = [:]
    var isScreenAlbum = false
    
    var widthScreen = CGFloat()
    var pipNameList: [String]!
    
    //let languageCode = Locale.current.languageCode
    
    var isSticker = false
    var isMultiSelect = false
    var allCountImage = 0
    
//    let maxCountImage = 10

    override func viewDidLoad() { //print("viewDidLoad PhotoListController")
        super.viewDidLoad()
//        layoutAlbumsDist.constant = self.view.bounds.size.height
//        layoutAlbumsDist.constant = self.widthScreen

        layoutAlbumsDist.constant = self.view.bounds.size.height
        layoutAlbumsHeight.constant = self.view.bounds.size.height - 64 - 44
        
        self.containerView.isHidden = true
        self.doneButton.isEnabled = false

        let width = (widthScreen - 4) / 3
        collectionLayout.itemSize = CGSize(width: width, height: width)

        
        //self.albumName = UserDefaults.standard.string(forKey: "albumName") ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("\nviewDidAppear")
        layoutAlbumsDist.constant = self.view.bounds.size.height
        layoutAlbumsHeight.constant = self.view.bounds.size.height - 64 - 44

        photoAuthorization()
    }
    
    func photoAuthorization() {//print("photoAuthorization")
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Photo Auth Ok")

            PHPhotoLibrary.shared().register(self)
            self.loadImages()
        case .restricted, .denied:
            // закрыт
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: {enabled in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        case .notDetermined:
            // не определен
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    print("Photo Auth Ok")
                    self.loadImages()
                case .restricted, .denied:
                    print("Клиент запретил сдуру - добавить функцию!!!!!!")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .notDetermined: break
                @unknown default:
                    fatalError()
                }
            }
        @unknown default:
            fatalError()
        }
    }

    // MARK: Данные
    func loadImages() {//print("loadImages")
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if albumName != "" {
            let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            for index in 0..<albumList.count {
                let album = albumList.object(at: index)
                if album.localizedTitle == albumName {
                    fetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)
                    break
                }
            }
        } else {
            fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        if fetchResult.count > 0 {
            self.selectList = Array(repeating: false, count: fetchResult.count)

            if isMultiSelect && pipNameList.count > 0 {
                for index in 0..<fetchResult.count {
                    let name = self.fetchResult[index].value(forKey: "localIdentifier") as! String
                    if pipNameList.contains(where: {$0 == name}) {
                        selectList[index] = true
                        self.selectNameList.updateValue(name, forKey: index)
                    }
                }
                self.navigationItem.title = String(format: "Выделено %i", self.selectNameList.count)
            }
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: PHPhotoLibraryChangeObserver
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        //print("photoLibraryDidChange")
        loadImages()
    }

    // MARK: IBAction
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        if !self.isMultiSelect {
            self.navigationController?.popViewController(animated: true)
            return
        }
        // массив ключей
        let keys = self.selectNameList.keys.sorted()
        // массив элементов
        var localIdentifierList : Array<String> = Array()
        for index in 0..<keys.count {
            let localIdentifier = self.selectNameList[keys[index]]
            localIdentifierList.append(localIdentifier!)
        }
        
        self.delegate?.didMultiSelectPhotoName(identifierList: localIdentifierList)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func showAlbumsAction(_ sender: UIBarButtonItem) {
        showAlbums()
    }
    
//    @IBAction func pixabay(_ sender: UIBarButtonItem) {
//
//    }
//
    func showAlbums() {
        self.isScreenAlbum = !self.isScreenAlbum
        if self.isScreenAlbum {
            self.layoutAlbumsDist.constant = 0
            self.containerView.isHidden = false
            
        } else {
            self.layoutAlbumsDist.constant = max(self.view.bounds.height, self.view.bounds.width)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { // Change `2.0` to the desired number of seconds.
               self.containerView.isHidden = true
            }
        }
        let albumListController = children.last as! AlbumListController
        albumListController.titleLabel.text = "Все альбомы"
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    // MARK: - PixabayControllerDelegate
    func didSelectPhotoFromBank() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - UICollection delegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (fetchResult != nil) {
            //print(fetchResult.count)
            return fetchResult.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("select: \(indexPath.row)")
        
        if !isMultiSelect {
            let name = self.fetchResult[indexPath.row].value(forKey: "localIdentifier") as! String
            self.delegate?.didSelectPhotoName(localIdentifier: name)
            
//            if isSticker {
//                self.delegate?.didSelectStickerName(localIdentifier: name)
//            } else {
//                self.delegate?.didSelectPhotoName(localIdentifier: name)
//            }
            self.navigationController?.popViewController(animated: true)
        } else {
            if self.selectNameList.count >= 100 && !self.selectList[indexPath.row] {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                return
            }
            // удаляем элемент
            if self.selectList[indexPath.row] {
                self.selectNameList.removeValue(forKey: indexPath.row)
            } else {  // добавляем элемент
                let name = self.fetchResult[indexPath.row].value(forKey: "localIdentifier") as! String
                self.selectNameList.updateValue(name, forKey: indexPath.row)
            }
            self.navigationItem.title = String(format: "Выделено %i", self.selectNameList.count)
            self.selectList[indexPath.row] = !self.selectList[indexPath.row]
            collectionView.reloadItems(at: [indexPath])
//            self.delegate?.didSelectPhotoName(localIdentifier: name)
        }
        if self.selectNameList.count == 0 {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let requestOptions = PHImageRequestOptions()
        PHImageManager.default().requestImage(for: fetchResult.object(at: indexPath.row), targetSize: collectionLayout.itemSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions) {
            (image, _) in
                
            cell.imageView.image = image
        }
        
//        cell.selectedView.isHidden = !self.selectList[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */
}
