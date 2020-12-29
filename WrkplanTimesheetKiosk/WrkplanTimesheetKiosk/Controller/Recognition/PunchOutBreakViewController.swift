//
//  PunchOutBreakViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 16/12/20.
//

import UIKit

class PunchOutBreakViewController: UIViewController {
    
    @IBOutlet weak var img_punch: UIImageView!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_time: UILabel!
    @IBOutlet weak var label_checked_in: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label_date.text = Date.getCurrentDateMonthForAttendanceRecordControllel()
        label_time.text = Date.getCurrentTime()
        label_checked_in.text = RecognitionOptionViewController.checkedInOut
        
        if RecognitionOptionViewController.punch_out_break == "out"{
            img_punch.image = UIImage(named: "goodbye")
        }else if RecognitionOptionViewController.punch_out_break == "break"{
            img_punch.image = UIImage(named: "goodbye")
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            // your code here For Pushing to Another Screen
            self.performSegue(withIdentifier: "homemain", sender: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
