//
//  CommentListViewController.swift
//  YouCat
//
//  Created by ting on 2018/12/14.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit

enum YCCommentLisType: String{
    case Publish = "Publish"
    case Theme = "Theme"
    case User = "User"
}

enum YCCommentListStyle: String{
    case Default = "Default"
    case Dark = "Dark"
}


class YCCommentListViewController: UIViewController, YCContentStringProtocol, YCAlertProtocol {
    
    var listType: YCCommentLisType = .Publish
    var listStyle: YCCommentListStyle = .Default
    var completeBlock: ((_ model: YCBaseModel?) -> Void)?
    
    convenience init(_ type: YCCommentLisType, style: YCCommentListStyle, completeBlock: ((_ model: YCBaseModel?) -> Void)?) {
        self.init()
        self.listType = type
        self.listStyle = style
        self.completeBlock = completeBlock
        self.view.backgroundColor = UIColor.clear
        self.modalPresentationStyle = .custom
    }
    
    static var _instaceArray: [YCCommentListViewController] = [];
    
    static func getInstance(_ type: YCCommentLisType, style: YCCommentListStyle, completeBlock: ((_ model: YCBaseModel?) -> Void)?) -> YCCommentListViewController{
        var _instance: YCCommentListViewController
        if _instaceArray.count > 0 {
            _instance = _instaceArray[0]
            _instaceArray.remove(at: 0)
            _instance.listType = type
            _instance.listStyle = style
            _instance.completeBlock = completeBlock
            return _instance
        }else {
            _instance = YCCommentListViewController(type, style: style, completeBlock: completeBlock)
        }
        return _instance
    }
    
    static func addInstance(instace: YCCommentListViewController) {
        _instaceArray.append(instace)
    }
    
    var commentBg: UIView!
    
    var closeButton: UIButton!
    var commenButton: UIImageView!
    var commentCountLabel: UILabel!
    var headerLine: UIView!
    
    var commentView: UIView!
    var commentBordView: UIView!
    var commentLabel: UILabel!
    var commentViewLine: UIView!
    
    var tableView: UITableView!
    
    var commentes: [YCCommentModel] = []   // 数据结构
    var viewCommentes: [YCCommentModel] = []   // 显示结构
    
    var isFirstLoad: Bool = true
    
    var loadingView: YCLoadingView!
    // 底部刷新
    let footerFresh = MJRefreshAutoNormalFooter()
    
    let refreshCount = 40
    let replyCount = 20
    
    let headerHeight = 44
    let bottomHeight = 48 + YCScreen.safeArea.bottom
    
    var publishModel: YCPublishModel?
    var themeModel: YCThemeModel?
    var userModel: YCUserModel?
    
    let commentBgTop = YCScreen.bounds.height / 4
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        if self.isFirstLoad {
            self.initStyle()
            self.setValue()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isFirstLoad {
            self.refreshPage()
        }
        self.isFirstLoad = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initOperateView()
        self.initBottomView()
        self.view.isUserInteractionEnabled = true
        let viewSigleTap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        self.view.addGestureRecognizer(viewSigleTap)
    }
    
