//
//  PublishDetailViewController.swift
//  YouCat
//
//  Created by ting on 2018/10/27.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
import MJRefresh
import SnapKit
import AVKit

enum YCPublishDetailType: String{
    case HOME = "home"
    case THEME = "theme"
    case POST = "post"
    case LIKE = "like"
}

class YCPublishDetailViewController: YCViewController {

    static var _instanceArray: [YCPublishDetailViewController] = [];
    
    override class func getInstance() -> YCViewController{
        var _instance: YCViewController
        if _instanceArray.count > 0 {
            _instance = _instanceArray[0]
            _instanceArray.remove(at: 0)
            _instance.initViewController()
            return _instance
        }else {
            _instance = YCPublishDetailViewController()
        }
        return _instance
    }
    
    override class func addInstance(_ instance: YCViewController) {
        if let ins = instance as? YCPublishDetailViewController {
            _instanceArray.append(ins)
        }
    }
    
    var isPresent = false

    var videoMedias: [YCMediaViewModel] = []
    
    let refreshCount = 20
    var isFirstShow: Bool = true
    
    var contentType: YCPublishDetailType = .HOME
    var contents: [YCPublishModel]?
    var contentIndex: Int = 0
    var contentID: String?
    var contentValue: [String: Any]?
    
    var contentModel: YCPublishModel?
    var contentIndexPath: IndexPath?
    
    var collectionView: UICollectionView!
    var collectionLayout: YCCollectionViewWaterfallLayout!
    
