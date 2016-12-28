//
//  AddressCell.swift
//  SpacetimeAlarm
//
//  Created by 石文文 on 2016/10/30.
//  Copyright © 2016年 石文文. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    var poi:AMapPOI!{
        didSet{
            nameLabel.text = poi.name
            addressLabel.text = poi.address
        }
    }
    var isFirst:Bool!{
        didSet{
            updateUI(currentLocation: isFirst)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func updateUI(currentLocation:Bool) {
        if currentLocation{
            nameLabel.text = "[当前]" + nameLabel.text!
            nameLabel.textColor = UIColor.colorFrom(hex: 0x0096ff)
        }else{
            nameLabel.textColor = UIColor.colorFrom(hex: 0x333333)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