    func initStyle() {
        if self.listStyle == .Default {
            self.commentBg.backgroundColor = YCStyleColor.white
            self.commentBg.layer.borderColor = YCStyleColor.grayWhite.cgColor
            self.closeButton.setImage(UIImage(named: "close_gray"), for: .normal)
            self.closeButton.setImage(UIImage(named: "close_gray"), for: .highlighted)
            self.commenButton.image = UIImage(named: "comment_gray")
            self.commentCountLabel.textColor = YCStyleColor.gray
            self.headerLine.backgroundColor = YCStyleColor.grayWhite
            
            self.commentView.backgroundColor = YCStyleColor.white
            self.commentBordView.layer.borderColor = YCStyleColor.gray.cgColor
            self.commentBordView.backgroundColor = YCStyleColor.white
            self.commentLabel.textColor = YCStyleColor.gray
            self.commentViewLine.backgroundColor = YCStyleColor.grayWhite
            self.loadingView.style = .INSIDE
        }else if self.listStyle == .Dark {
            self.commentBg.backgroundColor = YCStyleColor.blackAlpha
            self.commentBg.layer.borderColor = YCStyleColor.grayWhiteAlpha.cgColor
            self.closeButton.setImage(UIImage(named: "close_white"), for: .normal)
            self.closeButton.setImage(UIImage(named: "close_white"), for: .highlighted)
            self.commenButton.image = UIImage(named: "comment_white")
            self.commentCountLabel.textColor = YCStyleColor.white
            self.headerLine.backgroundColor = YCStyleColor.grayWhiteAlpha
            
            self.commentView.backgroundColor = YCStyleColor.black
            self.commentBordView.layer.borderColor = YCStyleColor.black.cgColor
            self.commentBordView.backgroundColor = YCStyleColor.grayWhiteAlpha
            self.commentLabel.textColor = YCStyleColor.grayWhite
            self.commentViewLine.backgroundColor = YCStyleColor.grayWhiteAlpha
            self.loadingView.style = .INSIDEWhite
        }
    }
    
    func setValue() {
        if self.listType == .Publish, let publish = self.publishModel {
            let commentCount = publish.commentCount
            self.commentCountLabel.text = "\(commentCount)"
        }else if self.listType == .Theme, let _ = self.themeModel {
            self.commentCountLabel.text = ""
        }
    }
    
    func initView() {
        self.commentBg = UIView()
        self.view.addSubview(self.commentBg)
        self.commentBg.snp.makeConstraints { (make) in
            make.left.equalTo(-1)
            make.right.equalTo(1)
            make.top.equalTo(self.commentBgTop)
            make.bottom.equalTo(0)
        }
        self.commentBg.layer.borderWidth = 1
        self.commentBg.layer.cornerRadius = 8;
        self.commentBg.clipsToBounds = true
        self.commentBg.isUserInteractionEnabled = true
        let viewSigleTap = UITapGestureRecognizer(target: self, action: nil)
        self.commentBg.addGestureRecognizer(viewSigleTap)
        
        self.tableView = UITableView()
        self.commentBg.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerHeight)
            make.bottom.equalTo(0-self.bottomHeight)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = YCScreen.bounds.width
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.register(YCCommentListViewCell.self, forCellReuseIdentifier: "YCCommentListCell")
        
