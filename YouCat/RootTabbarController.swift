 //
//  RootTabbarController.swift
//  YouCat
//
//  Created by ting on 2018/9/25.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit
 import LeanCloud

class YCRootTabbarController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.creatTabBar()
        self.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //创建tabBar
    func creatTabBar()  {
        
        let feed  = YCFavoriteViewController.getInstance()
        let feedNav = UINavigationController(rootViewController:feed)
        
        let feedTabBarItem = UITabBarItem(title: YCLanguageHelper.getString(key: "HomeLabel"), image: UIImage(named: "tabbar-home"), tag: 1)
        feedTabBarItem.selectedImage = UIImage(named: "tabbar-home-selected")
        
        feedNav.tabBarItem = feedTabBarItem;
        
        let category  = YCThemeViewController.getInstance()
        let categoryNav = UINavigationController(rootViewController:category)
        let categoryTabBarItem = UITabBarItem(title: YCLanguageHelper.getString(key: "ThemeLabel"), image: UIImage(named: "tabbar-catagory"), tag: 2)
        categoryTabBarItem.selectedImage = UIImage(named: "tabbar-catagory-selected")
        categoryNav.tabBarItem = categoryTabBarItem;
        
        
//        vc.conversation = chatRoom
    
        self.viewControllers = [feedNav,categoryNav]
        self.tabBar.tintColor = YCStyleColor.red
        self.navigationController?.isNavigationBarHidden = true
        register()
        clientInitializing(isReopen: false) {
            self.createMessageViewControllers()
        }
    }
    
    func register() {
        do {
            LCApplication.logLevel = .all
            try LCApplication.default.set(
                id: "heQFQ0SwoQqiI3gEAcvKXjeR-gzGzoHsz",
                key: "lNSjPPPDohJjYMJcQSxi9qAm"
            )
        } catch {
            fatalError("\(error)")
        }
        
        _ = Client.delegator
        _ = LocationManager.delegator
        
        LCObject.register()
    }
    
    func createMessageViewControllers() {
        let IDSet: Set<String> = Set(arrayLiteral: "Mary")
//        clientInitializing(isReopen: true)
        var memberSet: Set<String> = IDSet
        memberSet.insert(Client.current.ID)
        guard memberSet.count > 1 else {
            return
        }
        let name: String = {
            let sortedNames: [String] = memberSet.sorted(by: { $0 < $1 })
            let name: String
            if sortedNames.count > 3 {
                name = [sortedNames[0], sortedNames[1], sortedNames[2], "..."].joined(separator: " & ")
            } else {
                name = sortedNames.joined(separator: " & ")
            }
            return name
        }()
//        self.activityToggle()
        do {
            try Client.current.createConversation(clientIDs: memberSet, name: name, completion: { (result) in
//                self.activityToggle()
                switch result {
                case .success(value: let conversation):
                    mainQueueExecuting {
                        let messageListVC = MessageListViewController()
                        messageListVC.conversation = conversation
                        let ttem = UITabBarItem(title: YCLanguageHelper.getString(key: "ChatLabel"), image: UIImage(named: "tabbar-chat"), tag: 2)
                        ttem.selectedImage = UIImage(named: "tabbar-chat-selected")
                        messageListVC.tabBarItem = ttem;
                        self.viewControllers?.insert(messageListVC, at: 2)
//                        self.navigationController?.pushViewController(messageListVC, animated: true)
                    }
                case .failure(error: let error):
                    UIAlertController.show(error: error, controller: self)
                }
            })
        } catch {
//            self.activityToggle()
            UIAlertController.show(error: error, controller: self)
        }
        
        
        
    }
    
    func clientInitializing(isReopen: Bool, completed:(()->())?) {
        do {
//            self.activityToggle()
            
            let clientID: String = "Robert"
            let tag: String? = (Configuration.UserOption.isTagEnabled.boolValue ? "mobile" : nil)
            let options: IMClient.Options = Configuration.UserOption.isLocalStorageEnabled.boolValue
                ? .default
                : { var dOptions = IMClient.Options.default; dOptions.remove(.usingLocalStorage); return dOptions }()
            
            let client = try IMClient(
                ID: clientID,
                tag: tag,
                options: options,
                delegate: Client.delegator,
                eventQueue: Client.queue
            )
            
            if options.contains(.usingLocalStorage) {
                try client.prepareLocalStorage { (result) in
                    Client.specificAssertion
                    switch result {
                    case .success:
                        do {
                            try client.getAndLoadStoredConversations(completion: { (result) in
                                Client.specificAssertion
                                switch result {
                                case .success(value: let storedConversations):
                                    var conversations: [IMConversation] = []
                                    var serviceConversations: [IMServiceConversation] = []
                                    for item in storedConversations {
                                        if type(of: item) == IMConversation.self {
                                            conversations.append(item)
                                        } else if let serviceItem = item as? IMServiceConversation {
                                            serviceConversations.append(serviceItem)
                                        }
                                    }
                                    self.open(
                                        client: client,
                                        isReopen: isReopen,
                                        storedConversations: (conversations.isEmpty ? nil : conversations),
                                        storedServiceConversations: (serviceConversations.isEmpty ? nil : serviceConversations), completed: completed
                                    )
                                case .failure(error: let error):
//                                    self.activityToggle()
                                    UIAlertController.show(error: error, controller: self)
                                }
                            })
                        } catch {
//                            self.activityToggle()
                            UIAlertController.show(error: error, controller: self)
                        }
                    case .failure(error: let error):
//                        self.activityToggle()
                        UIAlertController.show(error: error, controller: self)
                    }
                }
            } else {
                self.open(client: client, isReopen: isReopen, completed: completed)
            }
        } catch {
//            self.activityToggle()
            UIAlertController.show(error: error, controller: self)
        }
    }
    
    func open(
        client: IMClient,
        isReopen: Bool,
        storedConversations: [IMConversation]? = nil,
        storedServiceConversations: [IMServiceConversation]? = nil,
        completed:(()->())?)
    {
        let options: IMClient.SessionOpenOptions
        if let _ = client.tag {
            options = Configuration.UserOption.isAutoOpenEnabled.boolValue ? [] : [.forced]
        } else {
            options = .default
        }
        client.open(options: options, completion: { (result) in
            Client.specificAssertion
//            self.activityToggle()
            switch result {
            case .success:
                mainQueueExecuting {
                    Client.current = client
                    Client.storedConversations = storedConversations
                    Client.storedServiceConversations = storedServiceConversations
//                    UIApplication.shared.keyWindow?.rootViewController = TabBarController()
                    completed?()
                }
            case .failure(error: let error):
                if error.code == 4111 {
                    Client.delegator.client(client, event: .sessionDidClose(error: error))
                } else {
                    UIAlertController.show(error: error, controller: self)
                }
            }
        })
    }
}

