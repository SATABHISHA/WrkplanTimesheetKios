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
           /* var style = ToastStyle()
            
            // this is just one of many style options
            style.messageColor = .white
            
            let str = "The device is not ready yet! Please fill up all required information through admin login > Kiosk Unit Settings."
            self.view.makeToast(str, duration: 3.0, position: .bottom, style: style) */ //commented on 30th dec
            
            openDetailsPopup(name:"The device is not ready yet! Please fill up all required information through admin login > Kiosk Unit Settings.")
        }
        
    }
    
    //---SubordinateMonthlyAttendanceLog OnClick
    @objc func ProfileView(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "login", sender: nil)
       
    }
    
    //===============FormDetails Popup code starts===================
    
    
    @IBOutlet weak var btnPopupOk: UIButton!
    @IBAction func btnPopupOk(_ sender: Any) {
        closeDetailsPopup()
    }
    
    
    @IBOutlet weak var stackViewPupupButton: UIStackView!
    @IBOutlet var viewDetails: UIView!
    @IBOutlet weak var name: UILabel!
    func openDetailsPopup(name:String!){
        blurEffect()
        self.view.addSubview(viewDetails)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewDetails.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewDetails.center = self.view.center
        viewDetails.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewDetails.alpha = 0
        viewDetails.sizeToFit()
        
        stackViewPupupButton.addBorder(side: .top, color: UIColor(hexFromString: "7F7F7F"), width: 1)
//        view_custom_btn_punchout.addBorder(side: .top, color: UIColor(hexFromString: "4f4f4f"), width: 1)
//        btnPopupCancel.addBorder(side: .right, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
        UIView.animate(withDuration: 0.3){
            self.viewDetails.alpha = 1
            self.viewDetails.transform = CGAffineTransform.identity
        }
        
        self.name.text = name!
        //        self.confidencelabel.text = confidence!
        
        
    }
    func closeDetailsPopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewDetails.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewDetails.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewDetails.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //===============FormDetails Popup code ends===================
    
    // ====================== Blur Effect Defiend START ================= \\
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var blurEffectView: UIVisualEffectView!
    var loader: UIVisualEffectView!
    func loaderStart() {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        loader = UIVisualEffectView(effect: blurEffect)
        loader.frame = view.bounds
        loader.alpha = 1
        view.addSubview(loader)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.transform = transform
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.white
        loadingIndicator.startAnimating();
        loader.contentView.addSubview(loadingIndicator)
        
        // screen roted and size resize automatic
        loader.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
        // ====================== Blur Effect END ================= \\
    }
    
    func loaderEnd() {
        self.loader.removeFromSuperview();
    }
    // ====================== Blur Effect Defiend END ================= \\
    // ====================== Blur Effect function calling code starts ================= \\
    func blurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.7
        view.addSubview(blurEffectView)
        // screen roted and size resize automatic
        blurEffectView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
        
    }
    func canelBlurEffect() {
        self.blurEffectView.removeFromSuperview();
    }
    
    // ====================== Blur Effect function calling code ends ================= \\
}

