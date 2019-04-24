//
//  CommentView.swift
//  YouCat
//
//  Created by ting on 2018/12/6.
//  Copyright © 2018年 Curios. All rights reserved.
//

import UIKit

enum YCCommentViewStyle: String{
    case Default = "Default"
    case Dark = "Dark"
}

public typealias CommentKeyboardWillShowBlock = ((_ keyWidth: Float, _ keyHeight: Float) -> Void)
public typealias CommentCompleteBlock = ((_ content: String) -> Void)

class YCCommentViewController: UIViewController {
    
    var keyboardWillShow: CommentKeyboardWillShowBlock?
    var completeBlock: CommentCompleteBlock?
    var style: YCCommentViewStyle = .Default
    
    var commentBgView:UIView!
    var textView:UITextView!
    
    let textHeight:CGFloat = 52
    
    var placeholderLabel:UILabel!
    var plcaeholderText = YCLanguageHelper.getString(key: "EnterCommentLabel")
    
    convenience init(style: YCCommentViewStyle, keyboardWillShow: CommentKeyboardWillShowBlock?, complete: CommentCompleteBlock?) {
        self.init()
        self.style = style
        self.keyboardWillShow = keyboardWillShow
        self.completeBlock = complete
        self.view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        self.modalPresentationStyle = .custom
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
        self.placeholderLabel.text = self.plcaeholderText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.view.isUserInteractionEnabled = true
        let viewSigleTap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler))
        self.view.addGestureRecognizer(viewSigleTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowHandler), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        self.commentBgView = UIView()
        self.view.addSubview(self.commentBgView)
        self.commentBgView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(self.textHeight)
        }
        
        let commentBordView = UIView()
        self.commentBgView.addSubview(commentBordView)
        
        commentBordView.layer.borderWidth = 1
        commentBordView.layer.cornerRadius = 16
        
        let lineView = UIView()
        self.commentBgView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(1)
        }
        
        self.textView = UITextView()
        self.commentBgView.addSubview(self.textView)
        self.textView.snp.makeConstraints { (make) in
            make.right.equalTo(-25)
            make.left.equalTo(25)
            make.centerY.equalTo(self.commentBgView).offset(0)
        }
        self.textView.backgroundColor = UIColor.clear
        self.textView.isScrollEnabled = false
        self.textView.font = UIFont.systemFont(ofSize: 18)
        self.textView.returnKeyType = .send
        self.textView.enablesReturnKeyAutomatically = true
        self.textView.delegate = self
        
        self.placeholderLabel = UILabel()
        self.commentBgView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.textView).offset(5)
            make.right.equalTo(self.textView).offset(-5)
            make.centerY.equalTo(self.textView).offset(0)
        }
        self.placeholderLabel.font = UIFont.systemFont(ofSize: 18)
        
        commentBordView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.centerY.equalTo(self.commentBgView).offset(0)
            make.height.equalTo(self.textView).offset(2)
        }
        
        if self.style == .Default {
            self.textView.keyboardAppearance = .default
            self.textView.textColor = YCStyleColor.black
            self.commentBgView.backgroundColor = YCStyleColor.white
            lineView.backgroundColor = YCStyleColor.grayWhite
            commentBordView.layer.borderColor = YCStyleColor.gray.cgColor
            commentBordView.backgroundColor = YCStyleColor.white
            self.placeholderLabel.textColor = YCStyleColor.gray
        }else if self.style == .Dark {
            self.textView.keyboardAppearance = .dark
            self.textView.textColor = YCStyleColor.white
            self.commentBgView.backgroundColor = YCStyleColor.blackAlpha
            lineView.backgroundColor = YCStyleColor.blackAlpha
            commentBordView.layer.borderColor = YCStyleColor.blackAlpha.cgColor
            commentBordView.backgroundColor = YCStyleColor.grayWhiteAlpha
            self.placeholderLabel.textColor = YCStyleColor.grayWhite
        }
    }
    
}

extension YCCommentViewController: UITextViewDelegate{
    
    @objc func viewTapHandler(sender:UITapGestureRecognizer) {
        self.closeViewHandler {
            if let complete = self.completeBlock {
                complete("")
            }
        }
    }
    
    @objc func keyboardWillShowHandler(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardWidth  = keyboardRectangle.width
            let keyboardHeight = keyboardRectangle.height
            self.commentBgView.snp.remakeConstraints({ (make) in
                make.right.equalTo(0)
                make.left.equalTo(0)
                make.height.equalTo(self.textView).offset(14)
                make.centerX.equalTo(self.view).offset(0)
                make.bottom.equalTo(0-keyboardHeight)
            })
            if let keyboard = self.keyboardWillShow {
                keyboard(Float(keyboardWidth), Float(keyboardHeight + self.textHeight))
            }
        }
    }
    
    func closeViewHandler(block: (()->Void)?) {
        self.textView.resignFirstResponder()
        if let b = block {
            b()
        }
        self.dismiss(animated: true) {
            
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let text = textView.text
            self.closeViewHandler {
                if text != nil, let complete = self.completeBlock {
                    complete(text!)
                }
            }
            return false
        }else {
            if let nowText = textView.text {
                let newText = NSString(string: nowText).replacingCharacters(in: range, with: text)
                let s: NSString = "Text"
                let fontSize = s.size(withAttributes: [NSAttributedString.Key.font: textView.font as Any])
                let tallerSize = CGSize(width: textView.frame.size.width-15, height: textView.frame.size.height*2)
                let newSize = NSString(string: newText).boundingRect(with: tallerSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: textView.font as Any], context: nil).size
                let newLineNum = newSize.height / fontSize.height;
                if newLineNum > 4 {
                    textView.isScrollEnabled = true
                }else{
                    textView.isScrollEnabled = false
                }
                if newText == "" {
                    self.placeholderLabel.isHidden = false
                }else {
                    self.placeholderLabel.isHidden = true
                }
            }
            return true
        }
    }
}
