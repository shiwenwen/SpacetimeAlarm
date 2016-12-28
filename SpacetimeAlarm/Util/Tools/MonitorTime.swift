//
//  MonitorTime.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/11/2.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import AVFoundation
class MonitorTime: NSObject {
    static let shared = MonitorTime()
    fileprivate var alarmTimer:Timer?
    fileprivate var results:Results<AlarmDB>!
    /// 当有闹铃完成响铃之后
    var timer:Timer?
    var whenDidRemind:((_ alarmDB:AlarmDB) -> Void)?
    var currents = [AlarmDB]() //当前正在提醒的闹钟队列 防止重提醒
    var isPlayering = false //是都正在播放
    var player:AVAudioPlayer?
    fileprivate override init() {
        
    }
    func start() {
        self.alarmTimer?.invalidate()
        self.alarmTimer = nil
        self.alarmTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction(timer:)), userInfo: nil, repeats: true)
    }
    @objc fileprivate func timerAction(timer:Timer){

        do{
             let realm = try Realm()
             self.results = realm.objects(AlarmDB.self).filter("isOpen == true").sorted(byProperty: "addTime", ascending: false)
            self.startMonitor()
        }catch let error {
            print(error)
        }
        
    }
    fileprivate func startMonitor() {
        for alarm in self.results {
            let time = alarm.alarmTime
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            
            let date = formatter.date(from: time)
            let now = formatter.string(from: Date())
            let weeks = Tools.weekTagToWeeks(week: alarm.alarmRepeat)
            if now == "00:00" {
                do{
                    let realm = try Realm()
                    try realm.write {
                        alarm.isHasRemind = weeks.count > 0
                    }
                }catch let error {
                    print(error)
                    
                }
            }
            let nowDate = formatter.date(from: now)
            let alarmInterval = date!.timeIntervalSince1970
            let nowInterval = nowDate!.timeIntervalSince1970
            print(nowInterval,alarmInterval)
            
            let weekFormatter = DateFormatter()
            weekFormatter.dateFormat = "EEE"
            var isToDay = false
            let weekStr = weekFormatter.string(from: Date())
            print(weekStr)
            for week in weeks {
                
                if week  == weekStr {
                    
                  isToDay = true
                }
            }
            if weeks.count < 1 {
                isToDay = true
            }
            if  nowInterval >= alarmInterval && nowInterval <= alarmInterval + 60 && !alarm.isHasRemind && isToDay{
                
                self.handleAlarm(alarm: alarm)
                
            }
        }
        
    }
    fileprivate func resetAlarm(now:String){
        
    }
    fileprivate func handleAlarm(alarm:AlarmDB) {
        
        if currents.contains(alarm) {
            return
        }
        print("新提醒:",alarm)
        currents.append(alarm)
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        if self.player != nil {
            self.player?.stop()
            self.player = nil
        }
        isPlayering = true
        if alarm.ring != "仅震动" {
            //播放铃声
            player = Tools.playMusic(source: alarm.ring, numofLoops: -1)!
            player?.play()
        }
        //震动
        timer = Tools.vibroseis()
        if UIApplication.shared.applicationState == .background {
            print("处于后台")
            //发送通知
            
            Tools.sendNotification(time: 0, content:alarm.describe, soundName: alarm.ring, info: [
                "key":"\(alarm.addTime.timeIntervalSince1970)",
                "addTime":alarm.addTime,
                "ring":alarm.ring,
                "isOpen":alarm.isOpen,
                "isHasRemind":alarm.isHasRemind
                ])

        }else{
            print("处于前台")
            //提示
            let _ = UITools.showAlert(title: "闹钟提醒", message: alarm.describe, sureAction: { [unowned self] in
                self.isPlayering = false
                self.timer?.invalidate()
                self.timer = nil
                self.player?.stop()
                for index in 0 ..< self.currents.count {
                    let ele = self.currents[index]
                    if ele == alarm {
                        self.currents.remove(at: index)
                    }
                }
                self.didRemind(data: alarm,isHasRemind: true)
                if let didRemind = self.whenDidRemind {
                    didRemind(alarm)
                }
                }, cancelAtion: nil, showVC: UIApplication.shared.keyWindow!.rootViewController!,sureTitle: "关闭")
            
        }
    }
    func didRemind(data:AlarmDB,isHasRemind:Bool) {
        let length = data.alarmRepeat.length
        print(length)
        do{
            let realm = try Realm()
            try realm.write {
                data.isOpen = length > 0
                data.isHasRemind = isHasRemind
                
            }
        }catch let error {
            print(error)
            
        }
        
    }
}