        self.loadingView = YCLoadingView(style: .INSIDEWhite)
        self.commentBg.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.commentBg).offset(0)
            make.top.equalTo(headerHeight+15)
        }
        
        self.footerFresh.setRefreshingTarget(self, refreshingAction: #selector(self.footerRefresh))
        self.tableView.mj_footer = self.footerFresh
        self.footerFresh.isHidden = true
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func initOperateView() {
        let operateView = UIView()
        self.commentBg.addSubview(operateView)
        operateView.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(self.headerHeight)
        }
        
        self.closeButton = UIButton()
        self.closeButton.setImage(UIImage(named: "close_black"), for: .normal)
        self.closeButton.setImage(UIImage(named: "close_black"), for: .highlighted)
        self.closeButton.addTarget(self, action: #selector(self.closeButtonClick), for: .touchUpInside)
        operateView.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.width.equalTo(44)
            make.top.equalTo(0)
            make.height.equalTo(44)
        }
        
        self.commenButton = UIImageView()
        self.commenButton.image = UIImage(named: "comment_black")
        operateView.addSubview(self.commenButton)
        self.commenButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.width.equalTo(44)
            make.top.equalTo(0)
            make.height.equalTo(44)
        }
        self.commentCountLabel = UILabel()
        operateView.addSubview(self.commentCountLabel)
        self.commentCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(50)
            make.centerY.equalTo(self.commenButton).offset(0)
        }
        self.commentCountLabel.textColor = YCStyleColor.black
        self.commentCountLabel.font = UIFont.systemFont(ofSize: 16)
        self.commentCountLabel.text = "12442"
        
        self.headerLine = UIView()
        operateView.addSubview(self.headerLine)
        self.headerLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(1)
        }
        self.headerLine.backgroundColor = YCStyleColor.grayWhite
    }
    
    func initBottomView() {
        self.commentView = UIView()
        self.view.addSubview(self.commentView)
        self.commentView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(self.bottomHeight)
        }
        self.commentView.backgroundColor = YCStyleColor.white
        
        let commentTap = UITapGestureRecognizer(target: self, action: #selector(self.commentTapHandler))
        self.commentView.isUserInteractionEnabled = true
        self.commentView.addGestureRecognizer(commentTap)
        
        self.commentBordView = UIView()
        self.commentView.addSubview(self.commentBordView)
        self.commentBordView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(35)
            make.top.equalTo(7)
        }
        self.commentBordView.layer.borderWidth = 1
        self.commentBordView.layer.cornerRadius = 16
        
        self.commentViewLine = UIView()
        self.commentView.addSubview(self.commentViewLine)
        self.commentViewLine.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(1)
        }
        
        self.commentLabel = UILabel();
        self.commentView.addSubview(self.commentLabel)
        self.commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(30)
            make.centerY.equalTo(self.commentBordView).offset(0)
        }
        self.commentLabel.textColor = YCStyleColor.gray
        self.commentLabel.font = UIFont.systemFont(ofSize: 16)
        self.commentLabel.text = YCLanguageHelper.getString(key: "EnterCommentLabel")
    }
    
}


extension YCCommentListViewController: YCLoginProtocol {
    
