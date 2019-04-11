//
//  DiscoverViewController.swift
//  YouCat
//
//  Created by ting on 2019/4/10.
//  Copyright © 2019年 Curios. All rights reserved.
//

import UIKit
import MJRefresh

class YCFavoriteViewController: UIViewController, YCImageProtocol, YCContentStringProtocol, YCAlertProtocol {
    
    static var _instaceArray: [YCFavoriteViewController] = [];
    
    static func getInstance() -> YCFavoriteViewController{
        var _instance: YCFavoriteViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            _instance.initViewController()
            return _instance
        }else {
            _instance = YCFavoriteViewController();
            _instance.initViewController()
        }
        return _instance
    }
    
    static func addInstance(instace: YCFavoriteViewController) {
        _instaceArray.append(instace)
    }
    
    var userIcon: UIImageView!
    
    var publishes: [YCPublishModel] = []
    var publishSizes: [String : CGSize] = [:]
    
    var collectionView: UICollectionView!
    var collectionLayout: YCCollectionViewWaterfallLayout!
    
    var topView: UIView!
    
    var isFirstLoad: Bool = true
    
    // 顶部刷新
    let headerFresh = MJRefreshNormalHeader()
    // 底部刷新
    let footerFresh = MJRefreshAutoNormalFooter()
    
    let refreshCount = 20
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(animated)
        self.setUserIcon()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.beginLoadFresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginUserChange(_:)), name: NSNotification.Name("LoginUserChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshHome(_:)), name: NSNotification.Name("reFreshHome"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView() {
        self.view.backgroundColor = YCStyleColor.white
        
        self.initTopView()
        self.initCollectionView()
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func initTopView(){
        let bounds = YCScreen.bounds
        self.topView = UIView(frame: CGRect(x:0, y:0, width: bounds.width, height: 60))
        self.topView.backgroundColor = YCStyleColor.white
        
        let iconView = UIView()
        self.topView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.equalTo(8)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.userIcon = UIImageView();
        iconView.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.right.equalTo(4)
            make.top.equalTo(4)
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
        self.cropImageCircle(self.userIcon, 18)
        self.userIcon.image = UIImage(named: "default_icon")
        
        let titleLabel = UILabel()
        self.topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(self.userIcon).offset(0)
        }
        titleLabel.numberOfLines = 1
        titleLabel.text = YCLanguageHelper.getString(key: "HomeLabel")
        titleLabel.textColor = YCStyleColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        self.userIcon.isUserInteractionEnabled = true
        self.userIcon.addGestureRecognizer(iconTap)
    }
    
    func initCollectionView(){
        let bounds = YCScreen.bounds
        let rect:CGRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.collectionLayout = YCCollectionViewWaterfallLayout()
        self.collectionLayout.minimumLineSpacing = 16
        self.collectionLayout.minimumInteritemSpacing = 14
        self.collectionLayout.columnCount = 2
        let bottom = YCScreen.safeArea.bottom == 0 ? 10 : YCScreen.safeArea.bottom
        self.collectionLayout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: bottom, right: 15)
        self.collectionLayout.headerReferenceSize = CGSize(width: bounds.width, height: 60)
        self.collectionView = UICollectionView(frame: rect, collectionViewLayout: self.collectionLayout)
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.bottom.equalTo(0-(44+YCScreen.safeArea.bottom))
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(YCPublishCollectionViewCell.self, forCellWithReuseIdentifier: "YCDiscoverCell")
        self.collectionView.register(YCCollectionHeaderView.self, forSupplementaryViewOfKind: YCCollectionViewWaterfallSectionHeader, withReuseIdentifier: "YCDiscoverHeader")
        self.collectionView.backgroundColor = YCStyleColor.white
        
        
        self.headerFresh.setRefreshingTarget(self, refreshingAction: #selector(self.refreshPage))
        self.headerFresh.stateLabel.isHidden = true
        self.headerFresh.lastUpdatedTimeLabel.isHidden = true
        self.collectionView.mj_header = self.headerFresh
        
        self.footerFresh.setRefreshingTarget(self, refreshingAction: #selector(self.footerRefresh))
        self.collectionView.mj_footer = self.footerFresh
        self.footerFresh.isHidden = true
    }
    
    func beginLoadFresh(){
        if self.isFirstLoad {
            if self.publishes.count == 0 {
                let publishList = YCDateManager.loadPublishListDate(account: LocalManager.home)
                for publish in publishList {
                    self.publishes.append(publish)
                }
                if self.publishes.count > 0 {
                    self.collectionView.reloadData()
                    self.footerFresh.isHidden = false
                }
            }
            self.headerFresh.beginRefreshing()
        }
        self.isFirstLoad = false
    }
    
    @objc func refreshPage() {
        YCPublishDomain().topPublishList(start: 0, count: refreshCount) { (modelList) in
            if let list = modelList, list.result{
                if let modelList = list.modelArray {
                    self.publishes.removeAll()
                    if self.updatePublishDate(modelList: modelList) {
                        self.collectionView.reloadData()
                        self.footerFresh.isHidden = false
                        let _ = YCDateManager.saveModelListDate(modelList: self.publishes, account: LocalManager.home)
                    }
                }
                self.headerFresh.endRefreshing()
            }else {
                self.headerFresh.endRefreshing()
            }
        }
    }
    
    @objc func footerRefresh() {
        YCPublishDomain().topPublishList(start: self.publishes.count, count: refreshCount) { (modelList) in
            if let list = modelList, list.result{
                if let modelList = list.modelArray {
                    if self.updatePublishDate(modelList: modelList) {
                        self.collectionView.reloadData()
                    }
                }
                self.footerFresh.endRefreshing()
            }else {
                self.footerFresh.endRefreshing()
            }
        }
    }
    
    func updatePublishDate(modelList: Array<YCBaseModel>) -> Bool{
        var isChange = false
        for model in modelList {
            if let publish = model as? YCPublishModel {
                var isHave = false
                var index = 0
                for (i, oldPublish) in self.publishes.enumerated() {
                    if oldPublish.publishID == publish.publishID {
                        isHave = true
                        index = i
                        break
                    }
                }
                if !isHave {
                    self.publishes.append(publish)
                    isChange = true
                }else {
                    self.publishes.remove(at: index)
                    self.publishes.insert(publish, at: index)
                }
            }
        }
        return isChange
    }
    
    func initViewController() {
    }
    
    func resetViewController() {
    }
}

