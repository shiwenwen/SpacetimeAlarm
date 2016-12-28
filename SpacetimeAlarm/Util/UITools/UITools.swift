//
//  UITools.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit

class UITools {
    
    /// 计算字符串大小
    ///
    /// - parameter string:        字符串
    /// - parameter font:          字体
    /// - parameter bound:         大小范围
    /// - parameter lineSpace:     行间距
    /// - parameter lineBreakMode: 换号方式
    ///
    /// - returns: size
    class func sizeOf(string:String,font:UIFont,bound:CGSize,lineSpace:CGFloat = 0,lineBreakMode:NSLineBreakMode = .byWordWrapping) -> CGSize {
        let str = NSString(string: string)
        let para = NSMutableParagraphStyle()
        para.lineSpacing = lineSpace
        let rect = str.boundingRect(with: bound, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:font,NSParagraphStyleAttributeName:para], context: nil).size
        return rect
    }
    
    
    /// 显示alert
    ///
    /// - parameter title:       title
    /// - parameter message:     message
    /// - parameter sureAction:  sureAction
    /// - parameter cancelAtion: cancelAction
    /// - parameter showVC:      showVC
    class func showAlert(title:String?,message:String?,sureAction:(()->Void)?,cancelAtion:(()->Void)?,showVC:UIViewController,sureTitle:String = "确定",cancelTitle:String = "取消") -> UIAlertController{
        
        let alert = UIAlertController(title:title, message:message, preferredStyle: .alert)
        if let cancel = cancelAtion {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
               cancel()
            }))
        }
        if let sure = sureAction {
            alert.addAction(UIAlertAction(title: sureTitle, style: .default, handler: { _ in
                sure()
            }))
        }
        
        
        showVC.present(alert, animated: true, completion: nil)
        return alert
    }
}
extension UINavigationBar {
    
    /// 获取导航栏底部线条
    ///
    /// - returns: 线
    func getNavigationBarBottomLine() -> UIImageView? {
        return getLine(View: self)
    }
    fileprivate func getLine(View:UIView) -> UIImageView? {
        if View.isKind(of: UIImageView.self) && View.height <= 1.0 {
            return View as? UIImageView
        }
        for view in View.subviews {
            let image = getLine(View: view)
            if image != nil {
               return image
            }
            
        }
        return nil
    }
}

//MARK:---常用参数-----
let KScreenHeight:CGFloat = UIScreen.main.bounds.size.height
let KScreenWidth:CGFloat = UIScreen.main.bounds.size.width
let proportation:CGFloat = KScreenWidth / 375 //和六的比例
let KNavigationBarHeight:CGFloat = 64
let KTabBarHeight:CGFloat = 49
//MARK:----颜色-----
extension UIColor {
    
    /// 十六进制生成颜色
    ///
    /// - parameter hex: 十六进制颜色值
    ///
    /// - returns: 颜色
    class func colorFrom(hex:Int) -> UIColor {
        return UIColor(red: CGFloat((hex&0xff0000)>>16)/255.0, green: CGFloat((hex&0xff00)>>8)/255.0, blue: CGFloat(hex&0xff)/255.0, alpha: 1)
    }
    