    func refreshPage() {
        if self.listType == .Publish, let publish = self.publishModel {
            self.loadingView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self.view).offset(0)
                make.top.equalTo(headerHeight+15)
            }
            self.loadingView.startAnimating()
            YCCommentDomain().publishCommentList(publishID: publish.publishID, start: 0, count: self.refreshCount) { (modelList) in
                self.refreshPageCompleteHandler(modelList: modelList)
            }
        }else if self.listType == .Theme, let theme = self.themeModel {
            self.loadingView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self.view).offset(0)
                make.top.equalTo(headerHeight+15)
            }
            self.loadingView.startAnimating()
            YCCommentDomain().themeCommentList(themeID: theme.themeID, start: 0, count: self.refreshCount) { (modelList) in
                 self.refreshPageCompleteHandler(modelList: modelList)
            }
        }
    }
    
    @objc func footerRefresh() {
        if self.listType == .Publish, let publish = self.publishModel {
            YCCommentDomain().publishCommentList(publishID: publish.publishID, start: self.commentes.count, count: self.refreshCount) { (modelList) in
                self.footerRefreshCompleteHandler(modelList: modelList)
            }
        }else if self.listType == .Theme, let theme = self.themeModel {
            YCCommentDomain().themeCommentList(themeID: theme.themeID, start: self.commentes.count, count: self.refreshCount) { (modelList) in
                self.footerRefreshCompleteHandler(modelList: modelList)
            }
        }
    }
    
    func refreshPageCompleteHandler(modelList: YCDomainListModel?) {
        if let list = modelList {
            if list.result{
                let total = list.totoal
                if let modelList = list.modelArray{
                    self.commentes.removeAll()
                    self.viewCommentes.removeAll()
                    if self.updatePublishDate(modelList: modelList) {
                        self.tableView.reloadData()
                    }
                    if modelList.count == 0 || modelList.count < self.refreshCount {
                        self.footerFresh.endRefreshingWithNoMoreData()
                        self.footerFresh.isHidden = true
                    }else{
                        self.footerFresh.resetNoMoreData()
                        self.footerFresh.isHidden = false
                    }
                }
                self.loadingView.stopAnimating()
                switch self.listType {
                case .Publish:
                    if self.publishModel != nil {
                        self.publishModel!.commentCount = total
                        let commentCount = self.publishModel!.commentCount
                        self.commentCountLabel.text = "\(commentCount)"
                    }else {
                        self.commentCountLabel.text = "\(total)"
                    }
                    break;
                case .Theme:
                    if self.themeModel != nil {
                        
                    }
                    break;
                case .User:
                    if self.userModel != nil {
                        
                    }
                    break
                }
            }else {
                self.loadingView.stopAnimating()
                self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "WifiErrorShortMessage"), view: self, completionBlock: {
                })
            }
        }else {
            self.loadingView.stopAnimating()
        }
    }
    
    func footerRefreshCompleteHandler(modelList: YCDomainListModel?){
        if let list = modelList {
            if list.result{
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
                self.showTempAlert("", alertMessage: YCLanguageHelper.getString(key: "WifiErrorShortMessage"), view: self, completionBlock: {
                })
            }
        }else {
            self.footerFresh.endRefreshing()
        }
    }
    
    func updatePublishDate(modelList: Array<YCBaseModel>) -> Bool{
        var isChange = false
        for model in modelList {
            if let comment = model as? YCCommentModel {
                var isHave = false
                for oldComment in self.commentes {
                    if oldComment.commentID == comment.commentID {
                        isHave = true
                        break
                    }
                }
                if !isHave {
                    self.commentes.append(comment)
                    isChange = true
                }
            }
        }
        if isChange {
            self.updatCommentsView()
        }
        return isChange
    }
    
    func updatCommentsView() {
        self.viewCommentes.removeAll()
        for comment in self.commentes {
            self.viewCommentes.append(comment)
            if comment.replyCount > 0 {
                let replyList = comment.replyList
                for reply in replyList {
                    self.viewCommentes.append(reply)
                }
                if comment.listCount < comment.replyCount {
                    let moreComment = YCCommentModel(comment.commentID, commentType: -1, replyCount: comment.replyCount, listCount: comment.listCount)
                    self.viewCommentes.append(moreComment)
                }
            }
        }
    }
    
    @objc func closeButtonClick() {
        self.closeViewHandler()
    }
    
    @objc func viewTapHandler() {
        self.closeViewHandler()
    }
    
    @objc func commentTapHandler() {
        self.showLoginView(view: self, noNeedShowBlock: {
            self.showCommentView(cell: nil)
        }) {
            self.showCommentView(cell: nil)
        }
    }
    
    func showCommentView(cell: YCCommentListViewCell?) {
        if let ce = cell, let index = self.tableView.indexPath(for: ce), let comment = ce.commentModel{
            let oldOffY = self.tableView.contentOffset.y
            var commStyle: YCCommentViewStyle = .Default
            if self.listStyle == .Dark {
                commStyle = .Dark
            }
            let commentView = YCCommentViewController(style: commStyle, keyboardWillShow: { (_, h) in
                let rect = self.tableView.rectForRow(at: index)
        
                let offY = YCScreen.bounds.height - self.commentBgTop - CGFloat(self.headerHeight) - (rect.height + CGFloat(h) - 2)
                var newY = rect.origin.y - offY
                if newY < 0 {
                    newY = 0
                }
                self.tableView.contentOffset.y = newY
            }, complete: { (content) in
                let contentH = self.tableView.contentSize.height
                let offY = self.tableView.contentOffset.y
                let tableH = YCScreen.bounds.height - (self.commentBgTop+CGFloat(self.headerHeight)+self.bottomHeight)
                if (offY+tableH) > contentH {
                    self.tableView.contentOffset.y = oldOffY
                }
                if content != "" {
                    YCCommentDomain().replyComment(commnetID: comment.commentID, content: content, completionBlock: { (modelMode) in
                        if let model = modelMode, model.result{
                            if model.result, let comment = model.baseModel as? YCCommentModel {
                                self.commentComplete(comment: comment)
                            }
                        }
                    })
                }
            })
            let userName = self.getNicknameString(user: comment.user)
            commentView.plcaeholderText = YCLanguageHelper.getString(key: "ReplyLabel") + userName+":"
            self.present(commentView, animated: true, completion: {

            })
        }else {
            let commentView = YCCommentViewController(style: .Default, keyboardWillShow: nil) { (content) in
                if content != "" {
                    if self.listType == .Publish, let publish = self.publishModel {
                        YCCommentDomain().commentPublish(publishID: publish.publishID, content: content, contentImages: nil, completionBlock: { (modelMode) in
                            if let model = modelMode, model.result{
                                if model.result, let comment = model.baseModel as? YCCommentModel {
                                    self.commentComplete(comment: comment)
                                }
                            }
                        })
                    }else if self.listType == .Theme, let theme = self.themeModel {
                        YCCommentDomain().commentTheme(themeID: theme.themeID, content: content, contentImages: nil, completionBlock: { (modelMode) in
                            if let model = modelMode, model.result{
                                if model.result, let comment = model.baseModel as? YCCommentModel {
                                    self.commentComplete(comment: comment)
                                }
                            }
                        })
                    }
                }
            }
            self.present(commentView, animated: true, completion: {
                
            })
        }
    }
    
    func commentComplete(comment: YCCommentModel) {
        if comment.commentType == 0 {
            self.commentes.insert(comment, at: 0)
        }else if comment.commentType == 1{
            let beCommentedID = comment.beCommentedID
            for oldComment in self.commentes {
                if oldComment.commentID == beCommentedID {
                    oldComment.replyList.insert(comment, at: 0)
                    oldComment.replyCount = oldComment.replyCount + 1
                    oldComment.listCount = oldComment.listCount + 1
                }
            }
        }
        self.updatCommentsView()
        self.tableView.reloadData()
        switch self.listType {
        case .Publish:
            if self.publishModel != nil {
                self.publishModel!.commentCount = self.publishModel!.commentCount + 1
                let commentCount = self.publishModel!.commentCount
                self.commentCountLabel.text = "\(commentCount)"
            }
            break;
        case .Theme:
            if self.themeModel != nil {
                
            }
            break;
        case .User:
            if self.userModel != nil {
                
            }
            break
        }
    }
    
    func resetViewController() {
        self.isFirstLoad = true
        self.commentes.removeAll()
        self.viewCommentes.removeAll()
        self.tableView.reloadData()
        self.footerFresh.isHidden = true
        self.commentCountLabel.text = ""
        self.publishModel = nil
        self.themeModel = nil
        self.userModel = nil
        self.listType = .Publish
        self.listStyle = .Default
        self.completeBlock = nil
    }
    
    func closeViewHandler() {
        if let ng = self.navigationController {
            ng.dismiss(animated: true) {
                if let complete = self.completeBlock {
                    switch self.listType{
                    case .Publish:
                        complete(self.publishModel)
                        break
                    case .Theme:
                        complete(self.themeModel)
                        break
                    case .User:
                        complete(self.userModel)
                        break
                    }
                }
                self.resetViewController()
                YCCommentListViewController.addInstance(instace: self)
            }
        }
    }
    
    
}

