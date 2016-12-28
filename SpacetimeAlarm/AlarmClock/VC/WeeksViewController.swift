//
//  WeeksViewController.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/11/1.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit

class WeeksViewController: BaseTableViewController {
    var completion:((_ week:String)->Void)?
    let weeks = ["周一","周二","周三","周四","周五","周六","周日"]
    var selecteds = [Bool]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        tableView.separatorColor = UIColor.colorFrom(hex: 0xececec)
        if selecteds.count < 1 {
            for _ in weeks {
                selecteds.append(false)
            }
        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let com = completion {
            var week = ""
            for i in 0 ..< selecteds.count {
                let selected = selecteds[i]
                if selected {
                   week = week + "\(i+1)"
                }
            }
            com(week)
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekCell")
        cell?.textLabel?.text = weeks[indexPath.row]
        cell?.selectionStyle = .none
        if selecteds[indexPath.row] {
            cell?.accessoryType = .checkmark
        }else{
            cell?.accessoryType = .none
        }
        
        return cell!
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selecteds[indexPath.row] = !selecteds[indexPath.row]
            tableView.reloadData()
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
