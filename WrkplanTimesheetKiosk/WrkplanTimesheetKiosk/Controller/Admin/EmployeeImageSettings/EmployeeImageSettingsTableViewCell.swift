//
//  EmployeeImageSettingsTableViewCell.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 08/12/20.
//

import UIKit

protocol EmployeeImageSettingsTableViewCellDelegate : class {
    func EmployeeImageSettingsTableViewCellAddOrRemoveDidTapAddOrView(_ sender: EmployeeImageSettingsTableViewCell)
}
class EmployeeImageSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_enroll_status: UILabel!
    @IBOutlet weak var view_custom_btn: UIView!
    @IBOutlet weak var label_custom_btn: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewCustomBtnAddOrRemoveTapped(tapGestureRecognizer:)))
        view_custom_btn.isUserInteractionEnabled = true
        view_custom_btn.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    weak var delegate: EmployeeImageSettingsTableViewCellDelegate?
    @objc func ViewCustomBtnAddOrRemoveTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //        let tappedImage = tapGestureRecognizer.view as! UIImageView
        delegate?.EmployeeImageSettingsTableViewCellAddOrRemoveDidTapAddOrView(self)
        
    }

}