    var isLoading = false
    var loadingView: YCLoadingView!
    var loadResourceIndex = -1
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        super.viewWillAppear(animated)
        if self.isFirstShow {
            self.showView()
        }
        if let closeButton = self.view.viewWithTag(11) as? UIButton {
            if self.isPresent {
                closeButton.setImage(UIImage(named: "close_white"), for: .normal)
                closeButton.setImage(UIImage(named: "close_white"), for: .highlighted)
            }else {
                closeButton.setImage(UIImage(named: "back_white"), for: .normal)
                closeButton.setImage(UIImage(named: "back_white"), for: .highlighted)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let index = self.contentIndexPath {
            self.setCurrentCell(indexPath: index)
        }else {
            self.setCurrentCell(indexPath: IndexPath(item: 0, section: 0))
        }
        if self.isFirstShow {
            if self.contentType == .HOME {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.7) {
                    self.footerRefresh()
                }
            }
        }else {
            if let index = self.contentIndexPath, let currentCell = self.collectionView.cellForItem(at: index) as? YCPublishDetailViewCell{
                currentCell.displayView()
            }
        }
        self.isFirstShow = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        for _ in 0..<10 {
            self.videoMedias.append(YCMediaViewModel(publishID: ""))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.followUserChange(_:)), name: NSNotification.Name("FollowUser"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.unFollowUserChange(_:)), name: NSNotification.Name("UnFollowUser"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let cells = self.collectionView.visibleCells
        for cell in cells {
            if let contentCell = cell as? YCPublishDetailViewCell{
                contentCell.displayPause()
            }
        }
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        self.view.backgroundColor = YCStyleColor.black
        
        self.initCollectionView()
        self.initOperateButton()
        
        self.loadingView = YCLoadingView(style: .POP)
        self.view.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { (make) in
             make.center.equalTo(self.view).offset(0)
        }
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func hideLoadingView() {
        self.view.isUserInteractionEnabled = true
        self.loadingView.stopAnimating()
    }
    
    func showLoadingView() {
        self.view.isUserInteractionEnabled = false
        self.loadingView.startAnimating()
    }

    func initOperateButton() {
        let closeButton=UIButton()
        closeButton.setImage(UIImage(named: "back_white"), for: .normal)
        closeButton.setImage(UIImage(named: "back_white"), for: .highlighted)
        closeButton.addTarget(self, action: #selector(self.closeButtonClick), for: .touchUpInside)
        closeButton.tag = 11
        self.view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(YCScreen.safeArea.top)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
        
        let operatorButton = UIButton()
        operatorButton.setImage(UIImage(named: "operate_white"), for: .normal)
        operatorButton.setImage(UIImage(named: "operate_white"), for: .highlighted)
        operatorButton.addTarget(self, action: #selector(self.operateButtonClick), for: .touchUpInside)
        self.view.addSubview(operatorButton)
        operatorButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.top.equalTo(YCScreen.safeArea.top)
            make.width.equalTo(44)
            make.height.equalTo(44)
        }
    }
    
    func initCollectionView(){
        let bounds = YCScreen.bounds
        let rect:CGRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.collectionLayout = YCCollectionViewWaterfallLayout()
        self.collectionLayout.minimumLineSpacing = 0
        self.collectionLayout.minimumInteritemSpacing = 0
        self.collectionLayout.columnCount = 1
        self.collectionLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        self.collectionLayout.footerReferenceSize = CGSize(width: bounds.width, height: 44)
        
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
        self.collectionView.register(YCPublishDetailViewCell.self, forCellWithReuseIdentifier: "YCPublishDetailCell")
//        self.collectionView.register(YCCollectionFooterView.self, forSupplementaryViewOfKind: YCCollectionViewWaterfallSectionFooter, withReuseIdentifier: "YCPublishDetailFooterView")
       
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.scrollsToTop = false
        self.collectionView.backgroundColor = YCStyleColor.black
    }
    
    func showView(){
        let bounds = YCScreen.bounds
        if let content = self.contentModel, let contents = self.contents {
            var publishIndex = 0
            for (index, item) in contents.enumerated() {
                if item.publishID == content.publishID {
                    publishIndex = index
                    break
                }
            }
            var rect = self.collectionView.frame
            rect.origin.y = CGFloat(publishIndex)*bounds.height
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.collectionView.scrollRectToVisible(rect, animated: false)
            self.contentIndexPath = IndexPath(item: publishIndex, section: 0)
        }
    }
    
    @objc func closeButtonClick(){
        self.viewCloseHander()
    }
    
    @objc func operateButtonClick(){
        var alertArray:Array<[String : Any]> = []
        //        alertArray.append(["title":YCLanguageHelper.getString(key: "ContentLinkLabel")])
        alertArray.append(["title":YCLanguageHelper.getString(key: "ReportLabel"), "textColor":YCStyleColor.red])
        self.showSheetAlert(nil, alertMessage: nil, okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
            if index == 0, let index = self.contentIndexPath, let cell = self.collectionView.cellForItem(at: index) as? YCPublishDetailViewCell {
                self.reportHandler(cell)
            }
        }
    }
    
    func footerRefresh() {
        if let ID = self.contentID, let contents = self.contents, !self.isLoading {
            self.isLoading = true
            if self.contentType == .THEME {
                var themeType = 0;
                if let contentValue = self.contentValue {
                    themeType = contentValue["ThemeType"] as! Int
                }
                YCPublishDomain().themePublishList(themeID: ID, type: themeType, start: contents.count, count: self.refreshCount, completionBlock: { (list) in
                    self.footerFreshEnd(list)
                })
            }else if self.contentType == .POST {
                YCPublishDomain().userPublishList(userID: ID, start: contents.count, count: self.refreshCount, completionBlock: { (list) in
                    self.footerFreshEnd(list)
                })
            }else if self.contentType == .LIKE {
                YCPublishDomain().userLikePublishList(userID: ID, start: contents.count, count: self.refreshCount, completionBlock: { (list) in
                    self.footerFreshEnd(list)
                })
            }else if self.contentType == .HOME {
                let start = contents.count - 1
                YCPublishDomain().publishMoreList(publishID: ID, start: start, count: self.refreshCount, completionBlock: { (list) in
                    self.footerFreshEnd(list)
                })
            }else {
                self.isLoading = false
            }
        }
    }
    
    func footerFreshEnd(_ modelList: YCDomainListModel?) {
        if let list = modelList, list.result{
            if let modelList = list.modelArray {
                if self.updatePublishDate(modelList: modelList) {
                    self.collectionView.reloadData()
                }
//                if modelList.count == 0 {
//                    self.footerFresh.endRefreshingWithNoMoreData()
//                }else{
//                    self.footerFresh.endRefreshing()
//                }
                
            }else {
                //self.footerFresh.endRefreshing()
            }
        }else {
            //self.footerFresh.endRefreshing()
        }
        self.isLoading = false
    }
    
    func updatePublishDate(modelList: Array<YCBaseModel>) -> Bool{
        var isChange = false
        if let _ = self.contents {
            for model in modelList {
                if let publish = model as? YCPublishModel {
                    var isHave = false
                    for oldPublish in self.contents! {
                        if oldPublish.publishID == publish.publishID {
                            isHave = true
                            break
                        }
                    }
                    if !isHave {
                        self.contents!.append(publish)
                        isChange = true
                    }
                }
            }
        }
        if isChange, let index = self.contentIndexPath {
            self.loadResourceIndex = -1
            let _ = self.loadCurrentMediaResouse(mediaIndex: index.item)
        }
        return isChange
    }
    
    override func resetViewController() {
        super.resetViewController()
        print("reset View")
        self.resetCollectionViewCell()
        self.contentModel = nil
        self.contentIndexPath = nil
        self.contentType = .HOME
        self.contents = nil
        self.contentID = nil
        self.contentValue = nil
        self.contentIndex = 0
        self.collectionView.reloadData()
        self.isFirstShow = true
        self.loadResourceIndex = -1
        self.isPresent = false
        for mediaModel in self.videoMedias.filter({$0.unUsed == false}) {
            self.releaseMediaViewModel(mediaModel: mediaModel)
        }
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name("FollowUser"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UnFollowUser"), object: nil)
//        self.videoMedias.removeAll()
    }
}

extension YCPublishDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if let contents = self.contents {
            return contents.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let displayCell = cell as? YCPublishDetailViewCell, let nowIndex = self.contentIndexPath, nowIndex.item == indexPath.item {
            displayCell.displayView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let removeCell = cell as? YCPublishDetailViewCell {
            removeCell.disPlayViewEnd()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let footerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: YCCollectionViewWaterfallSectionFooter, withReuseIdentifier: "YCPublishDetailFooterView", for: indexPath)
//        footerView.backgroundColor = YCStyleColor.red
//        footerView.addSubview(self.loadingView)
//        self.loadingView.snp.makeConstraints { (make) in
//            make.center.equalTo(footerView).offset(0)
//        }
//        self.loadingView.startAnimating()
//        return footerView
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:YCPublishDetailViewCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "YCPublishDetailCell", for: indexPath) as! YCPublishDetailViewCell
        if let contents = self.contents {
            cell.delegate = self
            let row = indexPath.item
            let publishModel = contents[row]
            cell.publishModel = publishModel
            if let content = self.contentModel, content.publishID == publishModel.publishID {
                cell.willDisplayView(contentIndex: self.contentIndex)
                self.contentIndex = -1
            }else {
                cell.willDisplayView(contentIndex: -1)
            }
            self.resolvePopGesture(scrollView: cell.contentScrollView)
        }
        return cell
    }
}

extension YCPublishDetailViewController: YCCollectionViewWaterfallLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        if let contents = self.contents {
            let row = indexPath.item
            if row < contents.count && row > -1 {
                let size = CGSize(width: YCScreen.bounds.width, height: YCScreen.bounds.height)
                return size
            }
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if(scrollView == self.collectionView){
//            let cells = self.collectionView.visibleCells
//            for cell in cells {
//                if let contentCell = cell as? YCPublishDetailViewCell{
//                    contentCell.displayPause()
//                }
//            }
//        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if(scrollView == self.collectionView){
            self.scrollDidEnd()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if(scrollView == self.collectionView){
            self.scrollDidEnd()
        }
    }
    
    func scrollDidEnd(){
        let contentH = YCScreen.bounds.height
        let offset = self.collectionView.contentOffset
        let index = Int(offset.y / contentH)
        let indexPath = IndexPath(item: index, section: 0)
        self.setCurrentCell(indexPath: indexPath)
        
        var rect = self.collectionView.frame
        rect.origin.y = CGFloat(index)*rect.height
        self.collectionView.scrollRectToVisible(rect, animated: false)
        
        if let contents = self.contents {
            if index > contents.count - 3 {
                self.footerRefresh()
            }
        }
    }
    
    func setCurrentCell(indexPath: IndexPath) {
        var needChange = false
        if let contentIndex = self.contentIndexPath {
            if contentIndex.item != indexPath.item {
                needChange = true
            }
        }else {
            needChange = true
        }
        if needChange, let contents = self.contents {
            if let contentIndex = self.contentIndexPath, let preCell = self.collectionView.cellForItem(at: contentIndex) as? YCPublishDetailViewCell {
                preCell.disPlayViewEnd()
            }
            let row = indexPath.item
            self.contentModel = contents[row]
            self.contentIndexPath = indexPath
        }
        if let index = self.contentIndexPath, let currentCell = self.collectionView.cellForItem(at: index) as? YCPublishDetailViewCell{
            currentCell.displayView()
        }
    }
    
    func loadCurrentMediaResouse(mediaIndex: Int) -> YCMediaViewModel? {
        if let contents = self.contents, mediaIndex > -1, mediaIndex < contents.count, self.loadResourceIndex !=  mediaIndex{
            self.loadResourceIndex = mediaIndex
            let top = min(mediaIndex, 3)
            let bottom = min((contents.count - 1) - mediaIndex, 3)
            let start = mediaIndex - top
            let end = mediaIndex + bottom
            let subContents = contents[start...end]
            for mediaView in self.videoMedias.filter({$0.unUsed == false}) {
                var isHave = false
                for subContent in subContents {
                    if mediaView.publishID == subContent.publishID{
                        isHave = true
                        break
                    }
                }
                if !isHave {
                    self.releaseMediaViewModel(mediaModel: mediaView)
                }
            }
            let currentContent = contents[mediaIndex]
            let currentViewModel = self.loadPublishModeMedia(currentContent)
            let loadContents = subContents.filter({$0.publishID != currentContent.publishID})
            var waitingLoad = false
            if let current = currentViewModel {
                if let currentPlayItem = current.videoPlayerItem {
                    if currentPlayItem.status == .readyToPlay || currentPlayItem.status == .failed {
                        waitingLoad = false
                    }else {
                        waitingLoad = true
                    }
                }else {
                    waitingLoad = false
                }
            }else {
                waitingLoad = false
            }
            if !waitingLoad {
                for subContent in loadContents {
                    let _ = self.loadPublishModeMedia(subContent)
                }
            }else {
                DispatchQueue.global().async {
                    print("waiting begin")
                    var waiting = true
                    while waiting {
                        if let contentIndex = self.contentIndexPath, contentIndex.item == mediaIndex {
                            if let currentPlayItem = currentViewModel?.videoPlayerItem{
                                if currentPlayItem.status == .readyToPlay {
                                    waiting = false
                                    for subContent in loadContents {
                                        let _ = self.loadPublishModeMedia(subContent)
                                    }
                                }else if currentPlayItem.status == .failed {
                                    waiting = false
                                }else {
                                    waiting = true
                                }
                            }else {
                                waiting = false
                            }
                        }else {
                            waiting = false
                        }
                    }
                    print("waiting finish")
                }
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//                    if let contentIndex = self.contentIndexPath, contentIndex.item == mediaIndex {
//                        for subContent in loadContents {
//                            let _ = self.loadPublishModeMedia(subContent)
//                        }
//                    }
//                }
            }
            return currentViewModel;
        }
        return nil
    }
    
    func loadPublishModeMedia(_ publish: YCPublishModel) -> YCMediaViewModel?  {
        if publish.contentType == 2 {
            for mediaView in self.videoMedias {
                if mediaView.publishID == publish.publishID {
                    return mediaView
                }
            }
            if publish.medias.count > 0, let videoModel = publish.medias[0] as? YCVideoModel,
                let videoURL = URL(string: videoModel.videoPath) {
                return self.initMediaViewModel(publishID: publish.publishID, videoURL: videoURL)
            }
        }
        return nil
    }
    
    func releaseMediaViewModel(mediaModel: YCMediaViewModel){
        if !mediaModel.unUsed {
            if let playerItem = mediaModel.videoPlayerItem {
                playerItem.cancelPendingSeeks()
                playerItem.asset.cancelLoading()
                playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
                playerItem.removeObserver(self, forKeyPath: "status")
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            }
            mediaModel.videoPlayerItem = nil
            mediaModel.videoPlayer = nil
            mediaModel.videoPlayComplete = nil
            mediaModel.videoStatusChange = nil
            mediaModel.publishID = ""
            mediaModel.unUsed = true
        }
    }
    
    func initMediaViewModel(publishID: String, videoURL: URL) -> YCMediaViewModel? {
        let freeMedias = self.videoMedias.filter{$0.unUsed == true}
        if freeMedias.count > 0{
            let mediaModel = freeMedias[0]
            let playerItem = AVPlayerItem(url: videoURL)
            mediaModel.publishID = publishID
            if let player = mediaModel.videoPlayer {
                player.replaceCurrentItem(with: playerItem)
            }else {
                mediaModel.videoPlayer = AVPlayer(playerItem: playerItem)
            }
            playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            NotificationCenter.default.addObserver(self, selector:  #selector(self.videoDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            mediaModel.videoPlayerItem = playerItem
            mediaModel.videoPlayComplete = nil
            mediaModel.videoStatusChange = nil
            mediaModel.unUsed = false
            return mediaModel
        }
        return nil
    }
    
    @objc func videoDidPlayToEnd(_ notify: Notification) {
        if let playerItem = notify.object as? AVPlayerItem {
            let mediaModels = self.videoMedias.filter {$0.videoPlayerItem == playerItem}
            if  mediaModels.count > 0{
                let mediaModel = mediaModels[0]
                if let videoPlayComplete = mediaModel.videoPlayComplete {
                    videoPlayComplete(playerItem)
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        let mediaModels  = self.videoMedias.filter {$0.videoPlayerItem == playerItem}
        if  mediaModels.count > 0{
            let mediaModel = mediaModels[0]
            if let videoStatusChange = mediaModel.videoStatusChange {
                videoStatusChange(keyPath, playerItem)
            }
        }
    }
    
    func resetCollectionViewCell() {
        let cells = self.collectionView.visibleCells
        for cell in cells {
            if let contentCell = cell as? YCPublishDetailViewCell{
                contentCell.displayRelease()
                contentCell.publishModel = nil
            }
        }
    }
    
    func viewCloseHander() {
        if self.isPresent {
            if let nav = self.navigationController {
                nav.dismiss(animated: true, completion: nil)
            }
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension YCPublishDetailViewController: YCPublishDetailViewCellDelegate, YCLoginProtocol, YCAlertProtocol, YCContentStringProtocol, YCShareProtocol {
    
    func cellLoadCellMedia(cell: YCPublishDetailViewCell?) -> [YCMediaViewModel]?{
        if let cl = cell,  let indexPath = self.collectionView.indexPath(for: cl) {
            let _ = self.loadCurrentMediaResouse(mediaIndex: indexPath.item)
            if let current = cell?.publishModel {
                let medias = self.videoMedias.filter {$0.publishID == current.publishID}
                return medias
            }
        }
        return nil
    }
    
    func cellContentDoubleTap(_ cell: YCPublishDetailViewCell?, sender: UITapGestureRecognizer) {
        let pt = sender.location(in: self.view)
        
        let img = UIImageView(frame: CGRect(x: pt.x - 33, y: pt.y - 33, width: 66, height: 66))
        self.view.addSubview(img)
        img.image = UIImage(named: "like_high")
        
        UIView.animate(withDuration: 0.5, animations: {
            img.frame.origin.x = pt.x - 88
            img.frame.origin.y = pt.y - 88
            img.frame.size.width = 176
            img.frame.size.height = 176
            img.alpha = 0.1
        }) { (result) in
            img.removeFromSuperview()
        }
        
        if cell != nil, let publish = cell?.publishModel {
            if publish.isLike == 0 {
                self.likePublishHandler(publish, publishCell: cell)
            }
        }
    }
    
    
    func cellFollowButtonTap(_ cell: YCPublishDetailViewCell?, followBlock: (()->Void)?) {
        self.isGoto = true
        self.showLoginView(view: self, noNeedShowBlock: {
            self.isGoto = false
            self.followHandler(cell)
            if let block = followBlock {
                block()
            }
        }) {
            self.followHandler(cell)
            if let block = followBlock {
                block()
            }
        }
    }
    
    func cellCommentTap(_ cell: YCPublishDetailViewCell?) {
        self.isGoto = true
        self.showLoginView(view: self, noNeedShowBlock: {
            self.isGoto = false
            self.showCommentView(cell: cell)
        }) {
            self.showCommentView(cell: cell)
        }
    }
    
    func followHandler(_ ce: YCPublishDetailViewCell?) {
        if let cell = ce, let publish = cell.publishModel, let user = publish.user {
            YCUserDomain().followUser(userID: user.userID) { (result) in
                if let re = result, re.result {
                    NotificationCenter.default.post(name: NSNotification.Name("FollowUser"), object: user.userID)
                }
            }
        }
    }
    
    func cellShareButtonClick(_ ce: YCPublishDetailViewCell?) {
        if let cell = ce, let publish = cell.publishModel {
            cell.isFocus = true
            var publishURL = ShareURL.publish.description
            publishURL = publishURL+"?uid="+publish.uuid
            let slogon = YCLanguageHelper.getString(key: "Slogon")
            let content = self.getContentString(content: publish.content)
            if let view = cell.getCurrentView(){
                if view is YCAnimationView {
                    var alertArray:Array<[String : Any]> = []
                    alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatEmoticonLabel")])
                    self.showSheetAlert(nil, alertMessage: YCLanguageHelper.getString(key: "ShareToTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                        if index != -1 {
                            self.showLoadingView()
                            let thumbImage = view.getSnap()
                            view.getMediaData(200, 150, completionBlock: { (data) in
                                self.hideLoadingView()
                                if let da = data {
                                    if index == 0 {
                                        let shareResult = self.shareEmoticon(da, thumbImage: thumbImage, title: content, description: slogon, to: .weChat)
                                        if shareResult, let imageID = (view as! YCAnimationView).imageModel?.imageID {
                                            YCShareDomain().shareImage(imageID: imageID, platform: 2, shareType: 3, completionBlock: { (result) in
                                            })
                                        }else {
                                            self.showSingleAlert(YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall"), alertMessage: nil, view: self, compelecationBlock: nil
                                            )
                                        }
                                    }
                                }
                            })
                        }
                    }
                }else if view is YCImageView {
                    var alertArray:Array<[String : Any]> = []
                    alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatFriendLabel")])
                    alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatEmoticonLabel")])
                    alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatMomentsLabel")])
                    alertArray.append(["title":YCLanguageHelper.getString(key:
                        "WeiboLabel")])
                    alertArray.append(["title":YCLanguageHelper.getString(key:
                        "SavePhotoLabel")])
                    self.showSheetAlert(nil, alertMessage: YCLanguageHelper.getString(key: "ShareToTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                        if index != -1 && index != 4 {
                            let thumbImage = view.getSnap()
                            self.showLoadingView()
                            var dateW:Float = 1280
                            var dateH:Float = 960
                            if index == 1 {
                                dateW = 800
                                dateH = 600
                            }
                            view.getMediaData(dateW, dateH, completionBlock: { (data) in
                                self.hideLoadingView()
                                if let da = data {
                                    var platform = 0
                                    var shareType = 0
                                    var shareResult = false;
                                    var errMessage = ""
                                    if index == 0 {
                                        shareResult = self.shareImage(da, url: publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .weChat)
                                        platform = 2
                                        shareType = 2
                                        errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                                    }else if index == 1 {
                                        shareResult = self.shareEmoticon(da, thumbImage: thumbImage, title: content, description: slogon, to: .weChat)
                                        platform = 2
                                        shareType = 3
                                        errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                                    }else if index == 2 {
                                        shareResult = self.shareImage(da, url: publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .moments)
                                        platform = 3
                                        shareType = 2
                                        errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                                    }else if index == 3 {
                                        shareResult = self.shareImage(da, url: publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .weibo)
                                        platform = 1
                                        shareType = 2
                                        errMessage = YCLanguageHelper.getString(key: "ShareFailedWeiboUninstall")
                                    }
                                    if shareResult, let imageID = (view as! YCImageView).imageModel?.imageID{
                                        YCShareDomain().shareImage(imageID: imageID, platform: platform, shareType: shareType, completionBlock: { (result) in
                                        })
                                    }else {
                                        self.showSingleAlert(errMessage, alertMessage: nil, view: self, compelecationBlock: nil
                                        )
                                    }
                                }
                            })
                        }else if index == 4 {
                            if let img = (view as! YCImageView).img?.image {
                                YCPhotoAlbumUtil.saveImageInAlbum(image: img, albumName: YCLanguageHelper.getString(key: "DefaultName"), completion: { (result) in
                                    DispatchQueue.main.async {
                                        switch result{
                                        case .success:
                                             let showMessage = YCLanguageHelper.getString(key:"SavePhotoSuccessLabel")
                                             self.showTempAlert("", alertMessage: showMessage, view: self, completionBlock: nil)
                                        case .denied:
                                            gotoSetting(title: "", mesage: YCLanguageHelper.getString(key: "LibraryAccessTitle"), view: self)
                                        case .error:
                                            let showMessage = YCLanguageHelper.getString(key:
                                                "SavePhotoErrorLabel")
                                            self.showTempAlert("", alertMessage: showMessage, view: self, completionBlock: nil)
                                        }
                                    }
                                })
//                                UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.savePhoteHandler), nil)
                            }
                        }
                    }
                }else if view is YCVideoView {
                    var alertArray:Array<[String : Any]> = []
                    alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatFriendLabel")])
                    alertArray.append(["title":YCLanguageHelper.getString(key: "WeChatMomentsLabel")])
                    alertArray.append(["title":YCLanguageHelper.getString(key: "WeiboLabel")])
                    self.showSheetAlert(nil, alertMessage: YCLanguageHelper.getString(key: "ShareToTitle"), okAlertArray: alertArray, cancelAlertLabel: YCLanguageHelper.getString(key: "CancelLabel"), view: self) { (index) in
                        if index != -1 {
                            let thumbImage = view.getSnap()
                            var platform = 0
                            var shareResult = false;
                            var errMessage = ""
                            if index == 0 {
                                shareResult = self.shareURL(publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .weChat)
                                platform = 2
                                errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                            }else if index == 1 {
                                shareResult = self.shareURL(publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .moments)
                                platform = 3
                                errMessage = YCLanguageHelper.getString(key: "ShareFailedWeChatUninstall")
                            }else if index == 2 {
                                shareResult = self.shareURL(publishURL, title: content, description: slogon, thumbImage: thumbImage, to: .weibo)
                                platform = 1
                                errMessage = YCLanguageHelper.getString(key: "ShareFailedWeiboUninstall")
                            }
                            if shareResult, let videoID = (view as! YCVideoView).videoModel?.videoID {
                                YCShareDomain().shareVideo(videoID: videoID, platform: platform, shareType: 1, completionBlock: { (result) in
                                })
                            }else {
                                self.showSingleAlert(errMessage, alertMessage: nil, view: self, compelecationBlock: nil
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    func cellLikeButtonClick(_ cell: YCPublishDetailViewCell?) {
        self.isGoto = true
        self.showLoginView(view: self, noNeedShowBlock: {
            self.isGoto = false
            if cell != nil, let publish = cell?.publishModel {
                if publish.isLike == 0 {
                    self.likePublishHandler(publish, publishCell: cell)
                }else {
                    self.unLikePublishHandler(publish, publishCell: cell)
                }
            }
        }) {
            if cell != nil, let publish = cell?.publishModel {
                if publish.isLike == 0 {
                    self.likePublishHandler(publish, publishCell: cell)
                }
            }
        }
    }
    
    func cellCommentButtonClick(_ cell: YCPublishDetailViewCell?) {
        if let ce = cell, let publish = ce.publishModel {
            let commentList = YCCommentListViewController.getInstance(.Publish, style: .Dark, completeBlock: { (model) in
                if let publishModel = model as? YCPublishModel {
                    ce.changePublishCommentStatus(publish: publishModel)
                }
            }, pushBlock: {
                if let index = self.contentIndexPath, let currentCell = self.collectionView.cellForItem(at: index) as? YCPublishDetailViewCell{
                    currentCell.displayPause()
                }
            }) {
                if let index = self.contentIndexPath, let currentCell = self.collectionView.cellForItem(at: index) as? YCPublishDetailViewCell{
                    currentCell.displayView()
                }
            }
            commentList.publishModel = publish
            let navigationController = UINavigationController(rootViewController: commentList)
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.view.backgroundColor = UIColor.clear
            self.present(navigationController, animated: true) {
                
            }
        }
    }
    
    func cellDidPlayToEnd(cell: YCPublishDetailViewCell?) {
        if let cell = cell, let index = self.collectionView.indexPath(for: cell), let contents = self.contents {
            let row = index.item
            let nextRow = row+1
            if nextRow < contents.count {
                var rect = self.collectionView.frame
                rect.origin.y = CGFloat(nextRow)*rect.height
                self.collectionView.scrollRectToVisible(rect, animated: true)
            }else {
                cell.displayView()
            }
        }
    }
    
    func cellUserIconTap(cell: YCPublishDetailViewCell?) {
        if let cell = cell, let publish = cell.publishModel {
            if let user = publish.user {
                self.goUser(user)
            }
        }
    }
    
    func goUser(_ user: YCUserModel) {
        var isSameUser = false
        if let ID = self.contentID, (self.contentType == .POST || self.contentType == .LIKE) {
            if user.userID == ID {
                isSameUser = true
            }
        }
        if isSameUser {
            self.viewCloseHander()
        }else {
            let userProfile = YCUserViewController.getInstance() as! YCUserViewController
            userProfile.userModel = user
            if let nav = self.navigationController {
                self.isGoto = true
                nav.pushViewController(userProfile, animated: true)
            }
        }
    }
    
    func likePublishHandler(_ publish: YCPublishModel, publishCell: YCPublishDetailViewCell?) {
        if publish.isLike == 0 {
            publish.isLike = 1
            publish.likeCount = publish.likeCount + 1
            YCLikeDomain().likePublish(publishID: publish.publishID, completionBlock: { (result) in
                if let re = result, re.result {
                    publish.isLike = 1
                    if let contents = self.contents {
                        for oldPublish in contents {
                            if oldPublish.publishID == publish.publishID {
                                oldPublish.isLike = publish.isLike
                                oldPublish.likeCount = publish.likeCount
                                break
                            }
                        }
                    }
                }
            })
            if let cell = publishCell {
                cell.changePublishLikeStatus(publish: publish)
            }
        }
    }
    
    func unLikePublishHandler(_ publish: YCPublishModel, publishCell: YCPublishDetailViewCell?) {
        if publish.isLike == 1 {
            publish.isLike = 0
            publish.likeCount = publish.likeCount - 1
            if publish.likeCount < 0 {
                publish.likeCount = 0
            }
            YCLikeDomain().unLikePublish(publishID: publish.publishID, completionBlock: { (result) in
                if let re = result, re.result {
                    publish.isLike = 0
                    if let contents = self.contents {
                        for oldPublish in contents {
                            if oldPublish.publishID == publish.publishID {
                                oldPublish.isLike = publish.isLike
                                oldPublish.likeCount = publish.likeCount
                                break
                            }
                        }
                    }
                }
            })
            if let cell = publishCell {
                cell.changePublishLikeStatus(publish: publish)
            }
        }
    }
    
    func showCommentView(cell: YCPublishDetailViewCell?) {
        if let ce = cell{
            let commentView = YCCommentViewController(style: .Default, keyboardWillShow: nil) { (content) in
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
            }
            self.present(commentView, animated: true, completion: {
                
            })
        }
    }
    
    func reportHandler(_ cell: YCPublishDetailViewCell?) {
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

extension YCPublishDetailViewController{
    
    @objc func unFollowUserChange(_ notify: Notification) {
        if let followUserID = notify.object as? String, let contents = self.contents {
            for publish in contents{
                if let publishUser = publish.user, publishUser.userID == followUserID {
                    publish.user?.relation = 0
                }
            }
            let cells = self.collectionView.visibleCells
            for cell in cells {
                if let contentCell = cell as? YCPublishDetailViewCell{
                    contentCell.changeCellStyle()
                }
            }
        }
    }
    
    @objc func followUserChange(_ notify: Notification) {
        if let followUserID = notify.object as? String, let contents = self.contents {
            for publish in contents {
                if let publishUser = publish.user, publishUser.userID == followUserID {
                    publish.user?.relation = 1
                }
            }
            let cells = self.collectionView.visibleCells
            for cell in cells {
                if let contentCell = cell as? YCPublishDetailViewCell{
                    contentCell.changeCellStyle()
                }
            }
        }
    }
    
    
    func resolvePopGesture(scrollView: UIScrollView) {
        if let gestures = self.navigationController?.view.gestureRecognizers {
            for gesture in gestures {
                if gesture.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                    scrollView.panGestureRecognizer.require(toFail: gesture)
                }
            }
        }
    }
}
