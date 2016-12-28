//
//  AlarmClockCell.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/11/1.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
class AlarmClockCell: UITableViewCell {

    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var repeatLabel: UILabel!
    
    @IBOutlet weak var remarkLabel: UILabel!
    var alarmData:AlarmDB!{
        didSet{
            self.remarkLabel.text = alarmData.describe
            self.repeatLabel.text = Tools.weekTagToWeekString(week: alarmData.alarmRepeat) + " " + alarmData.ring
            self.alarmSwitch.isOn = alarmData.isOpen
            self.timerLabel.text = alarmData.alarmTime
            updateUI(isOpen:self.alarmData.isOpen, isHasRemind: self.alarmData.isHasRemind)
        }
    }
    
    func changeSwitch() {
        alarmSwitch.isOn = !alarmSwitch.isOn
        
        do{
            let realm = try Realm()
            try! realm.write {
                self.alarmData.isOpen = alarmSwitch.isOn
                if alarmSwitch.isOn && self.alarmData.isHasRemind {
                    self.alarmData.isHasRemind = false
                    
                }
                MonitorTime.shared.start()
            }
            
            updateUI(isOpen:self.alarmData.isOpen, isHasRemind: self.alarmData.isHasRemind)
        }catch let error {
           print(error)
            
        }
        
        
    }
    func updateUI(isOpen:Bool,isHasRemind:Bool){
        if isOpen == true && !isHasRemind {
            timerLabel.alpha = 1
            repeatLabel.alpha = 1
            remarkLabel.alpha = 1
            
        }else{
            timerLabel.alpha = 0.5
            repeatLabel.alpha = 0.5
            remarkLabel.alpha = 0.5
            
        }
        if isHasRemind {
            self.timerLabel.text = self.timerLabel.text! + "（已提醒)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
         alarmSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
