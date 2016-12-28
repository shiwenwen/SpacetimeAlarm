//
//  DatePicker.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/11/1.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit

class DatePicker {
    
    static let shared = DatePicker()
    var background:UIView!
    fileprivate init() {}
    fileprivate var completion:((_ picker:UIDatePicker)->Void)!
    fileprivate var picker:UIDatePicker!
    func showDatePicker(completion:((_ picker:UIDatePicker)->Void)?){
        self.completion = completion
        
        if background == nil {
            self.background = UIView()
            background.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            UIApplication.shared.keyWindow!.addSubview(background)
            background.snp.makeConstraints { (make) in
                make.edges.equalTo(background.superview!)
            }
            picker = UIDatePicker()
            let contentView = UIView()
            contentView.backgroundColor = UIColor.white
            background.addSubview(contentView)
            contentView.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalTo(background)
                make.left.height.equalTo(background).multipliedBy(0.35)
            })
            contentView.addSubview(picker)
            
            let topView = UIView()
            topView.layer.borderColor = UIColor.colorFrom(hex: 0xececec).cgColor
            topView.layer.borderWidth = 0.5
            contentView.addSubview(topView)
            topView.snp.makeConstraints { (make) in
                
                make.left.right.top.equalTo(contentView)
                make.height.equalTo(40)
            }
            let finishButton = UIButton.create(title: "完成", image: nil, target: self, action: #selector(finish))
            finishButton.setTitleColor(UIColor.colorFrom(hex: 0x333333), for: .normal)
            topView.addSubview(finishButton)
            finishButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(topView)
                make.right.equalTo(topView).offset(-15)
            }
            let cancelButton = UIButton.create(title: "取消", image: nil, target: self, action: #selector(cancel))
            cancelButton.setTitleColor(UIColor.colorFrom(hex: 0x333333), for: .normal)
            topView.addSubview(cancelButton)
            cancelButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(topView)
                make.left.equalTo(topView).offset(15)
            }

            picker.snp.makeConstraints { (make) in
                make.left.right.bottom.equalTo(contentView)
                make.top.equalTo(topView.snp.bottom)
            }
            picker.datePickerMode = .time
            picker.addTarget(self, action: #selector(datePickerValueChanged(pick:)), for: .valueChanged)
            
        
        
        }
        self.picker.setDate(Date(), animated: false)
        self.background.alpha = 0
        UIView.animate(withDuration: 0.35) { 
            self.background.alpha = 1
        }
        
    }
    @objc func finish() {
        UIView.animate(withDuration: 0.35, animations: {
            self.background.alpha = 0
        }) { (result) in
            
            self.completion(self.picker)
        }
        
        
    }
    @objc func cancel() {
        UIView.animate(withDuration: 0.35, animations: {
            self.background.alpha = 0
            }) { (result) in
         
        }
        
    }
    @objc fileprivate func datePickerValueChanged(pick:UIDatePicker){
        
    }

}
