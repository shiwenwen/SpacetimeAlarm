//
//  alarmCell.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
class AlarmCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!

    var mapObj:MapAlarmDB!{
        didSet{
            self.titleLabel.text = mapObj.address + (mapObj.isHasRemind && !mapObj.isOpen ? "（已提醒）":"")
            self.subtitleLabel.text = "<\(mapObj.distance)m 时\(mapObj.ring)提醒"
            self.detailTitleLabel.text = mapObj.describe
            self.updateUI(isOpen: mapObj.isOpen,isHasRemind: mapObj.isHasRemind,set: true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        alarmSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
    }
    func changeSwitch() {
        alarmSwitch.isOn = !alarmSwitch.isOn
        
        do{
            let realm = try Realm()
            try! realm.write {
                self.mapObj.isOpen = alarmSwitch.isOn
                if alarmSwitch.isOn && self.mapObj.isHasRemind {
                    self.titleLabel.text = mapObj.address
                    self.mapObj.isHasRemind = false
                    
                }
                MonitorLocation.shared.start()
            }
            
            updateUI(isOpen:self.mapObj.isOpen, isHasRemind: self.mapObj.isHasRemind)
        }catch let error {
           print(error)
            
        }
        
        
    }
    func updateUI(isOpen:Bool,isHasRemind:Bool,set:Bool = false){
        if set {
            alarmSwitch.setOn(isOpen, animated: true)
        }
        if isOpen == true && !isHasRemind{
            titleLabel.alpha = 1
            subtitleLabel.alpha = 1
            detailTitleLabel.alpha = 1
            
        }else{
            titleLabel.alpha = 0.5
            subtitleLabel.alpha = 0.5
            detailTitleLabel.alpha = 0.5
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
