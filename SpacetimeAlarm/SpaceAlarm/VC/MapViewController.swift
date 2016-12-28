//
//  MapViewController.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/29.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit

class MapViewController: BaseViewController,UISearchBarDelegate,MAMapViewDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var searchBarLeft: NSLayoutConstraint!

    @IBOutlet weak var searchBarRight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MAMapView!
    var selectedIndex:Int = -1
    var tap:UITapGestureRecognizer!
    var annotation:UIImageView!
    var toSelfLocationView:UIButton!
    var currentLocation:CLLocationCoordinate2D!
    let search = AMapSearchAPI()
    var results = [AMapPOI]()
    var emppty:UILabel!
    var page = 0
    var size = 20
    var isAround = true
    var activity = UIActivityIndicatorView()
    var completion:((_ poi:AMapPOI)->Void)?
    var wasUserAction = true
    var wasClickToselfLocation = true
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(hiddenKeyboard))
        configUI()
        configMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.35) {
            self.navigationController?.navigationBar.getNavigationBarBottomLine()?.isHidden = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.35) {
            self.navigationController?.navigationBar.getNavigationBarBottomLine()?.isHidden = true
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let completion = completion {
            if  selectedIndex > -1 {
                completion(results[selectedIndex])
            }
            
        }
    }
    func hiddenKeyboard() {
        self.view.endEditing(true)
    }
    //MARK: 配置UI
    func configUI() {
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.colorFrom(hex: 0xececec)
        tableView.rowHeight = 55
        emppty = UILabel.create(text: "暂无数据", fontSize: 14, color: UIColor.colorFrom(hex: 0x999999), frame: CGRect.zero,lines: 1,alignment: .center)
        tableView.addSubview(emppty)
        tableView.addSubview(activity)
        
        emppty.snp.makeConstraints { (make) in
          make.center.equalTo(tableView)
        }
        activity.activityIndicatorViewStyle = .gray
        activity.startAnimating()
        activity.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.centerX.equalTo(tableView)
            make.width.height.equalTo(30)
        }
    }
    //MARK: 配置地图
    func configMap() {
        mapView.delegate = self
        mapView.mapType = MAMapType.standard
        annotation = UIImageView(image: UIImage(named: "大头针"))
        annotation.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        mapView.addSubview(annotation)
        annotation.snp.makeConstraints { (make) in
            make.center.equalTo(self.mapView)
        }
        
        toSelfLocationView = UIButton.create(title: nil, image: "复位", target: self, action: #selector(toSelfLocation))
        mapView.addSubview(toSelfLocationView)
        toSelfLocationView.snp.makeConstraints { (make) in
            make.right.equalTo(self.mapView.snp.right).offset(-5)
            make.bottom.equalTo(self.mapView.snp.bottom).offset(-5)
            make.width.height.equalTo(42)
        }
        
        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .followWithHeading
        mapView.setZoomLevel(16.5, animated: false)
        mapView.isShowsLabels = true
        
        search?.delegate = self
        
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            let _ = UITools.showAlert(title: "提示", message: "请打开地理位置权限，否则无法使用地图闹钟", sureAction: {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    
                }, cancelAtion: { [unowned self] in
                    self.goBack()
                }, showVC: self)
        }else{
            
            
        }
        
        
    }
    //MARK: 回到自己所在地
    func toSelfLocation() {
        wasUserAction = true
        wasClickToselfLocation = true
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        currentLocation = mapView.userLocation.coordinate
        isAround = true
        beginSearch()
    }
    //MARK: 开始搜索
    func beginSearch() {
        activity.startAnimating()
        page = 0
        selectedIndex = -1
        searchRequest()
    }
    //MARK: --mapViewDelegate-------
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if currentLocation == nil {
            
            isAround = true
            currentLocation = userLocation.coordinate
            mapView.setCenter(userLocation.coordinate, animated: false)
            beginSearch()
            
        }
        currentLocation = userLocation.coordinate
    }
    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
        if wasUserAction {
            UIView.animate(withDuration: 0.25, animations: { 
                self.annotation.transform = CGAffineTransform.init(translationX: 0, y: -20)
                
            })
            
        }
    }
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        self.wasUserAction = wasUserAction
        if wasClickToselfLocation {
            self.wasUserAction = true
            self.wasClickToselfLocation = false
        }
        if wasUserAction {
            currentLocation = mapView.convert(annotation.center, toCoordinateFrom:mapView)
            UIView.animate(withDuration: 0.25, animations: { 
                self.annotation.transform = CGAffineTransform.identity
                }, completion: { _ in
                    self.isAround = true
                    self.beginSearch()
            })
        }
    }
    //MARK: 搜索
    func searchRequest() {
        if isAround {
            let request = AMapPOIAroundSearchRequest()
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(currentLocation.latitude), longitude: CGFloat(currentLocation.longitude))
            request.keywords = searchBar.text
            request.sortrule = 0
            request.page = page
            request.requireExtension = true
            search?.aMapPOIAroundSearch(request)
        }else{
            let request = AMapPOIKeywordsSearchRequest()
            request.page = page
            request.keywords = searchBar.text
            request.requireExtension = true
            request.cityLimit = true
            request.requireSubPOIs = true
            search?.aMapPOIKeywordsSearch(request)
        }
        
    }
    //MARK: --AMapSearchDelegate--
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        activity.stopAnimating()
        guard response.pois.count > 0 else {
            return
        }
        
        if page == 0 {
            results.removeAll()
        }
        results.append(contentsOf: response.pois)
        
        if results.count < 1 {
            emppty.isHidden = false
        }else{
            emppty.isHidden = true
            tableView.reloadData()
        }
        if page == 0{
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            if results.count > 0{
                let location = results.first!.location!
                if !wasUserAction {
                    mapView.setCenter(CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude)), animated: true)
                }
                
            }
            
        }
        page += 1
    }
    //MARK: searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addGestureRecognizer(tap)
        wasUserAction = false
        UIView.animate(withDuration: 0.35) {
            self.searchBarLeft.constant = 15
            self.searchBarRight.constant = 15
            self.view.layoutIfNeeded()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isAround = false
        beginSearch()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isAround = false
        beginSearch()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.removeGestureRecognizer(tap)
        UIView.animate(withDuration: 0.35) {
            self.searchBarLeft.constant = 87
            self.searchBarRight.constant = 87
            self.view.layoutIfNeeded()
        }
    }
    //MARK: ---tableView----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as! AddressCell
        cell.poi = results[indexPath.row]
        cell.isFirst = indexPath.row == 0 && isAround
        if selectedIndex == indexPath.row {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == results.count - 1 {
            searchRequest()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex != indexPath.row {
            let location = results[indexPath.row].location!
            mapView.setCenter(CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude)), animated: true)
            selectedIndex = indexPath.row
            tableView.reloadData()
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
