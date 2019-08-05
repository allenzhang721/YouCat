//
//  CollectionViewController.swift
//  YouCat
//
//  Created by Emiaostein on 21/02/2018.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit

class YCHomeViewController: UIViewController, YCImageProtocol {
    
    static var _instance:YCHomeViewController?;
    
    static func getInstance() -> YCHomeViewController{
        if _instance == nil{
            _instance = YCHomeViewController();
        }
        return _instance!
    }
    
    var tableView: UITableView!
    
    var userIcon: UIImageView!
    
    var publishes: [YCPublishModel] = []
    
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
    
    func initView() {
        self.tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.bottom.equalTo(0-(44+YCScreen.safeArea.bottom))
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = YCScreen.bounds.height
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(YCPublishTableViewCell.self, forCellReuseIdentifier: "YCHomeCell")
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
       
        let iconView = UIView()
        headerView.addSubview(iconView)
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
        headerView.addSubview(titleLabel)
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
        
        self.tableView.tableHeaderView = headerView
        
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
    
    func beginLoadFresh(){
        if self.isFirstLoad {
            if self.publishes.count == 0 {
                let publishList = YCDateManager.loadPublishListDate(account: LocalManager.home)
                for publish in publishList {
                    self.publishes.append(publish)
                }
                if self.publishes.count > 0 {
                    self.tableView.reloadData()
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
                        self.tableView.reloadData()
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
}

extension YCHomeViewController: YCLoginProtocol {
    
    @objc func loginUserChange(_ notify: Notification) {
        self.isFirstLoad = true
        self.setUserIcon()
    }
    
    @objc func refreshHome(_ notify: Notification) {
        if self.tableView.contentOffset.y > 0 {
            let offset = CGPoint(x: 0, y: 0)
            self.tableView.setContentOffset(offset, animated: true)
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

extension YCHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.publishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:YCPublishTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "YCHomeCell", for: indexPath) as! YCPublishTableViewCell
        cell.delegate = self
        let row = indexPath.item
        let publishModel = self.publishes[row]
        cell.publishModel = publishModel
        return cell
    }
}

extension YCHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}



extension YCHomeViewController: YCPublishTableViewCellDelegate, YCAlertProtocol, YCShareProtocol, YCContentStringProtocol {
    
    func cellUserIconTap(_ cell: YCPublishTableViewCell?) {
        if cell != nil, let publish = cell?.publishModel {
            if let user = publish.user {
                NotificationCenter.default.post(name: NSNotification.Name("RootPushUserView"), object: user)
            }
        }
    }
    
    func cellContentTap(_ cell: YCPublishTableViewCell?, contentIndex: Int) {
        if cell != nil, let publish = cell?.publishModel {
            let publishDetail = YCPublishDetailViewController.getInstance()
            publishDetail.contentType = .HOME
            publishDetail.contentModel = publish
            publishDetail.contentIndex = contentIndex
            publishDetail.contents = [publish]
            publishDetail.contentID = publish.publishID

            NotificationCenter.default.post(name: NSNotification.Name("RootPushPublishView"), object: publishDetail)

//            let navigationController = UINavigationController(rootViewController: publishDetail)
//            navigationController.isNavigationBarHidden = true
//            self.present(navigationController, animated: true) {
//
//            }
        }
    }
    
    func cellCommentTap(_ cell:YCPublishTableViewCell?) {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.showCommentView(cell: cell)
        }) {
            self.isFirstLoad = false
        }
    }
    
    
    func cellLikeButtonClick(_ cell:YCPublishTableViewCell?){
        self.showLoginView(view: self, noNeedShowBlock: {
            if cell != nil, let publish = cell?.publishModel {
                if publish.isLike == 0 {
                    self.likePublishHandler(publish, publishCell: cell)
                }else {
                    self.unLikePublishHandler(publish, publishCell: cell)
                }
            }
        }) {
            self.isFirstLoad = false
            if cell != nil, let publish = cell?.publishModel {
                self.likePublishHandler(publish, publishCell: cell)
            }
        }
    }
    
    func cellCommentButtonClick(_ cell:YCPublishTableViewCell?){
        if let ce = cell, let publish = ce.publishModel {
            let commentList = YCCommentListViewController.getInstance(.Publish, style: .Default) { (model) in
                if let publishModel = model as? YCPublishModel {
                    ce.changePublishCommentStatus(publish: publishModel)
                }
            }
            commentList.publishModel = publish
            let navigationController = UINavigationController(rootViewController: commentList)
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.view.backgroundColor = UIColor.clear
            self.present(navigationController, animated: true) {
                navigationController.view.backgroundColor = UIColor.clear
            }
        }
    }
    
    func cellShareButtonClick(_ ce:YCPublishTableViewCell?){
        if let cell = ce, let publish = cell.publishModel {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatFriendLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatMomentsLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeiboLabel")])
            self.showSheetAlert(nil, alertMessage: YCLanguageHelper.getString(key: "ShareToTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                if index != -1 {
                    var publishURL = ShareURL.publish.description
                    publishURL = publishURL+"?uid="+publish.uuid
                    let slogon = YCLanguageHelper.getString(key: "Slogon")
                    let content = self.getContentString(content: publish.content)
                    var thumbImage: UIImage? = nil
                    if let view = cell.getContentView() {
                        thumbImage = view.getSnap()
                    }
                    var platform = 0;
                    var shareResult = false;
                    var errMessage = ""
                    if index == 0 {
                        shareResult = self.shareURL(publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .weChat)
                        if shareResult {
                            platform = 2
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                        }
                    }else if index == 1 {
                        shareResult = self.shareURL(publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .moments)
                        if shareResult {
                            platform = 3
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                        }
                    }else if index == 2 {
                        shareResult = self.shareURL(publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .weibo)
                        if shareResult {
                            platform = 1
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeiboUninstall")
                        }
                    }
                    if shareResult {
                        YCShareDomain().sharePublish(publishID: publish.publishID, platform: platform, shareType: 1, completionBlock: { (result) in
                        })
                    }else {
                        self.showSingleAlert(errMessage, alertMessage: nil, view: self, compelecationBlock: nil
                        )
                    }
                }
            }
        }
    }
    
    func cellOperateButtonClick(_ cell:YCPublishTableViewCell?){
        var alertArray:Array<[String : Any]> = []
//        alertArray.append(["title":YCLanguageHelper.getString(key: "ContentLinkLabel")])
        alertArray.append(["title":YCLanguageHelper.getString(key: "ReportLabel"), "textColor":YCStyleColor.red])
        self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0 {
                self.reportHandler(cell)
            }
        }
    }
    
    func likePublishHandler(_ publish: YCPublishModel, publishCell: YCPublishTableViewCell?) {
        if publish.isLike == 0 {
            publish.isLike = 1
            publish.likeCount = publish.likeCount + 1
            YCLikeDomain().likePublish(publishID: publish.publishID, completionBlock: { (result) in
                if let re = result, re.result {
                    publish.isLike = 1
                    for oldPublish in self.publishes {
                        if oldPublish.publishID == publish.publishID {
                            oldPublish.isLike = publish.isLike
                            oldPublish.likeCount = publish.likeCount
                            break
                        }
                    }
                }
            })
            if let cell = publishCell {
                cell.changePublishLikeStatus(publish: publish)
            }
        }
    }
    
    func unLikePublishHandler(_ publish: YCPublishModel, publishCell: YCPublishTableViewCell?) {
        if publish.isLike == 1 {
            publish.isLike = 0
            publish.likeCount = publish.likeCount - 1
            if publish.likeCount < 0 {
                publish.likeCount = 0
            }
            YCLikeDomain().unLikePublish(publishID: publish.publishID, completionBlock: { (result) in
                if let re = result, re.result {
                    publish.isLike = 0
                    for oldPublish in self.publishes {
                        if oldPublish.publishID == publish.publishID {
                            oldPublish.isLike = publish.isLike
                            oldPublish.likeCount = publish.likeCount
                            break
                        }
                    }
                }
            })
            if let cell = publishCell {
                cell.changePublishLikeStatus(publish: publish)
            }
        }
    }
    
    func showCommentView(cell: YCPublishTableViewCell?) {
        if let ce = cell, let index = self.tableView.indexPath(for: ce){
            let commentView = YCCommentViewController(style: .Default, keyboardWillShow: { (_, h) in
                let rect = self.tableView.rectForRow(at: index)
                let offY = YCScreen.bounds.height - YCScreen.safeArea.top - (rect.height - 70 + CGFloat(h))
                self.tableView.contentOffset.y = rect.origin.y - offY
            }, complete: { (content) in
                if let publish = ce.publishModel, content != "" {
                    YCCommentDomain().commentPublish(publishID: publish.publishID, content: content, contentImages: nil, completionBlock: { (modelMode) in
                        if let model = modelMode{
                            if model.result {
                                publish.commentCount = publish.commentCount + 1
                                ce.changePublishCommentStatus(publish: publish)
                                self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "CommentSuccessLabel"), view: self, completionBlock: nil)
                            }
                        }
                    })
                }
                
            })
            self.present(commentView, animated: true, completion: {
                
            })
        }
    }
    
    func reportHandler(_ cell: YCPublishTableViewCell?) {
        if let ce = cell, let publish = ce.publishModel {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportInfringement")])
//            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportPolitical")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportPornLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportSpamLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportScamLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportAbuseLabel")])
            self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                let type = index + 1
                YCReportDomain().reportPublish(publishID: publish.publishID, reportType: type, content: "", contentImages: nil, completionBlock: { (resultModel) in
                    
                })
            }
        }
    }
}


