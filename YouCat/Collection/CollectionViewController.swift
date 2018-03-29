//
//  CollectionViewController.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CollectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        
        
        let label = cell.viewWithTag(100) as! UILabel
        let shadow = cell.viewWithTag(300)!
        
        
        label.text = "Basic background Cosmetic surgery consists not just of enhancing someones beauty, but also to help those who have been badly damaged in an accident or who have physical birth defects. Many believe that women are the main gender that go for cosmetic surgery. "
        
        cell.layoutIfNeeded()
        
//        shadow.layer.shadowPath = UIBezierPath(roundedRect: shadow.bounds, cornerRadius: 8).cgPath
        shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadow.layer.shadowRadius = 10
        shadow.layer.shadowColor = UIColor.black.cgColor
        shadow.layer.shadowOpacity = 0.1
        
        return cell
    }
    
    
    
    
    
}



