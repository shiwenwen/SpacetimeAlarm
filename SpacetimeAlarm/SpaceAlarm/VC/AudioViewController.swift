//
//  AudioViewController.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/30.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import AVFoundation
class AudioViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var selectIndex = -1
    var musics = [String]()
    var player:AVAudioPlayer?
    var completion:((_ music:String)->Void)?
    var defaultName = "仅震动"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.colorFrom(hex: 0xececec)
        initAudio()
    }
    func initAudio() {
        let path = Bundle.main.path(forResource: "music", ofType: "plist")
        musics = NSArray(contentsOf: URL(fileURLWithPath: path!)) as! [String]
        for i in 0 ..< musics.count {
            let name = musics[i]
            if defaultName == name {
                selectIndex = i
            }
        }
        tableView.reloadData()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if selectIndex >= 0 {
            if let com = completion {
                com(musics[selectIndex])
            }
        }
        player?.stop()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Audio")
        cell?.textLabel?.textColor = UIColor.colorFrom(hex: 0x333333)
        cell?.textLabel?.text = musics[indexPath.row]
        if selectIndex == indexPath.row {
            cell?.accessoryType = .checkmark
        }else{
            cell?.accessoryType = .none
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectIndex != indexPath.row {
            selectIndex = indexPath.row
            tableView.reloadData()
        }
        if musics[indexPath.row] == "仅震动"{
            Tools.shake()
        }else {
            player = Tools.playMusic(source: musics[indexPath.row], numofLoops: 1)
            player?.play()
        }
        
        
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
