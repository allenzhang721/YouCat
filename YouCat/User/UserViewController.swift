//
//  UserViewController.swift
//  YouCat
//
//  Created by ting on 2018/10/24.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import MJRefresh
import Kingfisher


enum YCUserPublishType: String{
    case POST = "post"
    case LIKE = "like"
}

enum YCLoginUserType: String{
    case Default = "default"
    case LoginUser = "login"
}

class YCUserViewController: UIViewController, YCImageProtocol, YCNumberStringProtocol, YCAlertProtocol {
    
    static var _instaceArray: [YCUserViewController] = [];
    
    static func getInstance() -> YCUserViewController{
        var _instance: YCUserViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            _instance.initViewController()
            return _instance
        }else {
            _instance = YCUserViewController();
            _instance.initViewController()
        }
        return _instance
    }
    
    static func addInstance(instace: YCUserViewController) {
        _instaceArray.append(instace)
    }
    
    var userPublishType: YCUserPublishType = .POST
    var loginUserType: YCLoginUserType = .Default
    let refreshCount = 40
    var isFirstShow: Bool = true
    var isSetting: Bool = false

    var userModel: YCUserModel?
    var userDetailModel: YCUserDetailModel?
    
    var publishes: [YCPublishModel] = []
    var publishSizes: [String : CGSize] = [:]
    
    var operateButton: UIButton!
    var collectionView: UICollectionView!
    var collectionLayout: YCCollectionViewWaterfallLayout!
    
    var topView:UIView!
    var userIcon: UIImageView!
    var userNameLabel: UILabel!
    var userSignLabel: UILabel!
    
    
    var followButton: YCFollowButton!
    var postView: UIView!
    var postCountLabel: UILabel!
    var followingView: UIView!
    var followingCountLabel: UILabel!
    var followersView: UIView!
    var followersCountLabel: UILabel!
    
    var postButton: YCSelectedButton!
    var likeButton: YCSelectedButton!
    
    var loadingView: YCLoadingView!
    
    let footerFresh = MJRefreshAutoNormalFooter()
    
    var delegate: YCUserViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        super.viewWillAppear(animated)
        if self.isFirstShow || self.isSetting {
            self.setValue(userModel: self.userModel)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isFirstShow {
            self.userDetail()
            self.refreshPage()
        }
        self.isFirstShow = false
        self.isSetting = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        
        self.view.backgroundColor = YCStyleColor.blue
        
        self.initTopView()
        self.initCollectionView()
        self.initOperateButton()
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.loadingView = YCLoadingView(style: .INSIDE)
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view).offset(0)
            make.top.equalTo(0)
        }
    }
    
    func initOperateButton() {
        let backButton=UIButton()
        backButton.setImage(UIImage(named: "back_black"), for: .normal)
        backButton.setImage(UIImage(named: "back_black"), for: .highlighted)
        backButton.addTarget(self, action: #selector(self.backButtonClick), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.left.equalTo(10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.operateButton=UIButton()
        self.operateButton.setImage(UIImage(named: "operate_black"), for: .normal)
        self.operateButton.setImage(UIImage(named: "operate_black"), for: .highlighted)
        self.operateButton.addTarget(self, action: #selector(self.operateButtonClick), for: .touchUpInside)
        self.view.addSubview(self.operateButton)
        self.operateButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.right.equalTo(-10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
    }
    
    func initTopView(){
        let iconW:CGFloat = 88
        
        let bounds = YCScreen.bounds
        self.topView = UIView(frame: CGRect(x:0, y:0, width: bounds.width, height: bounds.width))
        self.topView.backgroundColor = YCStyleColor.white
        
        self.userIcon = UIImageView()
        self.topView.addSubview(self.userIcon)
        self.userIcon.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(YCScreen.safeArea.top + 44)
            make.width.equalTo(iconW)
            make.height.equalTo(iconW)
        }
        self.cropImageCircle(self.userIcon, iconW/2)
        self.userIcon.image = UIImage(named: "default_icon")
//        self.userIcon.isUserInteractionEnabled = true
//        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
//        self.userIcon.addGestureRecognizer(iconTap)
        
        let followBtW:CGFloat = bounds.width - 60 - iconW
        let followBtX:CGFloat = iconW+40
        self.followButton = YCFollowButton()
        self.topView.addSubview(self.followButton)
        self.followButton.snp.makeConstraints { (make) in
            make.left.equalTo(followBtX)
            make.bottom.equalTo(self.userIcon.snp.bottom).offset(0)
            make.width.equalTo(followBtW)
            make.height.equalTo(32)
        }
        let followTap = UITapGestureRecognizer(target: self, action: #selector(self.followButtonTap))
        self.followButton.addGestureRecognizer(followTap)
        
        self.userNameLabel = UILabel()
        self.topView.addSubview(self.userNameLabel)
        self.userNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(self.followButton.snp.bottom).offset(5)
            make.width.equalTo(bounds.width - 40)
            make.height.equalTo(36)
        }
        self.userNameLabel.textColor = YCStyleColor.black
        self.userNameLabel.font = UIFont.systemFont(ofSize: 24)
        
        self.userSignLabel = UILabel(frame: CGRect(x:20, y:(YCScreen.safeArea.top + 90 + iconW), width: bounds.width - 40, height: 22))
        self.topView.addSubview(self.userSignLabel)
        self.userSignLabel.textColor = YCStyleColor.gray
        self.userSignLabel.font = UIFont.systemFont(ofSize: 16)
        self.userSignLabel.numberOfLines = 0
        
        let operateW = (followBtW - 30)/3
        
        self.postView = UIView()
        self.topView.addSubview(self.postView)
        self.postView.snp.makeConstraints { (make) in
            make.left.equalTo(followBtX+5)
            make.top.equalTo(self.userIcon.snp.top).offset(0)
            make.width.equalTo(operateW)
            make.height.equalTo(50)
        }
        self.postCountLabel = UILabel(frame: CGRect(x:0, y:5, width: operateW, height: 22))
        self.postView.addSubview(self.postCountLabel)
        self.postCountLabel.textColor = YCStyleColor.black
        self.postCountLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.postCountLabel.textAlignment = .center
        let postLabel = UILabel(frame: CGRect(x:0, y:25, width: operateW, height: 22))
        self.postView.addSubview(postLabel)
        postLabel.textColor = YCStyleColor.gray
        postLabel.font = UIFont.systemFont(ofSize: 10)
        postLabel.textAlignment = .center
        postLabel.text = YCLanguageHelper.getString(key: "PublishLabel")
        
        self.followersView = UIView()
        self.topView.addSubview(self.followersView)
        self.followersView.snp.makeConstraints { (make) in
            make.left.equalTo(followBtX+25+2*operateW)
            make.centerY.equalTo(self.postView).offset(0)
            make.width.equalTo(operateW)
            make.height.equalTo(50)
        }
        self.followersCountLabel = UILabel(frame: CGRect(x:0, y:5, width: operateW, height: 22))
        self.followersView.addSubview(self.followersCountLabel)
        self.followersCountLabel.textColor = YCStyleColor.black
        self.followersCountLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.followersCountLabel.textAlignment = .center
        let followersLabel = UILabel(frame: CGRect(x:0, y:25, width: operateW, height: 22))
        self.followersView.addSubview(followersLabel)
        followersLabel.textColor = YCStyleColor.gray
        followersLabel.font = UIFont.systemFont(ofSize: 10)
        followersLabel.textAlignment = .center
        followersLabel.text = YCLanguageHelper.getString(key: "FollowersLabel")
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(self.followersTapHandler))
        self.followersView.isUserInteractionEnabled = true
        self.followersView.addGestureRecognizer(followersTap)
        
        self.followingView = UIView()
        self.topView.addSubview(self.followingView)
        self.followingView.snp.makeConstraints { (make) in
            make.left.equalTo(followBtX+15+operateW)
            make.centerY.equalTo(self.postView).offset(0)
            make.width.equalTo(operateW)
            make.height.equalTo(50)
        }
        self.followingCountLabel = UILabel(frame: CGRect(x:0, y:5, width: operateW, height: 22))
        self.followingView.addSubview(self.followingCountLabel)
        self.followingCountLabel.textColor = YCStyleColor.black
        self.followingCountLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.followingCountLabel.textAlignment = .center
        let followingLabel = UILabel(frame: CGRect(x:0, y:25, width: operateW, height: 22))
        self.followingView.addSubview(followingLabel)
        followingLabel.textColor = YCStyleColor.gray
        followingLabel.font = UIFont.systemFont(ofSize: 10)
        followingLabel.textAlignment = .center
        followingLabel.text = YCLanguageHelper.getString(key: "FollowingLabel")
        
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(self.followingTapHandler))
        self.followingView.isUserInteractionEnabled = true
        self.followingView.addGestureRecognizer(followingTap)
        
        
        self.postButton = YCSelectedButton(fontText: YCLanguageHelper.getString(key: "PostLabel"), fontSize: 16)
        self.topView.addSubview(self.postButton)
        self.postButton.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(bounds.width/2)
            make.height.equalTo(44)
        }
        self.postButton.status = .Selected
        let postTap = UITapGestureRecognizer(target: self, action: #selector(self.postButtonTap))
        self.postButton.addGestureRecognizer(postTap)
        
        self.likeButton = YCSelectedButton(fontText: YCLanguageHelper.getString(key: "LikeLabel"), fontSize: 16)
        self.topView.addSubview(self.likeButton)
        self.likeButton.snp.makeConstraints { (make) in
            make.left.equalTo(bounds.width/2)
            make.top.equalTo(0)
            make.width.equalTo(bounds.width/2)
            make.height.equalTo(44)
        }
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(self.likeButtonTap))
        self.likeButton.addGestureRecognizer(likeTap)
    }
    
    func initCollectionView(){
        let bounds = YCScreen.bounds
        let rect:CGRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.collectionLayout = YCCollectionViewWaterfallLayout()
        self.collectionLayout.minimumLineSpacing = 10
        self.collectionLayout.minimumInteritemSpacing = 8
        self.collectionLayout.columnCount = 2
        let bottom = YCScreen.safeArea.bottom == 0 ? 10 : YCScreen.safeArea.bottom
        self.collectionLayout.sectionInset = UIEdgeInsets(top: 10, left: 9, bottom: bottom, right: 9)
        self.collectionLayout.headerReferenceSize = CGSize(width: bounds.width, height: bounds.width)
        
        self.collectionView = UICollectionView(frame: rect, collectionViewLayout: self.collectionLayout)
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(YCPublishCollectionViewCell.self, forCellWithReuseIdentifier: "YCThemeDetailCell")
        self.collectionView.register(YCCollectionHeaderView.self, forSupplementaryViewOfKind: YCCollectionViewWaterfallSectionHeader, withReuseIdentifier: "YCThemeDetailHeader")
        self.collectionView.backgroundColor = YCStyleColor.white
        
        self.footerFresh.setRefreshingTarget(self, refreshingAction: #selector(self.footerRefresh))
        self.collectionView.mj_footer = self.footerFresh
        self.footerFresh.isHidden = true
    }
    
    func setValue(userModel: YCUserModel?){
        let bounds = YCScreen.bounds
        if var user = userModel {
            if let loginUser = YCUserManager.loginUser, user.userID == loginUser.userID {
                user = loginUser
                self.followButton.status = .EditProfile
            }else if let relationUser = user as? YCRelationUserModel {
                if let status = YCFollowButtonStatus(rawValue: relationUser.relation) {
                    self.followButton.status = status
                }else {
                    self.followButton.status = .Unfollow
                }
            }else {
                self.followButton.status = .Unfollow
            }
            if let icon = user.icon {
                let imagePath = icon.imagePath
                if imagePath != "", let imgURL = URL(string: imagePath){
                    self.userIcon.kf.setImage(with: ImageResource(downloadURL: imgURL), placeholder: UIImage(named: "default_icon"), options: nil, progressBlock: { (start, total) in
                    }, completionHandler: { (image, error, type, url) in
                    })
                }else {
                    self.userIcon.image = UIImage(named: "default_icon")
                }
            }else {
                self.userIcon.image = UIImage(named: "default_icon")
            }
            self.userNameLabel.text = self.getNicknameString(user: user)
            self.userSignLabel.text = self.getSignString(sign: user.signature)
        }else {
            self.userIcon.image = UIImage(named: "default_icon")
            self.userNameLabel.text = ""
            self.userSignLabel.text = ""
            self.followButton.status = .Unfollow
        }
        self.userSignLabel.frame.origin.x = 20
        self.userSignLabel.frame.size.width = bounds.width - 40
        self.userSignLabel.sizeToFit()
        let topH = self.userSignLabel.frame.origin.y + self.userSignLabel.frame.height
        self.topView.frame.size.height = topH + 44
        self.postButton.snp.updateConstraints({ (make) in
            make.top.equalTo(topH)
        })
        self.likeButton.snp.updateConstraints { (make) in
            make.top.equalTo(topH)
        }
        
        self.collectionLayout.headerReferenceSize = CGSize(width: bounds.width, height: topH + 44)

        self.loadingView.snp.updateConstraints { (make) in
            make.top.equalTo(topH+54)
        }
        
        if self.loginUserType == .Default && self.followButton.status == .EditProfile {
            self.operateButton.isHidden = true
        }else {
            self.operateButton.isHidden = false
        }
    }
    
    func setDetail(userDetailModel: YCUserDetailModel?){
        if let user = userDetailModel {
            if let status = YCFollowButtonStatus(rawValue: user.relation) {
                self.followButton.status = status
            }else {
                self.followButton.status = .Unfollow
            }
            self.postCountLabel.text = self.getNumberString(number: user.publishCount)
            self.followingCountLabel.text = self.getNumberString(number: user.followingCount)
            self.followersCountLabel.text = self.getNumberString(number: user.followersCount)
        }
    }
    
    func resetDetail() {
        self.postCountLabel.text = self.getNumberString(number: 0)
        self.followingCountLabel.text = self.getNumberString(number: 0)
        self.followersCountLabel.text = self.getNumberString(number: 0)
    }
    
    func userDetail() {
        if let user = self.userModel {
            self.resetDetail()
            if self.followButton.status != .EditProfile {
                self.followButton.status = .Loading
            }
            YCUserDomain().userDetail(userID: user.userID, completionBlock: { (model) in
                if let mo = model, mo.result {
                    if let userDetail = mo.baseModel as? YCUserDetailModel {
                        self.setDetail(userDetailModel: userDetail)
                        self.userDetailModel = userDetail
                    }else {
                        if let userDetail = self.userDetailModel {
                            self.setDetail(userDetailModel: userDetail)
                        }else {
                            self.resetDetail()
                            self.followButton.status = .Unfollow
                        }
                    }
                }else {
                    if let userDetail = self.userDetailModel {
                        self.setDetail(userDetailModel: userDetail)
                    }else {
                        self.resetDetail()
                    }
                }
            })
        }
    }
    
    func refreshPage(){
        if let user = self.userModel {
            if self.userPublishType == .POST {
                self.loadingView.startAnimating()
                self.footerFresh.isHidden = true
                YCPublishDomain().userPublishList(userID: user.userID, start: 0, count: self.refreshCount, completionBlock: { (list) in
                    self.refreshPageEnd(list)
                })
            }else if self.userPublishType == .LIKE {
                self.loadingView.startAnimating()
                self.footerFresh.isHidden = true
                YCPublishDomain().userLikePublishList(userID: user.userID, start: 0, count: self.refreshCount, completionBlock: { (list) in
                    self.refreshPageEnd(list)
                })
            }
        }
    }
    
    func refreshPageEnd(_ listModel: YCDomainListModel?) {
        if let list = listModel, list.result{
            if let modelList = list.modelArray {
                self.publishes.removeAll()
                let _ = self.updatePublishDate(modelList: modelList)
                self.collectionView.reloadData()
                if self.publishes.count > 0{
                    self.footerFresh.resetNoMoreData()
                    self.footerFresh.isHidden = false
                }else {
                    self.footerFresh.endRefreshingWithNoMoreData()
                    self.footerFresh.isHidden = true
                }
            }
            self.loadingView.stopAnimating()
        }else {
            self.loadingView.stopAnimating()
        }
    }
    
    @objc func footerRefresh() {
        if let user = self.userModel {
            if self.userPublishType == .POST {
                YCPublishDomain().userPublishList(userID: user.userID, start: self.publishes.count, count: self.refreshCount, completionBlock: { (list) in
                    self.footerFreshEnd(list)
                })
            }else if self.userPublishType == .LIKE {
                YCPublishDomain().userLikePublishList(userID: user.userID, start: self.publishes.count, count: self.refreshCount, completionBlock: { (list) in
                    self.footerFreshEnd(list)
                })
            }
        }
    }
    
    func footerFreshEnd(_ modelList: YCDomainListModel?) {
        if let list = modelList, list.result{
            if let modelList = list.modelArray {
                if self.updatePublishDate(modelList: modelList) {
                    self.collectionView.reloadData()
                }
                if modelList.count == 0 {
                    self.footerFresh.endRefreshingWithNoMoreData()
                    self.footerFresh.isHidden = true
                }else{
                    self.footerFresh.endRefreshing()
                }
            }else {
                self.footerFresh.endRefreshing()
            }
        }else {
            self.footerFresh.endRefreshing()
        }
    }
    
    @objc func backButtonClick(){
        if let delegate = self.delegate, let relationUser = self.userModel as? YCRelationUserModel {
            delegate.backUser(user: relationUser)
        }
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.resetViewController()
            YCUserViewController.addInstance(instace: self)
        }
    }
    
    func updatePublishDate(modelList: Array<YCBaseModel>) -> Bool{
        var isChange = false
        for model in modelList {
            if let publish = model as? YCPublishModel {
                var isHave = false
                for oldPublish in self.publishes {
                    if oldPublish.publishID == publish.publishID {
                        isHave = true
                        break
                    }
                }
                if !isHave {
                    self.publishes.append(publish)
                    isChange = true
                }
            }
        }
        return isChange
    }
    
    func initViewController(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginUserChange(_:)), name: NSNotification.Name("LoginUserChange"), object: nil)
    }
    
    func resetViewController() {
        self.userDetailModel = nil
        self.publishes.removeAll()
        self.publishSizes.removeAll()
        self.collectionView.reloadData()
        self.footerFresh.isHidden = true
        self.isFirstShow = true
        self.isSetting = false
        self.resetDetail()
        self.followButton.status = .Unfollow
        self.userPublishType = .POST
        self.loginUserType = .Default
        self.postButton.status = .Selected
        self.likeButton.status = .Default
        self.delegate = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LoginUserChange"), object: nil)
    }
}

