//
//  AddMapAlarmViewController.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import RealmSwift
class AddMapAlarmViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate{

    @IBOutlet weak var tableView: UITableView!
    typealias Completion = (_ result:Bool)->Void
    var completion:Completion!
    var address = ""
    var remarks:UITextField!
    var ring = "仅震动"
    var distance:Int = 100
    var poi:AMapPOI?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新建地图闹钟"
        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorColor = UIColor.colorFrom(hex: 0xececec)
        tableView.tableFooterView = UIView()

    }
    deinit {
        guard address.length > 0 && ring.length > 0 else{
            return
        }
        do{
            
            let realm = try Realm()
            let map = MapAlarmDB()
            map.address = self.address
            map.describe = self.remarks.text!
            map.distance = self.distance
            let location = Location()
            location.lat = Double(self.poi!.location.latitude)
            location.lon = Double(self.poi!.location.longitude)
            map.ring = self.ring
            map.location = location
            try realm.write {
                realm.add(map)
            }
            self.completion(true)
        }catch let error {
           print(error)
            self.completion(false)
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    //MARK:--tableViewDelegate-DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextInputCell") as! TextInputCell
        
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "提醒地点"
            cell.textInput.placeholder = "请选择地点"
            cell.textInput.isEnabled = false
            cell.textInput.text = address
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.titleLabel.text = "备注信息"
            cell.textInput.placeholder = "请填写备注信息"
            cell.textInput.isEnabled = true
            remarks = cell.textInput
            cell.accessoryType = .none
        default:
            cell.titleLabel.text = "提醒铃声"
            cell.textInput.placeholder = "请选择铃声"
            cell.textInput.isEnabled = false
            cell.textInput.text = ring
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            mapVC.completion = { [unowned self] poi in
                self.poi = poi
                self.address = poi.name
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            navigationController?.pushViewController(mapVC, animated: true)
            
        }else if indexPath.row == 2 {
            let audioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioViewController") as! AudioViewController
            audioVC.defaultName = self.ring
            audioVC.completion = {
                [unowned self] name in
                self.ring = name
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
                navigationController?.pushViewController(audioVC, animated: true)
            
        }
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
