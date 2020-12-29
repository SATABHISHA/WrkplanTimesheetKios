//
//  RecognitionOptionViewLeaveBalanceTableViewCell.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 11/12/20.
//

import UIKit

class RecognitionOptionViewLeaveBalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var viewLeaveBalanceCell: UIView!
    @IBOutlet weak var labelHrs: UILabel!
    @IBOutlet weak var labelHolidayName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