extension YCCommentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewCommentes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:YCCommentListViewCell = self.tableView.dequeueReusableCell(withIdentifier: "YCCommentListCell", for: indexPath) as! YCCommentListViewCell
        let row = indexPath.item
        let commentModel = self.viewCommentes[row]
        if self.listStyle == .Default {
            cell.style = .Default
        }else if self.listStyle == .Dark {
            cell.style = .Dark
        }
        cell.isHidden = false
        cell.delegate = self
        cell.commentModel = commentModel
        return cell
    }
}

extension YCCommentListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}


extension YCCommentListViewController: YCCommentListViewCellDelegate {
    
    func cellUserTap(_ cell: YCCommentListViewCell?) {
        if let cell = cell, let comment = cell.commentModel {
            if let user = comment.user {
                self.goUser(user)
            }
        }
    }
    
    func cellContentTap(_ cell: YCCommentListViewCell?) {
        if let ce = cell, let comment = ce.commentModel {
            if comment.commentType == -1 {
                ce.isHidden = true
                if let index = self.tableView.indexPath(for: ce) {
                    let rect = self.tableView.rectForRow(at: index)
                    let offY = self.tableView.contentOffset.y
                    let space = rect.origin.y - offY + 5
                    self.loadingView.snp.remakeConstraints { (make) in
                        make.centerX.equalTo(self.view).offset(0)
                        make.top.equalTo(CGFloat(headerHeight) + space)
                    }
                    self.loadingView.startAnimating()
                    YCCommentDomain().replyList(commentID: comment.commentID, start: comment.listCount, count: self.replyCount) { (listModel) in
                        self.loadingView.stopAnimating()
                        if let list = listModel, list.result {
                            let total = list.totoal
                            if let modelList = list.modelArray{
                                for oldComment in self.commentes {
                                    if oldComment.commentID == comment.commentID {
                                        oldComment.replyCount = total
                                        for model in modelList {
                                            if let reply = model as? YCCommentModel {
                                                var isHave = false
                                                for oldReply in oldComment.replyList {
                                                    if oldReply.commentID == reply.commentID {
                                                        isHave = true
                                                        break
                                                    }
                                                }
                                                if !isHave {
                                                    oldComment.replyList.append(reply)
                                                }
                                            }
                                        }
                                        oldComment.listCount = oldComment.replyList.count
                                        break
                                    }
                                }
                                self.updatCommentsView()
                                self.tableView.reloadData()
                            }else {
                                ce.isHidden = false
                            }
                        }else {
                            ce.isHidden = false
                        }
                    }
                }
            }else {
                self.showLoginView(view: self, noNeedShowBlock: {
                    if let user = YCUserManager.loginUser, let commentUser = comment.user {
                        if user.userID == commentUser.userID{
                            self.showDeleteCommentView(cell: cell)
                        }else {
                            self.showCommentView(cell: cell)
                        }
                    }else {
                        self.showCommentView(cell: cell)
                    }
                }) {
                    if let user = YCUserManager.loginUser, let commentUser = comment.user {
                        if user.userID == commentUser.userID{
                            self.showDeleteCommentView(cell: cell)
                        }else {
                            self.showCommentView(cell: cell)
                        }
                    }else {
                        self.showCommentView(cell: cell)
                    }
                }
            }
        }
        
    }
    