extension YCUserViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.publishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: YCCollectionViewWaterfallSectionHeader, withReuseIdentifier: "YCThemeDetailHeader", for: indexPath)
        headerView.addSubview(self.topView)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: YCPublishCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "YCThemeDetailCell", for: indexPath) as! YCPublishCollectionViewCell
        cell.delegate = self
        let row = indexPath.item
        let publishModel = self.publishes[row]
        if self.userPublishType == .POST {
            cell.type = .POST
        }else if self.userPublishType == .LIKE {
            cell.type = .LIKE
        }
        
        cell.publishModel = publishModel
        return cell
    }
}

extension YCUserViewController: YCCollectionViewWaterfallLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        let row = indexPath.item
        let publishModel = self.publishes[row]
        let size = self.getPublishSize(publish: publishModel, publishSize: self.publishSizes, frame: YCScreen.bounds.size, sectionInset: UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15), minimumInteritemSpacing: 14, columnCount: 2)
        self.publishSizes[publishModel.publishID] = size
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row = indexPath.item
        let publishModel = self.publishes[row]
        
        let publishDetail = YCPublishDetailViewController.getInstance()
        publishDetail.contentModel = publishModel
        publishDetail.contentIndex = 0
        publishDetail.contents = self.publishes
        if self.userPublishType == .LIKE {
            publishDetail.contentType = .LIKE
        }else if self.userPublishType == .POST {
            publishDetail.contentType = .POST
        }
        if let user = self.userModel {
            publishDetail.contentID = user.userID
        }
    
        let navigationController = UINavigationController(rootViewController: publishDetail)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true) {
            
        }
    }
}

