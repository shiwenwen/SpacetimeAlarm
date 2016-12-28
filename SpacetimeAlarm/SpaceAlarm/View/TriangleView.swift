//
//  TriangleView.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit

class TriangleView: UIView {

    
    override func draw(_ rect: CGRect) {
        //获取上下文
        let context = UIGraphicsGetCurrentContext()
        //设置填充色
        UIColor.white.setFill()
        
        context?.move(to: CGPoint(x: 0, y: 19))
        context?.addLine(to: CGPoint(x: 3, y: 19))
        context?.addLine(to: CGPoint(x: 20, y: 40))
        context?.addLine(to: CGPoint(x: 37, y: 19))
        context?.addLine(to: CGPoint(x: 40, y: 19))
        context?.fillPath()
        
    }
 

}
