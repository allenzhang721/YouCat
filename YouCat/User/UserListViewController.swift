//
//  UserListViewController.swift
//  YouCat
//
//  Created by ting on 2019/4/29.
//  Copyright © 2019年 Curios. All rights reserved.
//

import UIKit
import MJRefresh
import Kingfisher

enum YCUserListType: String{
    case Followers = "followers"
    case Following = "following"
}

class YCUserListViewController: UIViewController{
    static var _instaceArray: [YCUserListViewController] = [];
    
    static func getInstance() -> YCUserListViewController{
        var _instance: YCUserListViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            _instance.initViewController()
            return _instance
        }else {
            _instance = YCUserListViewController();
            _instance.initViewController()
        }
        return _instance
    }
    
    static func addInstance(instace: YCUserListViewController) {
        _instaceArray.append(instace)
    }
    
    var userModel: YCUserDetailModel?
    var userListType: YCUserListType = .Followers
    let refreshCount = 40
    // 顶部刷新
    let headerFresh = MJRefreshNormalHeader()
    // 底部刷新
    let footerFresh = MJRefreshAutoNormalFooter()
    
    var tableView: UITableView!
    
    var titleLabel: UILabel!
    
    var userList: [YCRelationUserModel] = []
    
    var isFirstShow = true
    
    func initViewController(){
        
    }
    
    func resetViewController(){
        self.userModel = nil
        self.userList.removeAll()
        self.tableView.reloadData()
        self.footerFresh.isHidden = true
        self.footerFresh.resetNoMoreData()
        self.isFirstShow = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        super.viewWillAppear(animated)
        self.setValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.beginLoadFresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(){
        self.view.backgroundColor = YCStyleColor.white
        var topHeight: CGFloat = 44
        if let bar = self.navigationController?.navigationBar{
            topHeight = bar.frame.height
        }
        topHeight = YCScreen.safeArea.top + topHeight
        
        let headerView = UIView()
        self.view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.height.equalTo(topHeight)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        let backButton=UIButton()
        backButton.setImage(UIImage(named: "back_black"), for: .normal)
        backButton.setImage(UIImage(named: "back_black"), for: .highlighted)
        backButton.addTarget(self, action: #selector(self.backButtonClick), for: .touchUpInside)
        headerView.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.left.equalTo(10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        self.titleLabel = UILabel()
        self.titleLabel.numberOfLines = 1
        headerView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(64)
            make.right.equalTo(-64)
            make.centerY.equalTo(backButton).offset(0)
        }
        self.titleLabel.textColor = YCStyleColor.black
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.titleLabel.text = ""
        self.titleLabel.textAlignment = .center
        
        let topLineView = UIView()
        headerView.addSubview(topLineView)
        topLineView.backgroundColor = YCStyleColor.grayWhite
        topLineView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(topHeight-1)
            make.height.equalTo(1)
        }
        
        self.tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topHeight)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = 64
        self.tableView.register(YCUserTableViewCell.self, forCellReuseIdentifier: "YCUserListCell")
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: YCScreen.safeArea.bottom))

        self.headerFresh.setRefreshingTarget(self, refreshingAction: #selector(self.refreshPage))
        self.headerFresh.stateLabel.isHidden = true
        self.headerFresh.lastUpdatedTimeLabel.isHidden = true
        self.tableView.mj_header = self.headerFresh
        self.footerFresh.setRefreshingTarget(self, refreshingAction: #selector(self.footerRefresh))
        self.tableView.mj_footer = self.footerFresh
        self.footerFresh.isHidden = true
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func setValue(){
        if let user = self.userModel {
            if self.userListType == .Followers {
                let count = user.followersCount
                self.titleLabel.text = self.getNumberString(number: count) + " " +  YCLanguageHelper.getString(key: "FollowersLabel");
            }else if self.userListType == .Following {
                let count = user.followingCount
                self.titleLabel.text = self.getNumberString(number: count) + " " +  YCLanguageHelper.getString(key: "FollowingLabel");
            }
            
        }
    }
    
    func beginLoadFresh(){
        if self.isFirstShow {
            self.headerFresh.beginRefreshing()
        }
        self.isFirstShow = false
    }
    
    @objc func refreshPage() {
        if let userID = self.userModel?.userID {
            if self.userListType == .Followers {
                YCUserDomain().userFollowerList(userID: userID, start: 0, count: self.refreshCount) { (modelList) in
                    self.refreshComplete(modelList: modelList)
                }
            }else if self.userListType == .Following {
                YCUserDomain().userFollowingList(userID: userID, start: 0, count: self.refreshCount) { (modelList) in
                    self.refreshComplete(modelList: modelList)
                }
            }
        }
    }
    
    func refreshComplete(modelList: YCDomainListModel?) {
        if let list = modelList, list.result{
            if let modelList = list.modelArray {
                self.userList.removeAll()
                if self.updateUserListDate(modelList: modelList) {
                    self.tableView.reloadData()
                }
                if self.userList.count < self.refreshCount/2 {
                    self.footerFresh.endRefreshingWithNoMoreData()
                    self.footerFresh.isHidden = true
                }else {
                    self.footerFresh.resetNoMoreData()
                    self.footerFresh.isHidden = false
                }
            }
            self.headerFresh.endRefreshing()
        }else {
            self.headerFresh.endRefreshing()
        }
    }
    
    @objc func footerRefresh() {
        if let userID = self.userModel?.userID {
            if self.userListType == .Followers {
                YCUserDomain().userFollowerList(userID: userID, start: self.userList.count, count: self.refreshCount) { (modelList) in
                    self.footerRefreshComplete(modelList: modelList)
                }
            }else if self.userListType == .Following {
                YCUserDomain().userFollowingList(userID: userID, start: self.userList.count, count: self.refreshCount) { (modelList) in
                    self.footerRefreshComplete(modelList: modelList)
                }
            }
        }
    }
    
    func footerRefreshComplete(modelList: YCDomainListModel?) {
        if let list = modelList, list.result{
            if let modelList = list.modelArray {
                if self.updateUserListDate(modelList: modelList) {
                    self.tableView.reloadData()
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
    
    func updateUserListDate(modelList: Array<YCBaseModel>) -> Bool{
        var isChange = false
        for model in modelList {
            if let user = model as? YCRelationUserModel {
                var isHave = false
                var index = 0
                for (i, oldUser) in self.userList.enumerated() {
                    if oldUser.userID == user.userID {
                        isHave = true
                        index = i
                        break
                    }
                }
                if !isHave {
                    self.userList.append(user)
                    isChange = true
                }else {
                    self.userList.remove(at: index)
                    self.userList.insert(user, at: index)
                }
            }
        }
        return isChange
    }
}

extension YCUserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:YCUserTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "YCUserListCell", for: indexPath) as! YCUserTableViewCell
        cell.delegate = self
        let row = indexPath.item
        let userModel = self.userList[row]
        cell.userModel = userModel
        return cell
    }
}

extension YCUserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}

extension YCUserListViewController: UIGestureRecognizerDelegate, YCUserTableViewCellDelegate, YCNumberStringProtocol, YCUserViewControllerDelegate{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    func cellUserIconTap(_ cell:YCUserTableViewCell?){
        if cell != nil, let user = cell?.userModel {
            let userProfile = YCUserViewController.getInstance()
            userProfile.userModel = user
            userProfile.delegate = self
            if let nav = self.navigationController {
                nav.pushViewController(userProfile, animated: true)
            }
        }
    }
    
    @objc func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.resetViewController()
            YCUserListViewController.addInstance(instace: self)
        }
    }
    
    func backUser(user: YCRelationUserModel?) {
        if let u = user {
            var isHave = false
            var index = 0
            for (i, oldUser) in self.userList.enumerated() {
                if oldUser.userID == u.userID {
                    isHave = true
                    index = i
                    break
                }
            }
            if isHave {
                self.userList.remove(at: index)
                self.userList.insert(u, at: index)
                self.tableView.reloadData()
            }
        }
    }
}