extension YCUserViewController: YCPublishCollectionViewCellDelegate, YCLoginProtocol, UIGestureRecognizerDelegate, YCShareProtocol{
    
    @objc func loginUserChange(_ notify: Notification) {
        self.isFirstShow = true
    }
    
    func cellUserIconTap(_ cell:YCPublishCollectionViewCell?){
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    @objc func operateButtonClick(){
        if self.followButton.status == .EditProfile {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "LogoutLabel"), "textColor":YCStyleColor.red])
            self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                if index == 0 {
                    self.logoutHandler()
                }
            }
        }else if self.followButton.status != .Loading{
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "ShareLabel")])
            if self.followButton.status == .Unblock {
                alertArray.append(["title":YCLanguageHelper.getString(key: "UnBlockLabel")])
            }else {
                alertArray.append(["title":YCLanguageHelper.getString(key: "BlockLabel")])
            }
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportLabel"), "textColor":YCStyleColor.red])
            self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                if index == 0 {
                    self.shareHandler()
                }else if index == 1 {
                    if self.followButton.status == .Unblock {
                        self.unBlockUserHandler()
                    }else {
                        self.blockUserHandler()
                    }
                }else if index == 2 {
                    self.reportHandler()
                }
            }
        }
    }
    
    func logoutHandler() {
        var alertArray:Array<[String : Any]> = []
        alertArray.append(["title":YCLanguageHelper.getString(key: "ConfirmLabel"), "textColor":YCStyleColor.red])
        self.showSheetAlert("", alertMessage: YCLanguageHelper.getString(key: "LogoutTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                if YCUserManager.logout() {
                    NotificationCenter.default.post(name: NSNotification.Name("LoginUserChange"), object: nil)
                    self.backButtonClick()
                }
            }
        }
    }
    
    func shareHandler() {
        if let user = self.userModel {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatFriendLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatMomentsLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeiboLabel")])
            self.showSheetAlert(nil, alertMessage: YCLanguageHelper.getString(key: "ShareToTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                if index != -1 {
                    var userURL = ShareURL.user.description
                    userURL = userURL+"?uid="+user.uuid
                    let slogon = YCLanguageHelper.getString(key: "Slogon")
                    let content = self.getNicknameString(user: user) + YCLanguageHelper.getString(key: "UserProfile")
                    var desc = self.getSignString(sign: user.signature)
                    if desc == "" {
                        desc = slogon
                    }
                    var thumbImage: UIImage?
                    if let iconImg = self.userIcon.image{
                        thumbImage = compressIconImage(iconImg, maxW: 100)
                    }
                    var platform = 0
                    var shareResult = false;
                    var errMessage = ""
                    if index == 0 {
                        shareResult = self.shareURL(userURL, title: content, description: desc, thumbImage: thumbImage, to: .weChat)
                        if shareResult {
                            platform = 2
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                        }
                    }else if index == 1 {
                        shareResult = self.shareURL(userURL, title: content, description: desc, thumbImage: thumbImage, to: .moments)
                        if shareResult {
                            platform = 3
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                        }
                    }else if index == 2 {
                        shareResult = self.shareURL(userURL, title: content, description: desc, thumbImage: thumbImage, to: .weibo)
                        if shareResult {
                            platform = 1
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeiboUninstall")
                        }
                    }
                    if shareResult {
                        YCShareDomain().shareUser(userID: user.userID, platform: platform, shareType: 1, completionBlock: { (result) in
                        })
                    }else {
                        self.showSingleAlert(errMessage, alertMessage: nil, view: self, compelecationBlock: nil
                        )
                    }
                }
            }
        }
    }
    
    @objc func followersTapHandler() {
        let userList = YCUserListViewController.getInstance()
        userList.userModel = self.userDetailModel
        userList.userListType = .Followers
        if let nav = self.navigationController {
            nav.pushViewController(userList, animated: true)
        }
    }
    
    @objc func followingTapHandler() {
        let userList = YCUserListViewController.getInstance()
        userList.userModel = self.userDetailModel
        userList.userListType = .Following
        
        if let nav = self.navigationController {
            nav.pushViewController(userList, animated: true)
        }
    }
    
    @objc func followButtonTap() {
        switch self.followButton.status {
        case .EditProfile:
            self.editProfileHandler()
        case .Unfollow:
            self.followUserHandler()
            break
        case .Following:
            self.unFollowUserHandler()
            break
        case .Unblock:
            self.unBlockUserHandler()
            break
        default:
            break
        }
    }
    
    @objc func postButtonTap() {
        if self.postButton.status != .Selected {
            self.postButton.status = .Selected
            self.likeButton.status = .Default
            self.userPublishType = .POST
            self.publishes.removeAll()
            self.collectionView.reloadData()
            self.refreshPage();
        }
    }
    
    @objc func likeButtonTap() {
        if self.likeButton.status != .Selected {
            self.likeButton.status = .Selected
            self.postButton.status = .Default
            self.userPublishType = .LIKE
            self.publishes.removeAll()
            self.collectionView.reloadData()
            self.refreshPage();
        }
    }
    
    func editProfileHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.editProfile()
        }, completeBlock: nil)
    }
    
    func editProfile() {
        let settingView = YCSettingViewController.getInstance()
        
        let navigationController = UINavigationController(rootViewController: settingView)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true) {
            
        }
        self.isSetting = true
    }
    
    func followUserHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.followHandler()
        }) {
            self.followHandler()
        }
    }
    
    func followHandler() {
        if let user = self.userModel as? YCRelationUserModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCUserDomain().followUser(userID: user.userID) { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        self.followButton.status = .Following
                        (self.userModel as? YCRelationUserModel)?.relation = 1
                    }else {
                        self.followButton.status = oldStatus
                        if let message = result.message {
                            self.showTempAlert("", alertMessage: message, view: self, completionBlock: nil)
                        }
                    }
                }else {
                    self.followButton.status = oldStatus
                }
            }
        }
    }
    
    func unFollowUserHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.unFollowConfirmHandler()
        }, completeBlock: nil)
    }
    
    func unFollowConfirmHandler() {
        var alertArray:Array<[String : Any]> = []
        alertArray.append(["title":YCLanguageHelper.getString(key: "UnFollowLabel"), "textColor":YCStyleColor.red])
        self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                self.unFollowHandler()
            }
        }
    }
    
    func unFollowHandler() {
        if let user = self.userModel as? YCRelationUserModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCUserDomain().unFollowUser(userID: user.userID) { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        (self.userModel as? YCRelationUserModel)?.relation = 0
                        self.followButton.status = .Unfollow
                    }else {
                        self.followButton.status = oldStatus
                        if let message = result.message {
                            self.showTempAlert("", alertMessage: message, view: self, completionBlock: nil)
                        }
                    }
                }else {
                    self.followButton.status = oldStatus
                }
            }
        }
    }
    
    func unBlockUserHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.unFollowHandler()
        }) {
            self.unFollowHandler()
        }
    }
    
    func blockUserHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.blockConfirmHandler()
        }, completeBlock: nil)
    }
    
    func blockConfirmHandler() {
        var alertArray:Array<[String : Any]> = []
        alertArray.append(["title":YCLanguageHelper.getString(key: "ConfirmLabel"), "textColor":YCStyleColor.red])
        self.showSheetAlert("", alertMessage: YCLanguageHelper.getString(key: "BlockTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                self.blockHandler()
            }
        }
    }
    
    func blockHandler() {
        if let user = self.userModel as? YCRelationUserModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCUserDomain().blockUser(userID: user.userID) { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        (self.userModel as? YCRelationUserModel)?.relation = 2
                        self.followButton.status = .Unblock
                    }else {
                        self.followButton.status = oldStatus
                        if let message = result.message {
                            self.showTempAlert("", alertMessage: message, view: self, completionBlock: nil)
                        }
                    }
                }else {
                    self.followButton.status = oldStatus
                }
            }
        }
    }
    
    func reportHandler() {
        if let user = self.userModel {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportInfringement")])
//            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportPolitical")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportPornLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportSpamLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportScamLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportAbuseLabel")])
            self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                let type = index + 1
                YCReportDomain().reportUser(userID: user.userID, reportType: type, content: "", contentImages: nil, completionBlock: { (result) in
                    
                })
            }
        }
    }
}

protocol YCUserViewControllerDelegate {
    func backUser(user: YCRelationUserModel?)
}


