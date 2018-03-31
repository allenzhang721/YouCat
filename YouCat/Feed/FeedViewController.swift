//
//  CollectionViewController.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit
import Kingfisher

struct FeedModel: Codable {
    let userName: String
    let subTitle: String
    let avatarUrl: String
    let contentUrl: String
    let intro: String
}

class FeedViewController: UIViewController {
    
    var feeds: [FeedModel] = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "feeds", ofType: "json")!))
        let decode = JSONDecoder()
        feeds = try! decode.decode([FeedModel].self, from: data)
    }
}



extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let feed = feeds[indexPath.item];
        
        let nameLabel = cell.viewWithTag(1) as! UILabel
        let subtitleLabel = cell.viewWithTag(2) as! UILabel
        let imgView = cell.viewWithTag(3) as! UIImageView
        let label = cell.viewWithTag(100) as! UILabel
        let shadow = cell.viewWithTag(300)!
        
        nameLabel.text = feed.userName
        label.text = feed.intro
        imgView.kf.setImage(with: ImageResource(downloadURL: URL(string: feed.contentUrl)!))
        
        cell.layoutIfNeeded()
        
        shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadow.layer.shadowRadius = 10
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOpacity = 0.1
        
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = feeds[indexPath.item]
        let detail = Detail.viewController(contentUrl: URL(string: feed.contentUrl)!)
        navigationController?.pushViewController(detail, animated: true)
        
    }
}



