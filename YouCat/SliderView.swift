//
//  SliderView.swift
//  YouCat
//
//  Created by ting on 2018/10/28.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

class YCVerSlierViewController: UIViewController {
    let num = 5
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //scrollView的初始化
        let scrollView = UIScrollView()
        let aa = UIScreen.main.bounds
        
        
        let bounds = CGRect(x: 0, y: 0, width: aa.width, height: aa.height)
        
        scrollView.frame = bounds
        //为了让内容横向滚动，设置横向内容宽度为3个页面的宽度总和
        scrollView.contentSize = CGSize(width: bounds.width ,
                                        height: bounds.height * CGFloat(num))
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        //添加子页面
        for i in 0..<num{
            let a = CGRect(x:0, y:bounds.height*CGFloat(i), width:bounds.width, height:bounds.height)
            let view = YCHorSliderView(frame: a, row: i+1)
            scrollView.addSubview(view)
        }
        self.view.addSubview(scrollView)
    }
    
}

class YCHorSliderView: UIView{
    let numOfPages = 3
    
    var row:Int!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    init(frame: CGRect, row: Int){
        self.row = row
        super.init(frame: frame)
        self.initView()
    }
    
    func initView(){
        //scrollView的初始化
        let scrollView = UIScrollView()
        let aa = self.frame
        print("aa = \(aa)")
    
        let bounds = CGRect(x: 0, y: 0, width: aa.width, height: aa.height)
        
        scrollView.frame = bounds
        //为了让内容横向滚动，设置横向内容宽度为3个页面的宽度总和
        scrollView.contentSize = CGSize(width: bounds.width * CGFloat(numOfPages)*2,
                                        height: bounds.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        
        //添加子页面
        for i in 0..<numOfPages{
            let myView = YCView(frame: CGRect(x:bounds.width*CGFloat(i), y:0,
                                 width:bounds.width*2, height:bounds.height), row: self.row, number: i+1)
            scrollView.addSubview(myView)
        }
        self.addSubview(scrollView)
    }
}


class YCView: UIView{
    var number:Int!
    var row:Int!
    let colorMap=[
        1:UIColor.red,
        2:UIColor.orange,
        3:UIColor.blue,
        4:UIColor.brown,
        5:UIColor.gray,
        6:UIColor.black,
        7:UIColor.purple,
        8:UIColor.cyan,
        9:UIColor.yellow,
        0:UIColor.darkGray
    ]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    init(frame: CGRect, row: Int, number: Int){
        self.row = row
        self.number = number
        super.init(frame: frame)
        self.initView()
    }
    
    func initView(){
    
        self.backgroundColor = UIColor.green
        
        let bounds = self.frame
        
         print("bb = \(bounds)")
        
        let scrollView = UIScrollView()
        self.addSubview(scrollView)
        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        //为了让内容横向滚动，设置横向内容宽度为3个页面的宽度总和
        let view = UIView()
        scrollView.addSubview(view)
        var contentSize = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        if number == 3 {
            contentSize = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height*2)
        }else if number == 2 {
            contentSize = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        }else if number == 1 {
            contentSize = CGRect(x: 0, y: bounds.height/4, width: bounds.width, height: bounds.height/2)
        }
        view.frame = contentSize
        let randomNumberTwo:Int = Int(arc4random_uniform(10))
        view.backgroundColor = colorMap[randomNumberTwo]
        scrollView.contentSize = CGSize(width: contentSize.width, height: contentSize.height)
        
//        var rec = scrollView.frame
//        rec.origin.y = -88
//        rec.origin.x = 0
//        scrollView.scrollRectToVisible(rec, animated: false)
        
        
        let numberLabel = UILabel(frame:CGRect(x:30, y:bounds.height/2, width:200, height:30))
        numberLabel.text = "第\(self.row!)行， 第\(self.number!)页"
        numberLabel.textColor = UIColor.white
        self.addSubview(numberLabel)
    }
}
