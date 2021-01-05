//
//  HomeViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 07/12/20.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var label_btn_logout: UILabel!
    @IBOutlet weak var label_dashboard_yaxis_constraint: NSLayoutConstraint!
    @IBOutlet weak var label_logout_yaxis_constraint: NSLayoutConstraint!
    @IBOutlet weak var customNavBarConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var Designablebtn_kiosk_unit_settings: DesignableButton!
    @IBOutlet weak var Designablebtn_employee_img_settings: DesignableButton!
    @IBOutlet weak var label_kiosk_unit_settings: UILabel!
    @IBOutlet weak var label_employee_image_settings: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if UIScreen.main.nativeBounds.height == 2688 ||
            UIScreen.main.nativeBounds.height == 2436 ||
            UIScreen.main.nativeBounds.height == 2208 ||
            UIScreen.main.nativeBounds.height == 1792 ||
            UIScreen.main.nativeBounds.height == 896{
            label_dashboard_yaxis_constraint.constant = 25
            label_logout_yaxis_constraint.constant = 25
            customNavBarConstraintHeight.constant = 107
        }
        /*if UIScreen.main.nativeBounds.height == 667 {
            label_dashboard_yaxis_constraint.constant = 0
            label_logout_yaxis_constraint.constant = 0
            customNavBarConstraintHeight.constant = 70
        }*/
       
        label_kiosk_unit_settings.layer.cornerRadius = 0
        label_kiosk_unit_settings.layer.masksToBounds = true
//        label_kiosk_unit_settings.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 2)
//        label_kiosk_unit_settings.layer.masksToBounds = true
        
//        label_employee_image_settings.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 2)
        label_employee_image_settings.layer.cornerRadius = 0
        label_employee_image_settings.layer.masksToBounds = true
        
        //---KioskUnitSettings OnClick
        let tapGestureRecognizerKioskUnitSettingsDesignablebtn = UITapGestureRecognizer(target: self, action: #selector(DesignablebtnKioskUnitSettings(tapGestureRecognizer:)))
        Designablebtn_kiosk_unit_settings.isUserInteractionEnabled = true
        Designablebtn_kiosk_unit_settings.addGestureRecognizer(tapGestureRecognizerKioskUnitSettingsDesignablebtn)
        
        //---ImageSettings OnClick
        let tapGestureRecognizerImageSettingsDesignablebtn = UITapGestureRecognizer(target: self, action: #selector(DesignablebtnImageSettings(tapGestureRecognizer:)))
        Designablebtn_employee_img_settings.isUserInteractionEnabled = true
        Designablebtn_employee_img_settings.addGestureRecognizer(tapGestureRecognizerImageSettingsDesignablebtn)
        
        //---Logout OnClick
        let tapGestureRecognizerLogout = UITapGestureRecognizer(target: self, action: #selector(Logout(tapGestureRecognizer:)))
        label_btn_logout.isUserInteractionEnabled = true
        label_btn_logout.addGestureRecognizer(tapGestureRecognizerLogout)
    }
    
    //---Logout OnClick
    @objc func Logout(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "login", sender: nil)
       
    }
    
    //---KioskUnitSettings OnClick
    @objc func DesignablebtnKioskUnitSettings(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "kiosksettings", sender: nil)
       
    }
    
    //---ImageSettings OnClick
    @objc func DesignablebtnImageSettings(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "empsettings", sender: nil)
       
    }

    @IBAction func btn_logout(_ sender: Any) {
        self.performSegue(withIdentifier: "login", sender: nil)
    }
}
extension UILabel {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
