//
//  MonitorLocation.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/31.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import AVFoundation
class MonitorLocation:NSObject,AMapLocationManagerDelegate{
    
    static let shared = MonitorLocation()
    
    
    /// 当有闹铃完成响铃之后
    var whenDidRemind:((_ alarmDB:MapAlarmDB) -> Void)?
    var currents = [MapAlarmDB]() //当前正在提醒的闹钟队列 防止重提醒
    var isPlayering = false //是都正在播放
    var timer:Timer?
    var player:AVAudioPlayer?
    fileprivate let locationManager = AMapLocationManager()
    fileprivate var results:Results<MapAlarmDB>!
    fileprivate override init(){}
    
    /// 开始 如果有闹钟更新 需要重新调用开始
    func start(){
            locationManager.stopUpdatingLocation()
        do{
            
            let realm = try Realm()
            self.results = realm.objects(MapAlarmDB.self).filter("isOpen == true AND isHasRemind == false").sorted(byProperty: "addTime", ascending: false)
            
            startLocation()
            
        }catch let error {
           print(error)
            
        }
        
    }
    //MARK: 开始定位
    fileprivate func startLocation(){
        
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    //MARK: 比对距离
    fileprivate func monitorLocation(location: CLLocation!){
        
        for data in results {
            let point1 = MAMapPointForCoordinate(location.coordinate)
            let point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(data.location!.lat, data.location!.lon))
            let distance = MAMetersBetweenMapPoints(point1, point2)
            if distance < 100 {
               self.handleAlarm(data: data)
            }
        }
        
    
    }
    //MARK: 处理闹钟
    fileprivate func handleAlarm(data:MapAlarmDB) {
        if currents.contains(data) {
            return
        }
       print("新提醒:",data)
        currents.append(data)
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        if self.player != nil {
            self.player?.stop()
            self.player = nil
        }
        isPlayering = true
        if data.ring != "仅震动" {
            //播放铃声
            player = Tools.playMusic(source: data.ring, numofLoops: -1)!
            player?.play()
        }
        //震动
        timer = Tools.vibroseis()
        if UIApplication.shared.applicationState == .background {
           print("处于后台")
            //发送通知
            
            Tools.sendNotification(time: 0, content:"已到达\(data.address)附近" + (data.describe.length > 0 ? ",您该:\(data.describe)" : ""), soundName: data.ring, info: [
                "key":"\(data.addTime.timeIntervalSince1970)",
                "address":data.address,
                "distance":data.distance,
                "addTime":data.addTime,
                "ring":data.ring,
                "isOpen":data.isOpen,
                "isHasRemind":data.isHasRemind
                ])
            

        }else{
           print("处于前台")
            //提示
           let _ = UITools.showAlert(title: "闹钟提醒", message: "已到达\(data.address)附近" + (data.describe.length > 0 ? "\n您该:\(data.describe)" : ""), sureAction: { [unowned self] in
            self.isPlayering = false
            self.timer?.invalidate()
            self.timer = nil
            self.player?.stop()
            for index in 0 ..< self.currents.count {
                let ele = self.currents[index]
                if ele == data {
                    self.currents.remove(at: index)
                }
            }
            self.didRemind(data: data,isHasRemind: true,isOpen:false)
            if let didRemind = self.whenDidRemind {
                didRemind(data)
            }
                }, cancelAtion: nil, showVC: UIApplication.shared.keyWindow!.rootViewController!,sureTitle: "关闭")
            
        }
    }
    func didRemind(data:MapAlarmDB,isHasRemind:Bool,isOpen:Bool) {
        do{
            let realm = try Realm()
            try realm.write {
                data.isHasRemind = isHasRemind
                data.isOpen = isOpen
            }
        }catch let error {
           print(error)
            
        }
        
    }
    //MARK: AMapLocationManagerDelegate
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
       print("位置更新",location)
        monitorLocation(location: location)
        
    }
    func amapLocationManager(_ manager: AMapLocationManager!, didChange status: CLAuthorizationStatus) {
        
        if status == .denied {
           let _ = UITools.showAlert(title: "提示", message: "请打开地理位置权限，否则无法使用地图闹钟", sureAction: {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                
                }, cancelAtion: { [unowned self] in
                    
                    self.locationManager.stopUpdatingLocation()
                    
                }, showVC: UIApplication.shared.keyWindow!.rootViewController!)

            
        }else{
            locationManager.startUpdatingLocation()
        }
        
    }
}
