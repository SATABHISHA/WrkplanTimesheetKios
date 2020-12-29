//
//  ViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 30/11/20.
//

import UIKit
import Toast

class ViewController: UIViewController {

   
    @IBOutlet weak var view_profile: UIImageView!
    //---Declaring shared preferences----
    let sharedpreferences=UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //SubordinateMonthlyAttendanceLog OnClick
        let tapGestureRecognizerProfileView = UITapGestureRecognizer(target: self, action: #selector(ProfileView(tapGestureRecognizer:)))
        view_profile.isUserInteractionEnabled = true
        view_profile.addGestureRecognizer(tapGestureRecognizerProfileView)
    }

    @IBAction func btn_recognize(_ sender: Any) {
        if sharedpreferences.object(forKey: "CorpIDForLogin") != nil{
            UserSingletonModel.sharedInstance.CorpID = sharedpreferences.object(forKey: "CorpIDForLogin") as? String
            self.performSegue(withIdentifier: "realtime", sender: nil)
        }else{
            var style = ToastStyle()
            
            // this is just one of many style options
            style.messageColor = .white
            
            let str = "The device is not ready yet! Please fill up all required information through admin login > Kiosk Unit Settings."
            self.view.makeToast(str, duration: 3.0, position: .bottom, style: style)
        }
        
    }
    
    //---SubordinateMonthlyAttendanceLog OnClick
    @objc func ProfileView(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "login", sender: nil)
       
    }
}

