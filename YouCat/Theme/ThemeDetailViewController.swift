//
//  ThemeDetailViewController.swift
//  YouCat
//
//  Created by ting on 2018/10/22.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import MJRefresh

class YCThemeDetailViewController: UIViewController, YCImageProtocol, YCContentStringProtocol, YCAlertProtocol {
    
    static var _instaceArray: [YCThemeDetailViewController] = [];
    
    static func getInstance() -> YCThemeDetailViewController{
        var _instance: YCThemeDetailViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            _instance.initViewController()
            return _instance
        }else {
            _instance = YCThemeDetailViewController();
            _instance.initViewController()
        }
        return _instance
    }
    
    static func addInstance(instace: YCThemeDetailViewController) {
        _instaceArray.append(instace)
    }
    
    let refreshCount = 40
    
    var themeModel: YCThemeModel?
    var themeDetailModel: YCThemeDetailModel?
    
    var themeType = 0
    
    var publishes: [YCPublishModel] = []
    var publishSizes: [String : CGSize] = [:]
    
    var collectionView: UICollectionView!
    var collectionLayout: YCCollectionViewWaterfallLayout!
    
    var topView: UIView!
    var topHeight: CGFloat = 0
    var coverImg: YCImageView!
    var themeNameLabel: UILabel!
    var themeDescLabel: UILabel!
    var followButton: YCFollowButton!
    var topLineView: UIView!
    var maskView: UIView!
    
    var loadingView: YCLoadingView!
    
    let footerFresh = MJRefreshAutoNormalFooter()
    
    var isFirstShow: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        if self.isFirstShow {
           self.setValue(themeModel: self.themeModel)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isFirstShow {
            self.themeDetail()
            self.refreshPage()
        }
        self.isFirstShow = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
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
        
//        self.maskView = UIView(frame: view.bounds)
//        maskView.backgroundColor = .blue
//        view.mask = maskView
//        
//        print(maskView.frame)
    }
    
    func initOperateButton() {
        let closeButton=UIButton()
        closeButton.tag = 100
        closeButton.setImage(UIImage(named: "close_black"), for: .normal)
        closeButton.setImage(UIImage(named: "close_black"), for: .highlighted)
        closeButton.addTarget(self, action: #selector(self.closeButtonClick), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.right.equalTo(-10)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        let operateButton=UIButton()
        operateButton.tag = 101
        operateButton.setImage(UIImage(named: "operate_black"), for: .normal)
        operateButton.setImage(UIImage(named: "operate_black"), for: .highlighted)
        operateButton.addTarget(self, action: #selector(self.operateButtonClick), for: .touchUpInside)
        self.view.addSubview(operateButton)
        operateButton.snp.makeConstraints { (make) in
            make.top.equalTo(YCScreen.safeArea.top)
            make.right.equalTo(-54)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
    }
    
    func updateInitStartView(){
        updateInitalViews()
    }
    
    func updateInitEndView(){
        updateFinalViews()
    }
    
    var snapView: UIView?
    
    func updatestartDismiss(){
        updateFinalViews()
//        let topH = self.topView.bounds.height
        if self.collectionView.contentOffset.y > self.topHeight {
            snapView = view.snapshotView(afterScreenUpdates: false)
            view.addSubview(snapView!)
            self.collectionView.contentOffset.y = self.topHeight
        }
    }
    
    func updatefinalDismiss(){
        updateInitalViews()
        self.collectionView.contentOffset.y = 0
        if snapView != nil {
            snapView!.transform = CGAffineTransform(translationX: 0, y: topHeight)
        }
    }
    
    func updateDidDismissed() {
        snapView?.removeFromSuperview()
    }
    
    func updateInitalViews() {
        if self.isFirstShow {
            self.setValue(themeModel: self.themeModel)
        }
        let wGap = YCScreen.bounds.width * 0.06
        let offset: CGFloat = wGap
        let bounds = YCScreen.bounds
        self.themeNameLabel.frame.origin.x = offset + 20
        self.themeDescLabel.frame.origin.x = offset + 20
        self.followButton.frame.origin.x = bounds.width - 100 - offset
        self.followButton.alpha = 0
        self.topLineView.alpha = 0
        view.viewWithTag(100)?.alpha = 0
        view.viewWithTag(101)?.alpha = 0
        
    }
    
    func updateFinalViews() {
        if self.isFirstShow {
            self.setValue(themeModel: self.themeModel)
        }
        let offset: CGFloat = 0
        let bounds = YCScreen.bounds
        self.themeNameLabel.frame.origin.x = offset + 20
        self.themeDescLabel.frame.origin.x = offset + 20
        self.followButton.frame.origin.x = bounds.width - 100 - offset
        self.followButton.alpha = 1
        self.topLineView.alpha = 1
        view.viewWithTag(100)?.alpha = 1
        view.viewWithTag(101)?.alpha = 1
    }
    
    func initTopView(){
        
        let offset: CGFloat = 0
        
        let bounds = YCScreen.bounds
        self.topView = UIView(frame: CGRect(x:0, y:0, width: bounds.width, height: bounds.width))
        self.topView.backgroundColor = YCStyleColor.white
        
        self.coverImg = YCImageView(frame: CGRect(x:0, y:0, width: bounds.width, height: bounds.width))
        coverImg.contentMode = .scaleAspectFill
        self.topView.addSubview(self.coverImg)
        
        self.themeNameLabel = UILabel(frame: CGRect(x:offset + 20, y:0, width: bounds.width - 120, height: 36))
        self.topView.addSubview(self.themeNameLabel)
        self.themeNameLabel.textColor = YCStyleColor.black
        self.themeNameLabel.font = UIFont.boldSystemFont(ofSize: 36)
        
        self.themeDescLabel = UILabel(frame: CGRect(x:offset + 20, y:0, width: bounds.width - 40, height: 22))
        self.topView.addSubview(self.themeDescLabel)
        self.themeDescLabel.textColor = YCStyleColor.gray
        self.themeDescLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.themeDescLabel.numberOfLines = 0
        
        self.followButton = YCFollowButton(frame: CGRect(x:bounds.width - 100 - offset, y:0, width: 90, height: 32))
        self.topView.addSubview(self.followButton)
        let followTap = UITapGestureRecognizer(target: self, action: #selector(self.followButtonTap))
        self.followButton.addGestureRecognizer(followTap)
        
        self.topLineView = UIView(frame: CGRect(x:0, y:0, width: bounds.width, height: 1))
        self.topView.addSubview(self.topLineView)
        self.topLineView.backgroundColor = YCStyleColor.grayWhite
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
    
    func setValue(themeModel: YCThemeModel?){
        let bounds = YCScreen.bounds
        var stypleType = 1;
        if let theme = themeModel {
            if let cover = theme.coverImage {
                let coverW = cover.imageWidth
                let coverH = cover.imageHeight
                var rate:CGFloat = CGFloat(coverH/coverW)
                if rate > 4/3 {
                    rate = 4/3
                }
                self.coverImg.frame.size.height = bounds.width * rate
                self.coverImg.loadSnapImage(cover, snapShot: false)
            }else {
                self.coverImg.frame.size.height = bounds.width * 9/16
            }
            self.themeNameLabel.text = self.getContentString(content: theme.name)
            self.themeDescLabel.text = self.getContentString(content: theme.description)
            if let status = YCFollowButtonStatus(rawValue: theme.relation) {
                self.followButton.status = status
            }else {
                self.followButton.status = .Unfollow
            }
            stypleType = theme.styleType
            if stypleType == 0{
                stypleType = 1
            }
        }else {
            self.coverImg.frame.size.height = bounds.width * 9/16
            self.coverImg.defaultStyle()
            self.themeNameLabel.text = ""
            self.themeDescLabel.text = ""
            self.followButton.status = .Unfollow
        }
        self.themeNameLabel.sizeToFit()
        self.themeDescLabel.sizeToFit()
        var topH:CGFloat = 1
        switch stypleType {
        case 1:
            self.themeNameLabel.frame.origin.x = 20
            self.themeNameLabel.frame.origin.y = self.coverImg.frame.height + 10
            self.themeDescLabel.frame.origin.y = self.themeNameLabel.frame.origin.y +  self.themeNameLabel.frame.height + 10
            self.themeDescLabel.frame.origin.x = 20
            self.themeDescLabel.frame.size.width = bounds.width - 40
            self.followButton.frame.origin.y = self.themeNameLabel.frame.origin.y - (self.followButton.frame.height - self.themeNameLabel.frame.height)/2
            topH = self.themeDescLabel.frame.origin.y + self.themeDescLabel.frame.height + 11
            self.themeNameLabel.textColor = YCStyleColor.black
            self.themeDescLabel.textColor = YCStyleColor.gray
            self.topLineView.isHidden = false
            break;
        case 2:
            self.themeNameLabel.frame.origin.x = 20
            self.themeNameLabel.frame.origin.y = YCScreen.safeArea.top + 20
            self.themeDescLabel.frame.origin.y = self.themeNameLabel.frame.origin.y +  self.themeNameLabel.frame.height + 10
            self.themeDescLabel.frame.origin.x = 20
            self.themeDescLabel.frame.size.width = bounds.width - 40
            self.followButton.frame.origin.y = self.coverImg.frame.height - self.followButton.frame.height - 10
            topH = self.coverImg.frame.height
            self.themeNameLabel.textColor = YCStyleColor.white
            self.themeDescLabel.textColor = YCStyleColor.whiteAlpha
            self.topLineView.isHidden = true
            break;
        case 3:
            self.themeNameLabel.frame.origin.x = 20
            self.themeNameLabel.frame.origin.y = YCScreen.safeArea.top + 20
            self.themeDescLabel.frame.origin.y = self.themeNameLabel.frame.origin.y +  self.themeNameLabel.frame.height + 10
            self.themeDescLabel.frame.origin.x = 20
            self.themeDescLabel.frame.size.width = bounds.width - 40
            self.followButton.frame.origin.y = self.coverImg.frame.height - self.followButton.frame.height - 10
            topH = self.coverImg.frame.height
            self.themeNameLabel.textColor = YCStyleColor.black
            self.themeDescLabel.textColor = YCStyleColor.blackAlphaMore
            self.topLineView.isHidden = true
            break;
        default:
            break;
        }
        self.topHeight = topH
        self.topView.frame.size.height = topH
        self.topLineView.frame.origin.y = topH - 1
        self.collectionLayout.headerReferenceSize = CGSize(width: bounds.width, height: topH)
        self.loadingView.snp.updateConstraints { (make) in
            make.top.equalTo(topH+15)
        }
    }
    
    func themeDetail() {
        if let theme = self.themeModel {
            self.followButton.status = .Loading
            YCThemeDomain().themeDetail(themeID: theme.themeID, completionBlock: { (modelMode) in
                if let model = modelMode, model.result {
                    if let themeDetail = model.baseModel as? YCThemeDetailModel {
                        self.setValue(themeModel: themeDetail)
                        self.themeDetailModel = themeDetail
                        if let status = YCFollowButtonStatus(rawValue: themeDetail.relation) {
                            self.followButton.status = status
                        }else {
                            self.followButton.status = .Unfollow
                        }
                    }else {
                        if let themeDetail = self.themeDetailModel {
                            if let status = YCFollowButtonStatus(rawValue: themeDetail.relation) {
                                self.followButton.status = status
                            }else {
                                self.followButton.status = .Unfollow
                            }
                        }else {
                            self.followButton.status = .Unfollow
                        }
                    }
                }else {
                    if let themeDetail = self.themeDetailModel {
                        if let status = YCFollowButtonStatus(rawValue: themeDetail.relation) {
                            self.followButton.status = status
                        }else {
                            self.followButton.status = .Unfollow
                        }
                    }else {
                        self.followButton.status = .Unfollow
                    }
                }
            })
        }
    }
    
    func refreshPage(){
        if let theme = self.themeModel {
            self.loadingView.startAnimating()
            YCPublishDomain().themePublishList(themeID: theme.themeID, type: self.themeType, start: 0, count: self.refreshCount, completionBlock: { (modelList) in
                if let list = modelList {
                    if list.result{
                        if let modelList = list.modelArray {
                            self.publishes.removeAll()
                            if self.updatePublishDate(modelList: modelList) {
                                self.collectionView.reloadData()
                                self.footerFresh.resetNoMoreData()
                                self.footerFresh.isHidden = false
                            }
                        }
                        self.loadingView.stopAnimating()
                    }else {
                        self.loadingView.stopAnimating()
                        self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "WifiErrorShortMessage"), view: self, completionBlock: {
                        })
                    }
                }else {
                    self.loadingView.stopAnimating()
                }
            })
        }
    }
    
    @objc func footerRefresh() {
        if let theme = self.themeModel {
            YCPublishDomain().themePublishList(themeID: theme.themeID, type: self.themeType, start: self.publishes.count, count: self.refreshCount, completionBlock: { (modelList) in
                if let list = modelList {
                    if list.result{
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
                        self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "WifiErrorShortMessage"), view: self, completionBlock: {
                        })
                    }
                }else {
                    self.footerFresh.endRefreshing()
                }
            })
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
    
    func initViewController() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginUserChange(_:)), name: NSNotification.Name("LoginUserChange"), object: nil)
    }
    
    func resetViewController() {
        self.themeModel = nil
        self.themeDetailModel = nil
        self.publishes.removeAll()
        self.publishSizes.removeAll()
        self.collectionView.reloadData()
        self.footerFresh.isHidden = true
        self.isFirstShow = true
        self.followButton.status = .Unfollow
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LoginUserChange"), object: nil)
    }
}