    func showDeleteCommentView(cell: YCCommentListViewCell?) {
        if let ce = cell, let comment = ce.commentModel {
            var alertArray:Array<[String : Any]> = []
            alertArray.append(["title":YCLanguageHelper.getString(key: "DeleteLabel"), "textColor":YCStyleColor.red])
            self.showSheetAlert("", alertMessage: YCLanguageHelper.getString(key: "DeleteCommentTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                if index == 0 {
                    YCCommentDomain().removeComment(commentID: comment.commentID, completionBlock: { (resultMode) in
                        if let result = resultMode, result.result {
                            var changeCommentID = ""
                            if comment.commentType == 0 {
                                changeCommentID = comment.commentID
                            }else if comment.commentType == 1 {
                                changeCommentID = comment.beCommentedID
                            }
                            for (i,oldComment) in self.commentes.enumerated() {
                                if oldComment.commentID == changeCommentID {
                                    if comment.commentType == 0 {
                                        self.commentes.remove(at: i)
                                    }else if comment.commentType == 1 {
                                        let replyList = oldComment.replyList
                                        for (j, reply) in replyList.enumerated() {
                                            if reply.commentID == comment.commentID {
                                                oldComment.replyList.remove(at: j)
                                                break
                                            }
                                        }
                                    }
                                    break
                                }
                            }
                            self.updatCommentsView()
                            if let index = self.tableView.indexPath(for: ce) {
                                self.tableView.deleteRows(at: [index], with: .fade)
                            }
                            switch self.listType {
                            case .Publish:
                                if self.publishModel != nil {
                                    self.publishModel!.commentCount = self.publishModel!.commentCount - 1
                                    if self.publishModel!.commentCount < 0 {
                                        self.publishModel!.commentCount = 0
                                    }
                                    let commentCount = self.publishModel!.commentCount
                                    self.commentCountLabel.text = "\(commentCount)"
                                }
                                break;
                            case .Theme:
                                if self.themeModel != nil {
                                    
                                }
                                break;
                            case .User:
                                if self.userModel != nil {
                                    
                                }
                                break
                            }
                        }
                    })
                }else if index == -1 {
                    
                }
            }
        }
        
    }
    
