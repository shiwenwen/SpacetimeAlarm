//
//  AlarmDB.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/11/1.
//  Copyright © 2016年 石文文. All rights reserved.
//

import RealmSwift
import Realm
class AlarmDB: Object {
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
