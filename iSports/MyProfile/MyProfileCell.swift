//
//  ProfileCell.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/28.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class MyProfileCell: UITableViewCell {

    @IBOutlet weak var typeSettingTextField: UITextField!
    @IBOutlet weak var levelSettingTextField: UITextField!
    @IBOutlet weak var citySettingTextField: UITextField!
    @IBOutlet weak var timeSettingTextField: UITextField!
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var lableImage: UIImageView!
    @IBOutlet weak var preferenceView: UIView!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var nameSettimgTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preferenceView.isHidden = true
        profileView.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