extension YCRootTabbarController: UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let cl = tabBarController.selectedViewController, cl.isEqual(viewController){
            let index = tabBarController.selectedIndex
            if index == 0 {
                NotificationCenter.default.post(name: NSNotification.Name("reFreshHome"), object: nil)
            }else if index == 1 {
                NotificationCenter.default.post(name: NSNotification.Name("reFreshCategory"), object: nil)
            }
            return false;
        }
        return true
    }
}

extension UINavigationController{
    
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override open var childForStatusBarHidden: UIViewController?{
        return self.topViewController
    }
}


class YCNavigationController: UINavigationController{
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    override var childForStatusBarHidden: UIViewController?{
        return self.topViewController
    }
}

class YCViewController: UIViewController {
    
    class func getInstance() -> YCViewController{
        return YCViewController()
    }
    
    class func addInstance(_ instance: YCViewController) {
        
    }
    
    var isGoto: Bool = false
    var addInteractivePop: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        if self.addInteractivePop {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.delegate = self
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isGoto = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !self.isGoto {
            self.resetViewController()
        }
        if let delegate = self.navigationController?.interactivePopGestureRecognizer?.delegate as? YCViewController, delegate == self {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        if let delegate = self.navigationController?.delegate as? YCViewController, delegate == self {
            self.navigationController?.delegate = nil
        }
    }
    
    func initViewController(){
        
    }
    
    func resetViewController() {
        YCViewController.addInstance(self)
    }
}

extension YCViewController:UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
}