    func cellLikeButtonClick(_ cell: YCCommentListViewCell?) {
        self.showLoginView(view: self, noNeedShowBlock: {
            if let cell = cell, let comment = cell.commentModel {
                if comment.isLike == 0 {
                    self.likeCommentHandler(comment, commentCell: cell)
                }else {
                    self.unLikeCommentHandler(comment, commentCell: cell)
                }
            }
        }) {
            if let cell = cell, let comment = cell.commentModel {
                if comment.isLike == 0 {
                    self.likeCommentHandler(comment, commentCell: cell)
                }
            }
        }
    }
    
    func goUser(_ user: YCUserModel) {
        let userProfile = YCUserViewController.getInstance()
        userProfile.userModel = user
        if let nav = self.navigationController {
            nav.pushViewController(userProfile, animated: true)
        }
    }
    
    func likeCommentHandler(_ comment: YCCommentModel, commentCell: YCCommentListViewCell?) {
        if comment.isLike == 0 {
            comment.isLike = 1
            comment.likeCount = comment.likeCount + 1
            YCLikeDomain().likeComment(commentID: comment.commentID) { (result) in
                if let re = result, re.result {
                    comment.isLike = 1
                    self.updateComment(comment: comment)
                }
            }
            if let cell = commentCell {
                cell.changeCommentLikeStatus(comment: comment)
            }
        }
    }
    
    func unLikeCommentHandler(_ comment: YCCommentModel, commentCell: YCCommentListViewCell?) {
        if comment.isLike == 1 {
            comment.isLike = 0
            comment.likeCount = comment.likeCount - 1
            if comment.likeCount < 0 {
                comment.likeCount = 0
            }
            YCLikeDomain().unLikeComment(commentID: comment.commentID) { (result) in
                if let re = result, re.result {
                    comment.isLike = 0
                    self.updateComment(comment: comment)
                }
            }
            if let cell = commentCell {
                cell.changeCommentLikeStatus(comment: comment)
            }
        }
    }
    
    func updateComment(comment: YCCommentModel) {
        for oldComment in self.viewCommentes {
            if oldComment.commentID == comment.commentID {
                oldComment.isLike = comment.isLike
                oldComment.likeCount = comment.likeCount
                break
            }
        }
        if comment.commentType == 0 {
            for oldComment in self.commentes {
                if oldComment.commentID == comment.commentID {
                    oldComment.isLike = comment.isLike
                    oldComment.likeCount = comment.likeCount
                    break
                }
            }
        }else if comment.commentType == 1 {
            let beCommentedID = comment.beCommentedID
            for oldComment in self.commentes {
                if oldComment.commentID == beCommentedID {
                    let replyList = oldComment.replyList
                    for reply in replyList {
                        if reply.commentID == comment.commentID {
                            reply.isLike = comment.isLike
                            reply.likeCount = comment.likeCount
                            break
                        }
                    }
                    break
                }
            }
        }
    }
}