extension YCThemeDetailViewController: UICollectionViewDataSource {
   
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
        cell.type = .THEME
        cell.publishModel = publishModel
        return cell
    }
}

extension YCThemeDetailViewController: YCCollectionViewWaterfallLayoutDelegate {
    
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
        publishDetail.contents = self.publishes
        publishDetail.contentType = .THEME
        publishDetail.contentIndex = 0
        if let themeModel = self.themeModel {
            publishDetail.contentID = themeModel.themeID
        }
        publishDetail.contentValue = ["ThemeType": self.themeType]
        
        let navigationController = UINavigationController(rootViewController: publishDetail)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true) {
            
        }
    }
}

extension YCThemeDetailViewController: YCPublishCollectionViewCellDelegate, YCLoginProtocol, YCShareProtocol {
    
    @objc func loginUserChange(_ notify: Notification) {
        self.isFirstShow = true
    }
    
    @objc func closeButtonClick(){
//        self.navigationController?.dismiss(animated: true, completion: { () -> Void in
//            self.resetViewController()
//            YCThemeDetailViewController.addInstance(instace: self)
//        })
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func operateButtonClick(){
        
//        snapView = view.snapshotView(afterScreenUpdates: true)
//        view.addSubview(snapView!)
//        return
        
        if self.followButton.status != .Loading {
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
                        self.unBlockThemeHandler()
                    }else {
                        self.blockThemeHandler()
                    }
                }else if index == 2 {
                    self.reportHandler()
                }
            }
        }
    }
    
    func shareHandler() {
        if let theme = self.themeModel {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatFriendLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatMomentsLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "WeiboLabel")])
            self.showSheetAlert(nil, alertMessage: YCLanguageHelper.getString(key: "ShareToTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                if index != -1 {
                    var themeURL = ShareURL.theme.description
                    themeURL = themeURL+"?uid="+theme.uuid
                    let slogon = YCLanguageHelper.getString(key: "Slogon")
                    let content = self.getContentString(content: theme.name)
                    var desc = self.getContentString(content: theme.description)
                    if desc == "" {
                        desc = slogon
                    }
                    let thumbImage: UIImage? = self.coverImg.getSnap()
                    var platform = 0
                    var shareResult = false;
                    var errMessage = ""
                    if index == 0 {
                        shareResult = self.shareURL(themeURL, title: content, description: desc, thumbImage: thumbImage, to: .weChat)
                        if shareResult {
                            platform = 2
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                        }
                    }else if index == 1 {
                        shareResult = self.shareURL(themeURL, title: content, description: desc, thumbImage: thumbImage, to: .moments)
                        if shareResult {
                            platform = 3
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                        }
                    }else if index == 2 {
                        shareResult = self.shareURL(themeURL, title: content, description: desc, thumbImage: thumbImage, to: .weibo)
                        if shareResult {
                            platform = 1
                        }else {
                            errMessage = YCLanguageHelper.getString(key: "ShareFailedWeiboUninstall")
                        }
                    }
                    if shareResult {
                        YCShareDomain().shareTheme(themeID: theme.themeID, platform: platform, shareType: 1, completionBlock: { (result) in
                        })
                    }else {
                        self.showSingleAlert(errMessage, alertMessage: nil, view: self, compelecationBlock: nil
                        )
                    }
                }
            }
        }
    }
    
    func cellUserIconTap(_ cell:YCPublishCollectionViewCell?){
        
    }
    
    @objc func followButtonTap() {
        switch self.followButton.status {
        case .Unfollow:
            self.followThemeHandler()
            break
        case .Following:
            self.unFollowThemeHandler()
            break
        case .Unblock:
            self.unBlockThemeHandler()
            break
        default:
            break
        }
    }
    
    func followThemeHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.followHandler()
        }) {
            self.followHandler()
        }
    }
    
    func followHandler() {
        if let theme = self.themeModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCThemeDomain().followTheme(themeID: theme.themeID) { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        self.themeModel?.relation = 1
                        self.followButton.status = .Following
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
    
    func unFollowThemeHandler() {
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
        if let theme = self.themeModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCThemeDomain().unFollowTheme(themeID: theme.themeID, completionBlock: { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        self.themeModel?.relation = 0
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
            })
        }
    }
    
    func unBlockThemeHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.unFollowHandler()
        }) {
            self.unFollowHandler()
        }
    }
    
    func blockThemeHandler() {
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
        if let theme = self.themeModel {
            let oldStatus = self.followButton.status
            self.followButton.status = .Loading
            YCThemeDomain().blockTheme(themeID: theme.themeID, completionBlock: { (resultMode) in
                if let result = resultMode {
                    if result.result {
                        self.themeModel?.relation = 2
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
            })
        }
    }
    
    func reportHandler() {
        if let theme = self.themeModel {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportInfringement")])
            //            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportPolitical")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportPornLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportSpamLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportScamLabel")])
            alertArray.append(["title":YCLanguageHelper.getString(key: "ReportAbuseLabel")])
            self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                let type = index + 1
                YCReportDomain().reportTheme(themeID: theme.themeID, reportType: type, content: "", contentImages: nil, completionBlock: { (result) in
                })
            }
        }
    }
}

class YCCollectionHeaderView: UICollectionReusableView {
}

class YCCollectionFooterView: UICollectionReusableView {
}

