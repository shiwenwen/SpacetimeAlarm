//
//  Tools.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
class Tools {
    /// 播放音乐
    ///
    /// - parameter source:     音乐资源
    /// - parameter numofLoops: 循环次数
    ///
    /// - returns: 播放器
    class func playMusic(source:String,numofLoops:Int,type:String = "m4r") -> AVAudioPlayer?{

        let path = Bundle.main.path(forResource: source, ofType: type)
        let url = URL(fileURLWithPath: path!)
        var player:AVAudioPlayer? = nil
        do{
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = numofLoops
            player?.prepareToPlay()
            print("准备播放"+source)
        }catch{
            
        }
        
        return player
        
    }
    class func getAppVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    /// 震动
    @objc class func shake(){
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
       print("震动")
    }
    
    /// 连续震动
    class func vibroseis(timeInterval:TimeInterval = 1.5) -> Timer{
        
        return Timer.scheduledTimer(timeInterval: timeInterval, target: Tools.self, selector: #selector(shake), userInfo: nil, repeats: true)
        /*
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
        } else {
            // Fallback on earlier versions
            
            return Timer.scheduledTimer(timeInterval: 2, target: Tools.self, selector: #selector(shake), userInfo: nil, repeats: true)
            
        }
        */
    }
    
    /// 发送通知
    ///
    /// - parameter alertTime: 通知时间
    /// - parameter content:   通知内容
    class func sendNotification(time:TimeInterval,content:String,soundName:String?,info:[String:Any]?){
        let noti = UILocalNotification()
        let date = Date(timeIntervalSinceNow: time)
        noti.fireDate = date
        noti.timeZone = NSTimeZone.default
        noti.alertBody = content
        noti.alertAction = "滑动来查看"
        noti.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        if soundName != "仅震动" {
            if let sound = soundName {
                noti.soundName = sound + ".m4r"
            }
            
        }
        noti.userInfo = info
        UIApplication.shared.scheduleLocalNotification(noti)
    }
    
    /// 取消通知
    ///
    /// - parameter key: key
    class func cancelNotification(key:String){
        
        let notis = UIApplication.shared.scheduledLocalNotifications
        for noti in notis! {
            if let info = noti.userInfo {
                if info["key"] as! String == key {
                    UIApplication.shared.cancelLocalNotification(noti)
                }
            }
        }
    }
    
    /// 星期标识串转星期数组
    ///
    /// - parameter week: 星期标识字符串
    ///
    /// - returns: 数组
    class func weekTagToWeeks(week:String)->[String]{
        var weeks = [String]()
        for char in week.characters {
            switch char {
            case "1":
                weeks.append("周一")
            case "2":
                weeks.append("周二")
            case "3":
                weeks.append("周三")
            case "4":
                weeks.append("周四")
            case "5":
                weeks.append("周五")
            case "6":
                weeks.append("周六")
            default:
                weeks.append("周日")
            }
        }
        return weeks
    }
    
    /// 星期标识串转星期字符串
    ///
    /// - parameter week: 星期标识字符串
    ///
    /// - returns: 字符串
    class func weekTagToWeekString(week:String)->String{
        var weeks = ""
        for char in week.characters {
            switch char {
            case "1":
                weeks += "周一 "
            case "2":
                weeks += "周二 "
            case "3":
                weeks += "周三 "
            case "4":
                weeks += "周四 "
            case "5":
                weeks += "周五 "
            case "6":
                weeks += "周六 "
            default:
                weeks += "周日 "
            }
        }
        return weeks
    }
    class func weeksToWeekTag(weeks:[String])->String{
        var weekTag = ""
        for week in weeks {
            switch week {
            case "周一":
                weekTag += "1"
            case "周二":
                weekTag += "2"
            case "周三":
                weekTag += "3"
            case "周四":
                weekTag += "4"
            case "周五":
                weekTag += "5"
            case "周六":
                weekTag += "6"
            default:
                weekTag += "7"
            }
        }
        return weekTag
        
    }

    
}
extension String{
    
    /// 字符串长度
    var length:Int{
        get{
            return self.characters.count
        }

    }
    
    
}

