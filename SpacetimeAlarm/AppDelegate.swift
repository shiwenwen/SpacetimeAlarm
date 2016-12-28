//
//  AppDelegate.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreLocation
import Realm
import RealmSwift
import AVFoundation
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,AVAudioPlayerDelegate {
    
    var window: UIWindow?
    var bgTaskId = UIBackgroundTaskInvalid
    let player = Tools.playMusic(source: "silent", numofLoops: -1,type: "mp3")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.applicationIconBadgeNumber = 0
        IQKeyboardManager.sharedManager().enable = true
        configBugly()
        configAMAP()
        registerNotification()
        configBackgroundPlayer()
        return true
    }
    //MARK: 注册通知
    func registerNotification(){
        let action = UIMutableUserNotificationAction()
        action.identifier = "Cloose"
        action.activationMode = UIUserNotificationActivationMode.foreground
        action.isAuthenticationRequired = true
        action.isDestructive = true
        action.title = "关闭"
        let category = UIMutableUserNotificationCategory()
        category.identifier = CategoryId
        category.setActions([action], for: .default)
        let set = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories:[category])
        UIApplication.shared.registerUserNotificationSettings(set)
    }
    func configBackgroundPlayer() {
        //设置后台播放
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setActive(true)
            try session.setCategory(AVAudioSessionCategoryPlayback)
           
        }catch{
            
        }
        
        player?.delegate = self
    }
    //MARK: AVAudioPlayerDelegate
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error)
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == UIEventType.remoteControl {
            MonitorLocation.shared.start()
            MonitorTime.shared.start()
        }
    }
    func beginIgnoringInteractionEvents() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.bgTaskId = self.backgroundPlayerID(backTaskId: self.bgTaskId)
    }
    func backgroundPlayerID(backTaskId:UIBackgroundTaskIdentifier) -> UIBackgroundTaskIdentifier {
        
        var newTaskId = UIBackgroundTaskInvalid
        newTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        if newTaskId != UIBackgroundTaskInvalid && backTaskId != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(backTaskId)
        }
        return newTaskId
    }
    
    //MARK: -----第三方配置-----
    /// 配置bugly
    func configBugly() {
        let config =  BuglyConfig()
        config.deviceIdentifier = UUID().uuidString
        Bugly.start(withAppId: BuglyId, config:config)
    }
    ///高德地图
    func configAMAP(){
        
        AMapServices.shared().apiKey = AMAPKey
        
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        beginIgnoringInteractionEvents()
        player?.prepareToPlay()
        player?.play()
        print("silent.mp3播放")
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        player?.stop()
        UIApplication.shared.endReceivingRemoteControlEvents()
        UIApplication.shared.applicationIconBadgeNumber = 0
        if !MonitorLocation.shared.isPlayering {
            MonitorLocation.shared.timer?.invalidate()
            MonitorLocation.shared.timer = nil
            MonitorLocation.shared.currents.removeAll()
            MonitorLocation.shared.start()
            
        }
        if !MonitorTime.shared.isPlayering {
            MonitorTime.shared.timer?.invalidate()
            MonitorTime.shared.timer = nil
            MonitorTime.shared.currents.removeAll()
            MonitorTime.shared.start()
        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("didReceive notification")
        MonitorLocation.shared.timer?.invalidate()
        MonitorLocation.shared.timer = nil
        MonitorLocation.shared.player?.stop()
        MonitorLocation.shared.player = nil
        MonitorLocation.shared.currents.removeAll()
        MonitorLocation.shared.start()
        
        MonitorTime.shared.timer?.invalidate()
        MonitorTime.shared.timer = nil
        MonitorTime.shared.player?.stop()
        MonitorTime.shared.player = nil
        MonitorTime.shared.currents.removeAll()
        MonitorTime.shared.start()
        
        
        /*
        if let info = notification.userInfo {
            Tools.cancelNotification(key: info["key"] as! String)
            do{
                let realm = try Realm()
                let datas = realm.objects(MapAlarmDB.self).filter("isOpen == true")
                
                for i in 0 ..< datas.count {
                    let data = datas[i]
                    if "\(data.addTime.timeIntervalSince1970)" == info["key"] as! String {
                        try realm.write {
                            data.isHasRemind = true
                            data.isOpen = false
                        }
                        if MonitorLocation.shared.currents.contains(data) {
                           MonitorLocation.shared.currents.remove(at: i)
                        }
                    }
                    
                }
                let navi = UIApplication.shared.keyWindow!.rootViewController as! UINavigationController
                let alarmVC = navi.viewControllers.first as! AlarmViewController
                alarmVC.tableView.reloadData()
                
            }catch let error {
                
                print(error)
            }

            
        }
        */
        
        
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
        print("handleActionWithIdentifier")
        
        completionHandler()
    }


}

