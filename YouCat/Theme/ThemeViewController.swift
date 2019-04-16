//
//  CategoryViewController.swift
//  YouCat
//
//  Created by Emiaostein on 2018/3/31.
//  Copyright © 2018 Curios. All rights reserved.
//

import UIKit
import MJRefresh

class YCThemeViewController: UIViewController, YCImageProtocol {
    
    static var _instance:YCThemeViewController?;
    
    static func getInstance() -> YCThemeViewController{
        if _instance == nil{
            _instance = YCThemeViewController();
        }
        return _instance!
    }
    
    var tableView: UITableView!
    
    var userIcon: UIImageView!
    
    var themes: [YCThemeModel] = []
    
    var isFirstLoad: Bool = true
    
    // 顶部刷新
    let headerFresh = MJRefreshNormalHeader()
    // 底部刷新
    let footerFresh = MJRefreshAutoNormalFooter()
    
    let refreshCount = 20
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        self.setUserIcon()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.beginLoadFresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginUserChange(_:)), name: NSNotification.Name("LoginUserChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCategory(_:)), name: NSNotification.Name("reFreshCategory"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let iconTap = UITapGestureRecognizer(target: self, action: #selector(self.iconTapHandler))
        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(iconTap)
        
        let titleLabel = UILabel()
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalTo(self.userIcon).offset(0)
        }
        titleLabel.text = YCLanguageHelper.getString(key: "ThemeLabel")
        titleLabel.textColor = YCStyleColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 36)
        
        
        self.tableView.tableHeaderView = headerView
        
        let rowHeight = self.view.frame.size.width * 4/3
        self.tableView.estimatedRowHeight = rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(YCThemeTableViewCell.self, forCellReuseIdentifier: "YCThemeCell")
        
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
            let themeList = YCDateManager.loadThemeListDate(account: LocalManager.theme)
            self.themes.removeAll()
            for theme in themeList {
                self.themes.append(theme)
            }
            if self.themes.count > 0 {
                self.tableView.reloadData()
                self.footerFresh.isHidden = false
            }
            self.headerFresh.beginRefreshing()
        }
        self.isFirstLoad = false
    }
    
    @objc func refreshPage() {
        YCThemeDomain().topThemeList(start: 0, count: refreshCount) { (modelList) in
            if let list = modelList, list.result{
                if let modelList = list.modelArray {
                    self.themes.removeAll()
                    if self.updateThemeDate(modelList: modelList) {
                        self.tableView.reloadData()
                        self.footerFresh.resetNoMoreData()
                        self.footerFresh.isHidden = false
                        let _ = YCDateManager.saveModelListDate(modelList: self.themes, account: LocalManager.theme)
                    }
                    self.headerFresh.endRefreshing()
                }
            }else {
                self.headerFresh.endRefreshing()
            }
        }
    }
    
    @objc func footerRefresh() {
        YCThemeDomain().topThemeList(start: self.themes.count, count: refreshCount) { (modelList) in
            if let list = modelList, list.result{
                if let modelList = list.modelArray {
                    if self.updateThemeDate(modelList: modelList) {
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
    
    func updateThemeDate(modelList: Array<YCBaseModel>) -> Bool{
        var isChange = false
        for model in modelList {
            if let theme = model as? YCThemeModel {
                var isHave = false
                var index = 0
                for (i, oldTheme) in self.themes.enumerated() {
                    if oldTheme.themeID == theme.themeID {
                        isHave = true
                        index = i
                        break
                    }
                }
                if !isHave {
                    self.themes.append(theme)
                    isChange = true
                }else {
                    self.themes.remove(at: index)
                    self.themes.insert(theme, at: index)
                }
            }
        }
        return isChange
    }

}

extension YCThemeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:YCThemeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "YCThemeCell", for: indexPath) as! YCThemeTableViewCell
        let row = indexPath.item
        let theme = self.themes[row]
        cell.themeModel = theme
        return cell
    }
}

extension YCThemeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.item
        let theme = self.themes[row]
        let themeDetail = YCThemeDetailViewController.getInstance()
        themeDetail.themeModel = theme

        let navigationController = UINavigationController(rootViewController: themeDetail)
        navigationController.isNavigationBarHidden = true
        self.present(navigationController, animated: true) {
            
        }
    }
}

extension YCThemeViewController: YCLoginProtocol {
    
    @objc func loginUserChange(_ notify: Notification) {
        self.isFirstLoad = true
        self.setUserIcon()
    }
    
    @objc func refreshCategory(_ notify: Notification) {
        if self.tableView.contentOffset.y > 0 {
            let offset = CGPoint(x: 0, y: 0)
            self.tableView.setContentOffset(offset, animated: true)
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
//                self.headerFresh.beginRefreshing()
//            }
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
