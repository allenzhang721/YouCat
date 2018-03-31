//
//  CategoryViewController.swift
//  YouCat
//
//  Created by Emiaostein on 2018/3/31.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit
import Kingfisher

struct CategoryModel:Codable {
    let title: String
    let intro: String
    let coverUrl: String
}

class CategoryViewController: UIViewController {
    
    var categories: [CategoryModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "catories", ofType: "json")!))
        let decode = JSONDecoder()
        categories = try! decode.decode([CategoryModel].self, from: data)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        let category = categories[indexPath.item]
        
        let titleLabel = cell.viewWithTag(200) as! UILabel
        titleLabel.text = category.title
        
        let introLabel = cell.viewWithTag(100) as! UILabel
        introLabel.text = category.intro
        
        let cover = cell.viewWithTag(1) as! UIImageView
        cover.kf.setImage(with: ImageResource(downloadURL: URL(string: category.coverUrl)!))
        
        let shadow = cell.viewWithTag(2)!
        shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadow.layer.shadowRadius = 10
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOpacity = 0.2
        
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = categories[indexPath.item]
        let feed = Feed.viewController()
        feed.title = category.title
        navigationController?.pushViewController(feed, animated: true)
        
    }
    
}
