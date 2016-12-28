//
//  AlarmClockViewController.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/11/1.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
class AlarmClockViewController: BaseTableViewController {

    @IBOutlet weak var alarmTime: UITextField!
    @IBOutlet weak var alarmRepeat: UITextField!
    @IBOutlet weak var remarks: UITextField!
    @IBOutlet weak var rings: UITextField!
    var weekTag = ""
    typealias Completion = (_ result:Bool)->Void
    var completion:Completion!
    var isDismiss = true
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.colorFrom(hex: 0xececec)
        tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    // MARK: - Table view data source
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isDismiss = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard alarmTime.text!.length > 0 && isDismiss else {
            
            return
        }
        do{
            
            let realm = try Realm()
            let alarm = AlarmDB()
            alarm.describe = remarks.text ?? ""
            alarm.ring = rings.text!
            alarm.alarmTime = alarmTime.text!
            alarm.alarmRepeat = weekTag
            try realm.write {
                realm.add(alarm)
            }
            self.completion(true)
        }catch let error {
           print(error)
            self.completion(false)
        }
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            
            DatePicker.shared.showDatePicker(completion: { (picker) in
                let date = picker.date
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timer = formatter.string(from: date)
                self.alarmTime.text = timer
            })
            
        case 1:
            chooseWeeks()
            
        case 2:
            
            break

            
        default:
            let audioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioViewController") as! AudioViewController
            audioVC.defaultName = self.rings.text!
            audioVC.completion = {
                [unowned self] name in
                self.rings.text = name
            }
            navigationController?.pushViewController(audioVC, animated: true)
            isDismiss = false
        }
    }
    //MARK: 选择日期
    func chooseWeeks() {
        let weekVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeeksViewController") as! WeeksViewController
        if self.alarmRepeat.text!.length > 0 {
            let weeks = self.alarmRepeat.text!.components(separatedBy: ",")
            var  selecteds = [Bool]()
            for _ in 0 ..< 7 {
                selecteds.append(false)
            }
            for day in weeks {
                switch day {
                case "周一":
                    selecteds[0] = true
                case "周二":
                    selecteds[1] = true
                case "周三":
                    selecteds[2] = true
                case "周四":
                    selecteds[3] = true
                case "周五":
                    selecteds[4] = true
                case "周六":
                    selecteds[5] = true
                default:
                    selecteds[6] = true
                }
            }
           weekVC.selecteds = selecteds
        }
        
        weekVC.completion = { [unowned self] str in
            self.weekTag = str
            self.alarmRepeat.text = Tools.weekTagToWeekString(week: str)
        }
        navigationController?.pushViewController(weekVC, animated: true)
        isDismiss = false
    }
    
}

