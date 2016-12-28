//
//  AlarmViewController.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift
class AlarmViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var normalTableView: UITableView!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mapTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var tableSuperView: UIView!
    
    var mapEmptyLabel:UILabel!
    var normalEmptyLabel:UILabel!
    var triangle: TriangleView!
    var triangleLeft:Constraint!
    var triangleRight:Constraint!
    var alarmCell:AlarmCell!
    var mapData:Results<MapAlarmDB>?
    var alarmsData:Results<AlarmDB>?
    let locationManager = AMapLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        initMapData()
        initAlarmData()
        monitorLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    //MARK: 监听位置
    func monitorLocation() {
        
        MonitorLocation.shared.start()
        MonitorLocation.shared.whenDidRemind = { [unowned self] _ in
            self.mapTableView.reloadData()
        }
        MonitorTime.shared.start()
        MonitorTime.shared.whenDidRemind = {[unowned self] _ in
            self.normalTableView.reloadData()
        }
    }
    //MARK: ----获取地理位置
    func getLocation() {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
           let _ = UITools.showAlert(title: "提示", message: "请打开地理位置权限，否则无法使用地图闹钟", sureAction: {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                
                    self.locationManager.requestLocation(withReGeocode: true, completionBlock: { (location, geoode, error) in
                        
                        if error == nil {
                            let city = geoode?.city
                            UserDefaults.standard.set(city, forKey: KCity)
                            UserDefaults.standard.synchronize()
                        }
                    })
                
                }, cancelAtion: { [unowned self] in
                    self.mapButton.isEnabled = false
                    self.mapButton.alpha = 0.5
                }, showVC: self)
        }else{
            
            
        }
        
    }
    //MARK: 初始化数据
    func initMapData() {
        do{
            let realm = try Realm()
            self.mapData = realm.objects(MapAlarmDB.self).sorted(byProperty: "addTime", ascending: false)
            if self.mapData!.count > 0 {
                self.mapEmptyLabel.isHidden = true
            }else{
                self.mapEmptyLabel.isHidden = false
            }
            DispatchQueue.main.async {
                self.mapTableView.reloadData()
            }
            
        }catch let error {
            print(error)
            self.mapEmptyLabel.isHidden = false
        }
        
    }
    func initAlarmData() {
        do{
            let realm = try Realm()
            self.alarmsData = realm.objects(AlarmDB.self).sorted(byProperty: "addTime", ascending: false)
            if self.alarmsData!.count > 0 {
                self.normalEmptyLabel.isHidden = true
            }else{
                self.normalEmptyLabel.isHidden = false
            }
            DispatchQueue.main.async {
                self.normalTableView.reloadData()
            }
            
        }catch let error {
            print(error)
            self.normalEmptyLabel.isHidden = false
        }
    }
    //MARK: 配置UI
    func configUI() {
        triangle = TriangleView()
        triangle.backgroundColor = UIColor.clear
        bottomView.addSubview(triangle)
        triangle.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            self.triangleLeft = make.left.equalTo(75).constraint
            self.triangleRight = make.right.equalTo(self.bottomView).offset(-75).priority(250).constraint
            make.top.equalTo(-20)
            
        }
        contentView.cornerRadius = 10
        mapButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .selected)
        normalButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .selected)
        normalButton.isSelected = true
        
        mapTableView.separatorStyle = .none
        mapTableView.dataSource = self
        mapTableView.delegate = self
        alarmCell = mapTableView.dequeueReusableCell(withIdentifier: "AlarmCell") as! AlarmCell
        mapTableView.rowHeight = UITableViewAutomaticDimension
        mapTableView.estimatedRowHeight = 80
        mapEmptyLabel = UILabel.create(text: "暂无闹钟,快去添加一个吧", fontSize: 14, color: UIColor.colorFrom(hex: 0xb1b1b1))
        mapTableView.addSubview(mapEmptyLabel)
        mapEmptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(mapTableView)
        }
        
        normalTableView.separatorStyle = .none
        normalTableView.dataSource = self
        normalTableView.delegate = self
        normalTableView.rowHeight = UITableViewAutomaticDimension
        normalTableView.estimatedRowHeight = 80
        normalEmptyLabel = UILabel.create(text: "暂无闹钟,快去添加一个吧", fontSize: 14, color: UIColor.colorFrom(hex: 0xb1b1b1))
        normalTableView.addSubview(normalEmptyLabel)
        normalEmptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.normalTableView)
        }
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: 添加闹钟
    @IBAction func addAlarm(_ sender: AnyObject) {
        if self.tableSuperView.subviews.last === mapTableView {
            let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddMapAlarmViewController") as! AddMapAlarmViewController
            addVC.completion = { [unowned self] result in
                if  result {
                    self.initMapData()
                    MonitorLocation.shared.start()
                }else{
                    let alert = UIAlertController(title: "提示", message: "添加闹钟失败", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
            navigationController?.pushViewController(addVC, animated: true)
        }else{
           let alarmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlarmClockViewController") as! AlarmClockViewController
            alarmVC.completion = { [unowned self] result in
                if  result {
                    self.initAlarmData()
                    MonitorTime.shared.start()
                }else{
                    let alert = UIAlertController(title: "提示", message: "添加闹钟失败", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            navigationController?.pushViewController(alarmVC, animated: true)
            
            
            
        }
        
    }
    //MARK: 设置
    @IBAction func setting(_ sender: AnyObject) {
        
    }
    //MARK: 切换地图模式
    @IBAction func mapMode(_ sender: AnyObject) {
        mapButton.isSelected = !mapButton.isSelected
        normalButton.isSelected = !normalButton.isSelected
        UIView.animate(withDuration: 0.25) {
            
            self.triangleRight.deactivate()
            self.triangleLeft.activate()
            self.view.layoutIfNeeded()
        }
       UIView.transition(with: tableSuperView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.tableSuperView.bringSubview(toFront: self.mapTableView)
        }, completion: nil)
        
        
    }
    //切换普通模式
    @IBAction func normalModel(_ sender: AnyObject) {

        mapButton.isSelected = !mapButton.isSelected
        normalButton.isSelected = !normalButton.isSelected
        UIView.animate(withDuration: 0.25) {
            self.triangleLeft.deactivate()
            self.triangleRight.activate()
            self.view.layoutIfNeeded()
        }
        UIView.transition(with: tableSuperView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.tableSuperView.bringSubview(toFront: self.normalTableView)
            }, completion: nil)
    
    }
    
    //MARK:--tableViewDelegate-DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === mapTableView {
            return mapData == nil ? 0 : mapData!.count
        }else{
            return alarmsData == nil ? 0 : alarmsData!.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === mapTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell") as! AlarmCell
            let mapObj = mapData![indexPath.row]
            cell.mapObj = mapObj
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmClockCell") as! AlarmClockCell
        cell.alarmData = alarmsData![indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if tableView === mapTableView {
                do{
                    let mapObj = mapData?[indexPath.row]
                    let realm = try Realm()
                    try! realm.write {
                        realm.delete(mapObj!)
                    }
                    self.initMapData()
                    
                    
                }catch let error {
                    print(error)
                    
                }
            }else{
                do{
                    let alarm = alarmsData?[indexPath.row]
                    let realm = try Realm()
                    try! realm.write {
                        realm.delete(alarm!)
                    }
                    self.initAlarmData()
                    
                    
                }catch let error {
                    print(error)
                    
                }
            }
            
        }
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.alarmCell.detailTitleLabel.text = "这是一个非常非常非常非常长的文字，我来想想，到底会有多长呢，你猜，哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈"
        return self.alarmCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + 1
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
    }
 

}
