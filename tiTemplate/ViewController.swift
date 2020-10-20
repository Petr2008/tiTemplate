//
//  ViewController.swift
//  tiTemplate
//
//  Created by Petr Gusakov on 19.10.2020.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var projectCollectionView: UICollectionView!
    @IBOutlet var templateCollectionView: UICollectionView!
    @IBOutlet var statusCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //    MARK: - CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        
        switch collectionView {
        case projectCollectionView:
            let cell = projectCollectionView.dequeueReusableCell(withReuseIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
            cell.imageView.image = UIImage(named: "icons8-wrench.png")
            cell.nameLabel.text = String(format: "project%i", indexPath.row)
            return cell
        case templateCollectionView:
            let cell = templateCollectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCell", for: indexPath) as! TemplateCell
            cell.imageView.image = UIImage(named: "icons8-collage.png")
            return cell
        case statusCollectionView:
            let cell = statusCollectionView.dequeueReusableCell(withReuseIdentifier: "StatusCell", for: indexPath) as! StatusCell
            cell.statusLabel.text = String(format: "Status - %i", indexPath.row)
            return cell
        default:
            break
        }
        
        return cell
    }
}

