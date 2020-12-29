//
//  TaskSelectionTableViewCell.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 11/12/20.
//

import UIKit

protocol TaskSelectionTableViewCellDelegate : class {
    func TaskSelectionTableViewCellDidTapAddOrView(_ sender: TaskSelectionTableViewCell)
}
class TaskSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var btn_radio: KGRadioButton!
    @IBOutlet weak var label_account_code: UILabel!
    @IBOutlet weak var label_contract: UILabel!
    @IBOutlet weak var label_labour_category: UILabel!
    @IBOutlet weak var label_hour: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewCustomBtnRadioTapped(tapGestureRecognizer:)))
        btn_radio.isUserInteractionEnabled = true
        btn_radio.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    weak var delegate: TaskSelectionTableViewCellDelegate?
    @objc func ViewCustomBtnRadioTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //        let tappedImage = tapGestureRecognizer.view as! UIImageView
        delegate?.TaskSelectionTableViewCellDidTapAddOrView(self)
        
    }
}
