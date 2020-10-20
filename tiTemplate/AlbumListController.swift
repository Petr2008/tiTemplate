//
//  AlbumListController.swift
//  Interior
//
//  Created by Petr Gusakov on 09/08/2019.
//  Copyright © 2019 Petr Gusakov. All rights reserved.
//

import UIKit
import Photos

class AlbumListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    //@IBOutlet var typeClose: UIButton!
    var nameList : Array<String> = Array()
    var photoListController : PhotoListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 15
        self.view.layer.masksToBounds = true
        self.view.layer.borderColor = UIColor.clear.cgColor
        
        // get the albums list
        let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        for index in 0..<albumList.count {
            let album = albumList.object(at: index)
            nameList.append(album.localizedTitle!)
            // print(album.localizedTitle as Any)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        photoListController = parent as? PhotoListController
    }
    // MARK: - IBAction
    @IBAction func cancelAction(_ sender: UIButton) {
        photoListController.showAlbums()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        photoListController.albumName = nameList[indexPath.row]
//        UserDefaults.standard.set(photoListController.albumName, forKey: "albumName")
        photoListController.loadImages()
        photoListController.showAlbums()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = nameList[indexPath.row]
        cell.detailTextLabel?.text = ""
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
