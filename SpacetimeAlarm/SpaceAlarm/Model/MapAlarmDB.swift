//
//  MapAlarmDB.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
class MapAlarmDB: Object {
    ///地址
    dynamic var  address = ""
    ///位置
    dynamic var location:Location? = nil
    ///距离
    dynamic var distance = 0
    ///描述
    dynamic var describe = ""
    ///铃声
    dynamic var ring = ""
    dynamic var isOpen = true
    ///添加时间
    dynamic var addTime = NSDate()
    
    /// 是否已经提醒过
    dynamic var isHasRemind = false
    
    ///闹铃时间
    dynamic var alarmTime = ""
    ///重复
    dynamic var alarmRepeat = ""
    
}