    /// rgb颜色 0-1
    ///
    /// - parameter r:     red
    /// - parameter g:     green
    /// - parameter b:     blue
    /// - parameter alpha: alpha
    ///
    /// - returns: 颜色
    class func colorFrom(r:CGFloat,g:CGFloat,b:CGFloat,alpha:CGFloat = 1) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
    
}
//MARK:坐标
extension UIView {
    //左
    var left:CGFloat{
        
        /**
         设置视图左边的坐标 整个视图跟着移动
         
         - parameter left: 视图最左边坐标
         */
        set{
            self.frame = CGRect(x: newValue, y:  self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        }
        
        /**
         获取视图最左边的坐标
         
         - returns: 视图最左边的坐标
         */
        get{
            return self.frame.origin.x
        }
    }

    //右
    var right:CGFloat{
        
        /**
         设置视图右边的坐标 整个视图跟着移动
         
         - parameter right: 视图最右边坐标
         */
        get{
            return self.frame.origin.x + self.frame.size.width
        }
        /**
         获取视图最右边的坐标
         
         - returns: 视图最右边的坐标
         */
        set{
            self.frame = CGRect(x:newValue - self.frame.size.width, y:self.frame.origin.y,width:self.frame.size.width,height:self.frame.size.height)
        }
    }

    
    //上
    
    
    var top:CGFloat{
        /**
         获取视图顶部的坐标
         
         - returns: 视图顶部坐标
         */
        get{
            return self.frame.origin.y
        }
        /**
         设置视图顶部的坐标 整个视图跟着移动
         
         - parameter top: 视图顶部坐标
         */
        set{
            self.frame = CGRect(x:self.frame.origin.x,y:newValue,width:self.frame.size.width,height:self.frame.size.height)
        }
    }
    
    //下
    var bottom:CGFloat{
        /**
         设置视图底部的坐标 整个视图跟着移动
         
         - parameter bottom: 视图底部坐标
         */
        set{
            self.frame = CGRect(x:self.frame.origin.x,y:newValue - self.frame.size.height,width:self.frame.size.width,height:self.frame.size.height)
            
        }
        /**
         获取视图底部的坐标
         
         - returns: 视图底部坐标
         */
        get{
            return self.frame.origin.y+self.frame.size.height
        }
    }
    
    //宽
    var width:CGFloat{
        /**
         获取视图宽度
         
         - returns: 视图宽
         */
        get{
            return self.frame.size.width
        }
        /**
         设置视图宽度
         
         - parameter width: 视图宽
         */
        set{
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newValue, height: self.frame.size.height)
            
        }
    }

    //高度
    var height:CGFloat{
        /**
         获取视图高度
         
         - returns: 视图高度
         */
        get{
            return self.frame.size.height
        }
        /**
         设置视图高度
         
         - parameter height: 视图高度
         */
        set{
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height:newValue)
        }
    }
    
}



//MARK:-------UIView--------------------------------

extension UIView{
    
    
    /**
     获取当前视图所在的视图控制器
     
     - returns: 视图控制器
     */
    func viewController()->UIViewController?{
        
        var next:UIResponder? = self.next
        
        repeat{
            
            
            if next!.isKind(of:UIViewController.self){
                
                return (next as? UIViewController)
                
            }
            next = next?.next
            
            
        }while next != nil
        
        return nil
    }
    
    /**
     设置圆角
     
     - parameter cornerRadius: 圆角大小
     */
    var cornerRadius:CGFloat{
        set{
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
        get{
            return self.layer.cornerRadius
        }
    }

    
}
//MARK: -----UIlabel-------
extension UILabel {
    
    /// 创建一个label
    ///
    /// - parameter text:      text
    /// - parameter fontSize:  fontSize
    /// - parameter color:     textColor
    /// - parameter frame:     frame
    /// - parameter lines:     numberOfLines
    /// - parameter alignment: textAligment
    ///
    /// - returns: UIlabel
    class func create(text:String?,fontSize:CGFloat?,color:UIColor?,frame:CGRect = CGRect.zero,lines:Int = 1,alignment:NSTextAlignment = .left) -> UILabel {
        
        let label = UILabel(frame: frame)
        label.text = text
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = lines
        label.font = fontSize == nil ? label.font : UIFont.systemFont(ofSize: fontSize!)
        return label
    }
    
    /// 获取调整尺寸
    ///
    /// - parameter autoSet: 是否自动调整
    ///
    /// - returns: 尺寸
    func size(autoSet:Bool = false) -> CGSize {
        
        let size = self.sizeThatFits(CGSize(width: self.width, height:CGFloat(MAXFLOAT)))
        if autoSet {
            self.width = size.width
            self.height = self.height
        }
        return size
        
    }
    
}
//MARK: ----UIButton----
extension UIButton {
    
    /// 创建一个button
    ///
    /// - parameter title:  title
    /// - parameter image:  image
    /// - parameter target: target
    /// - parameter action: action
    /// - parameter frame:  frame
    ///
    /// - returns: button
    class func create(title:String?,image:String?,target:Any?,action:Selector,frame:CGRect = CGRect.zero) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        if let name = image{
            button.setImage(UIImage(named: name), for: .normal)
        }
        button.setTitle(title, for: .normal)
        
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
        
    }
}