extension YCFavoriteViewController: YCLoginProtocol {
    
    @objc func loginUserChange(_ notify: Notification) {
        self.isFirstLoad = true
        self.setUserIcon()
    }
    
    @objc func refreshHome(_ notify: Notification) {
        if self.collectionView.contentOffset.y > 0 {
            let offset = CGPoint(x: 0, y: 0)
            self.collectionView.setContentOffset(offset, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
                self.headerFresh.beginRefreshing()
            }
        }else {
            self.headerFresh.beginRefreshing()
        }
    }
    
    func setUserIcon(){
        self.setLoginUserIcon(userIcon: self.userIcon)
    }
    
    @objc func iconTapHandler(sender:UITapGestureRecognizer) {
        self.showLoginView(view: self, noNeedShowBlock: {
            if let user = YCUserManager.loginUser {
                NotificationCenter.default.post(name: NSNotification.Name("RootPushUserView"), object: user)
            }
        }, completeBlock: nil)
    }
}


extension YCFavoriteViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.publishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: YCCollectionViewWaterfallSectionHeader, withReuseIdentifier: "YCDiscoverHeader", for: indexPath)
        headerView.addSubview(self.topView)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: YCPublishCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "YCDiscoverCell", for: indexPath) as! YCPublishCollectionViewCell
        cell.delegate = self
        let row = indexPath.item
        let publishModel = self.publishes[row]
        cell.type = .THEME
        cell.publishModel = publishModel
        return cell
    }
}

extension YCFavoriteViewController: YCCollectionViewWaterfallLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        let row = indexPath.item
        let publishModel = self.publishes[row]
        let size = self.getPublishSize(publish: publishModel, publishSize: self.publishSizes, frame: YCScreen.bounds.size, sectionInset: UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15), minimumInteritemSpacing: 14, columnCount: 2)
        
        self.publishSizes[publishModel.publishID] = size
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.item
        let publish = self.publishes[row]
        let publishDetail = YCPublishDetailViewController.getInstance()
        publishDetail.contentType = .HOME
        publishDetail.contentModel = publish
        publishDetail.contentIndex = 0
        publishDetail.contents = [publish]
        publishDetail.contentID = publish.publishID
        
        let navigationController = UINavigationController(rootViewController: publishDetail)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true) {
            
        }
    }
}

extension YCFavoriteViewController: YCPublishCollectionViewCellDelegate {
    
    func cellUserIconTap(_ cell:YCPublishCollectionViewCell?){
        
    }
    
}

