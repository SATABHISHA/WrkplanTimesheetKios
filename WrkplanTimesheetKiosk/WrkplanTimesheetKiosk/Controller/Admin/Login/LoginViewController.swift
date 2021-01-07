//
//  LoginViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 07/12/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast

class LoginViewController: UIViewController {
    
    @IBOutlet weak var home_img_custom: UIImageView!
    @IBOutlet weak var view_custom_nav_bar: UIView!
    @IBOutlet weak var label_login: UILabel!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var corpId: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var label_yaxis_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var navbar_height_constraint: NSLayoutConstraint!
    @IBOutlet weak var home_yaxis_constraint: NSLayoutConstraint!
    @IBOutlet weak var view_corpid: UIView!
    @IBOutlet weak var view_username: UIView!
    @IBOutlet weak var view_pwd: UIView!
    
    var checkBtnYN = 0
    //---Declaring shared preferences----
    let sharedpreferences=UserDefaults.standard
    
    var loginResult = false
    var mutableData = NSMutableData()
    var arrRes = [[String:AnyObject]]()
    var foundCharacters = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        if UIScreen.main.nativeBounds.height == 2688 ||
            UIScreen.main.nativeBounds.height == 2436 ||
            UIScreen.main.nativeBounds.height == 2208 ||
            UIScreen.main.nativeBounds.height == 1792 ||
            UIScreen.main.nativeBounds.height == 896{
            label_yaxis_constraint.constant = 25
            home_yaxis_constraint.constant = 25
            navbar_height_constraint.constant = 107
        }
        
//        btnCheckBox.setImage(UIImage(named:"check_box_empty"), for: .normal)
//        btnCheckBox.setImage(UIImage(named:"check_box"), for: .selected)
        
        corpId.setLeftPaddingPoints(12)
        userName.setLeftPaddingPoints(12)
        password.setLeftPaddingPoints(12)
        
        corpId.attributedPlaceholder = NSAttributedString(string: "Corporate ID", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        userName.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        if sharedpreferences.object(forKey: "CorpIDForLogin") != nil{
            corpId.text = sharedpreferences.object(forKey: "CorpIDForLogin") as? String
        }
        
        //============keyboard will show/hide, code starts==========
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //============keyboard will show/hide, code ends===========
        
        //--------to hide keyboard, code starts-----
        corpId.resignFirstResponder()
        userName.resignFirstResponder()
        password.resignFirstResponder()
        //--------to hide keyboard code ends------
        
        //---Home OnClick
        let tapGestureRecognizerLogout = UITapGestureRecognizer(target: self, action: #selector(Home(tapGestureRecognizer:)))
        home_img_custom.isUserInteractionEnabled = true
        home_img_custom.addGestureRecognizer(tapGestureRecognizerLogout)
        
        //--corner radius
        //--commented as getting issues on corner radius
//        view_corpid.addBorder(side: .left, color: UIColor(hexFromString: "7F7F7F"), width: 1)
       /* view_corpid.roundCorners([.topLeft,.bottomLeft], radius: 5)
        corpId.layer.borderWidth = 1
        corpId.roundCorners([.topRight,.bottomRight], radius: 5)
        corpId.borderColor = UIColor(hexFromString: "626262")
        
        
        
        view_username.roundCorners([.topLeft,.bottomLeft], radius: 5)
        userName.roundCorners([.topRight,.bottomRight], radius: 5)
        
        view_pwd.roundCorners([.topLeft,.bottomLeft], radius: 5)
        password.roundCorners([.topRight,.bottomRight], radius: 5) */
//        view_corpid.roundCorners(.bottomLeft, radius: 5)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //---Logout OnClick
    @objc func Home(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "homemain", sender: nil)
       
    }
    
    
    @IBAction func btn_login(_ sender: Any) {
//        self.performSegue(withIdentifier: "home", sender: nil)
        corpId.resignFirstResponder()
        userName.resignFirstResponder()
        password.resignFirstResponder()
        loaderStart()
        self.Validate()
    }
    func Validate(){
        if (corpId.text == "" || userName.text == "" || password.text == ""){
            loaderEnd()
            var style = ToastStyle()
            
            // this is just one of many style options
            style.messageColor = .white
            
            // present the toast with the new style
            self.view.makeToast("Field cannot be left empty", duration: 3.0, position: .bottom, style: style)
        }else {
//            self.loginAPICall()
            if Connectivity.isConnectedToInternet {
                
                self.loginAPICall()
            }
            else{
                loaderEnd()
                print("No Internet is available")
                var style = ToastStyle()
                
                // this is just one of many style options
                style.messageColor = .white
                
                // present the toast with the new style
                self.view.makeToast("No Internet Connection", duration: 3.0, position: .bottom, style: style)
                }
             }
    }
    @IBAction func checkMarkedTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                if(!sender.isSelected){
                    sender.isSelected = true
                    sender.transform = .identity
                    self.checkBtnYN = 1
                    print("checked", self.checkBtnYN)
                }else{
                    sender.isSelected = false
                    sender.transform = .identity
                    self.checkBtnYN = 0
                    print("Un checked")
                }
            }, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
      /*  if sharedpreferences.object(forKey: "UserID") != nil {
            // let swiftyJsonVar=JSON(sharedpreferences.object(forKey: "preferences_activescreen")!)
            UserSingletonModel.sharedInstance.CompanyName = sharedpreferences.object(forKey: "CompanyName") as? String
            UserSingletonModel.sharedInstance.PayableClerkYN = sharedpreferences.object(forKey: "PayableClerkYN") as? Int
            UserSingletonModel.sharedInstance.UserID = sharedpreferences.object(forKey: "UserID") as? Int
            UserSingletonModel.sharedInstance.AdminYN = sharedpreferences.object(forKey: "AdminYN") as? Int
            UserSingletonModel.sharedInstance.SupervisorId = sharedpreferences.object(forKey: "SupervisorId") as? Int
            UserSingletonModel.sharedInstance.SupervisorYN = sharedpreferences.object(forKey: "SupervisorYN") as? Int
            UserSingletonModel.sharedInstance.UserName = sharedpreferences.object(forKey: "UserName") as? String
            UserSingletonModel.sharedInstance.PwdSetterId = sharedpreferences.object(forKey: "PwdSetterId") as? Int
            UserSingletonModel.sharedInstance.CompID = sharedpreferences.object(forKey: "CompID") as? Int
            UserSingletonModel.sharedInstance.CorpID = sharedpreferences.object(forKey: "CorpID") as? String
            UserSingletonModel.sharedInstance.Msg = sharedpreferences.object(forKey: "Msg") as? String
            UserSingletonModel.sharedInstance.EmailId = sharedpreferences.object(forKey: "EmailId") as? String
            UserSingletonModel.sharedInstance.UserRole = sharedpreferences.object(forKey: "UserRole") as? String
            UserSingletonModel.sharedInstance.UserType = sharedpreferences.object(forKey: "UserType") as? String
            UserSingletonModel.sharedInstance.FinYearID = sharedpreferences.object(forKey: "FinYearID") as? String
            UserSingletonModel.sharedInstance.PurchaseYN = sharedpreferences.object(forKey: "PurchaseYN") as? Int
            UserSingletonModel.sharedInstance.PayrollClerkYN = sharedpreferences.object(forKey: "PayrollClerkYN") as? Int
            UserSingletonModel.sharedInstance.EmpName = sharedpreferences.object(forKey: "EmpName") as? String
            
            UserSingletonModel.sharedInstance.EmailServer = sharedpreferences.object(forKey: "EmailServer") as? String
            UserSingletonModel.sharedInstance.EmailServerPort = sharedpreferences.object(forKey: "EmailServerPort") as? String
            UserSingletonModel.sharedInstance.EmailSendingUsername = sharedpreferences.object(forKey: "EmailSendingUsername") as? String
            UserSingletonModel.sharedInstance.EmailPassword = sharedpreferences.object(forKey: "EmailPassword") as? String
            UserSingletonModel.sharedInstance.EmailHostAddress = sharedpreferences.object(forKey: "EmailHostAddress") as? String
            // self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "home", sender: self)
            
            
        } */ //--- cpmmenting on 28th dec
    }
    
    //-----------dismiss keyboard on touching anywhere in the screen code starts-----------
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //-----------dismiss keyboard code ends-----------
    
    //============keyboard will show/hide, code starts==========
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 100
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    //============keyboard will show/hide, code ends===========
    
    // ====================== Blur Effect Defiend START ================= \\
    var ActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var blurEffectView: UIVisualEffectView!
    var loader: UIVisualEffectView!
    func loaderStart() {
        // ====================== Blur Effect START ================= \\
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        loader = UIVisualEffectView(effect: blurEffect)
        loader.frame = view.bounds
        loader.alpha = 2
        view.addSubview(loader)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        ActivityIndicator.transform = transform
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
    // ====================== Blur Effect function calling code ends =================

};
extension LoginViewController: XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    func loginAPICall() {
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        print("deviceId-=>",deviceId!)
        
//        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><ValidateTSheetLogin xmlns='%@/'><CorpID>%@</CorpID><UserName>%@</UserName><Password>%@</Password></ValidateTSheetLogin></soap:Body></soap:Envelope>",BASE_URL, String(describing: corpId.text!),  String(describing: userName.text!), String(describing: password.text!))
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><ValidateTSheetKioskAdminLogin xmlns='%@/KioskService.asmx'><CorpID>%@</CorpID><UserName>%@</UserName><Password>%@</Password><DeviceID>%@</DeviceID> </ValidateTSheetKioskAdminLogin></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: corpId.text!), String(describing: userName.text!), String(describing: password.text!), String(describing: deviceId!))
//        <DeviceID>%@</DeviceID> , String(describing: deviceId!)
        let soapMessage = text
//        let url = NSURL(string: "\(BASE_URL)/TimesheetService.asmx?op=ValidateTSheetLogin")
        let url = NSURL(string: "\(BASE_URL)/KioskService.asmx?op=ValidateTSheetKioskAdminLogin")
        print("url-=>", url!)
        print("corpID-=-=>",corpId.text!)
        print("username-=-=>",userName.text!)
        let theRequest = NSMutableURLRequest(url: url! as URL)
        let msgLength = String(soapMessage.count)
        
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(msgLength, forHTTPHeaderField: "Content-Length")
//        theRequest.addValue("http://www.erpgovmobile.com/timesheetservice.asmx?op=/ValidateTSheetLogin", forHTTPHeaderField: "SOAPAction")
        theRequest.httpMethod = "POST"
        theRequest.httpBody = soapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false) // or false
        
        let connection = NSURLConnection(request: theRequest as URLRequest, delegate: self, startImmediately: true)
        connection?.start()
        if (connection != nil) {
            let mutableData : Void = NSMutableData.initialize()
            print(mutableData)
        }
    }
    
    // MARK: - Web Service
    
    internal func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        mutableData.length = 0;
    }
    
    internal func connection(_ connection: NSURLConnection, didReceive data: Data) {
        mutableData.append(data as Data)
    }
    
    // Parse the result right after loading
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        print(mutableData)
        _ = NSString(data: mutableData as Data, encoding: String.Encoding.utf8.rawValue)
        let xmlParser = XMLParser(data: mutableData as Data)
        xmlParser.delegate = self
        xmlParser.parse()
        xmlParser.shouldResolveExternalEntities = true
    }
    
    // NSXMLParserDelegate
    
    // Operation to do when a new element is parsed
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print(String(format : "didStartElement / elementName %@", elementName))
        if elementName == "ValidateTSheetKioskAdminLoginResult" {
            self.loginResult = true
            self.foundCharacters = ""
        }
    }
    
    // Operations to do for each element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(String(format : "foundCharacters / value %@", string))
        self.foundCharacters += string
        if self.loginResult == true {
//            KRProgressHUD.dismiss()
            loaderEnd()
            if let dataFromString = foundCharacters.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do{
                 let response = try JSON(data: dataFromString)
//                print("Jsondatatest->",response)
                    let json = try JSON(data: dataFromString)
                    print("Jsondatatest->",json)
                    /*if let username = json[0]["user"]["name"].string {
                        //Now you got your value
                    } */
                    if let status = json["status"].string{
                        if status == "true"{
                            print("status test",status)
                            UserSingletonModel.sharedInstance.CompanyName = json["UserLogin"][0]["CompanyName"].string
                            UserSingletonModel.sharedInstance.PayableClerkYN = json["UserLogin"][0]["PayableClerkYN"].int
                            UserSingletonModel.sharedInstance.UserID = json["UserLogin"][0]["UserID"].int
                            UserSingletonModel.sharedInstance.AdminYN = json["UserLogin"][0]["AdminYN"].int
                            UserSingletonModel.sharedInstance.SupervisorId = json["UserLogin"][0]["SupervisorId"].int
                            UserSingletonModel.sharedInstance.SupervisorYN = json["UserLogin"][0]["SupervisorYN"].int
                            UserSingletonModel.sharedInstance.UserName = json["UserLogin"][0]["UserName"].string
                            UserSingletonModel.sharedInstance.PwdSetterId = json["UserLogin"][0]["PwdSetterId"].int
                            UserSingletonModel.sharedInstance.CompID = json["UserLogin"][0]["CompID"].int
                            UserSingletonModel.sharedInstance.CorpID = json["UserLogin"][0]["CorpID"].string
                            UserSingletonModel.sharedInstance.Msg = json["UserLogin"][0]["Msg"].string
                            UserSingletonModel.sharedInstance.EmailId = json["UserLogin"][0]["EmailId"].string
                            UserSingletonModel.sharedInstance.UserRole = json["UserLogin"][0]["UserRole"].string
                            UserSingletonModel.sharedInstance.UserType = json["UserLogin"][0]["UserType"].string
                            UserSingletonModel.sharedInstance.FinYearID = json["UserLogin"][0]["FinYearID"].string
                            UserSingletonModel.sharedInstance.PurchaseYN = json["UserLogin"][0]["PurchaseYN"].int
                            UserSingletonModel.sharedInstance.PayrollClerkYN = json["UserLogin"][0]["PayrollClerkYN"].int
                            UserSingletonModel.sharedInstance.EmpName = json["UserLogin"][0]["EmpName"].string
                            
                            //------for sending email variables initialization, code starts---
                            UserSingletonModel.sharedInstance.EmailServer = json["UserLogin"][0]["EmailServer"].string
                            UserSingletonModel.sharedInstance.EmailServerPort = json["UserLogin"][0]["EmailServerPort"].string
                            UserSingletonModel.sharedInstance.EmailSendingUsername = json["UserLogin"][0]["EmailUsername"].string
                            UserSingletonModel.sharedInstance.EmailPassword = json["UserLogin"][0]["EmailPassword"].string
                            UserSingletonModel.sharedInstance.EmailHostAddress = json["UserLogin"][0]["EmailHostAddress"].string
                            //------for sending email variables initialization, code ends---
                            
                            //====================setting shared preference variables, code starts==============
                            if self.checkBtnYN == 1{
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.CompanyName, forKey: "CompanyName")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.PayableClerkYN, forKey: "PayableClerkYN")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.UserID, forKey: "UserID")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.AdminYN, forKey: "AdminYN")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.SupervisorId, forKey: "SupervisorId")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.SupervisorYN, forKey: "SupervisorYN")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.UserName, forKey: "UserName")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.PwdSetterId, forKey: "PwdSetterId")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.CompID, forKey: "CompID")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.CorpID, forKey: "CorpID")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.Msg, forKey: "Msg")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.EmailId, forKey: "EmailId")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.UserRole, forKey: "UserRole")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.UserType, forKey: "UserType")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.FinYearID, forKey: "FinYearID")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.PurchaseYN, forKey: "PurchaseYN")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.PayrollClerkYN, forKey: "PayrollClerkYN")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.EmpName, forKey: "EmpName")
                                
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.EmailServer, forKey: "EmailServer")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.EmailServerPort, forKey: "EmailServerPort")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.EmailSendingUsername, forKey: "EmailSendingUsername")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.EmailPassword, forKey: "EmailPassword")
                                self.sharedpreferences.set(UserSingletonModel.sharedInstance.EmailHostAddress, forKey: "EmailHostAddress")
                                
                                self.sharedpreferences.synchronize()
                            }
                            //====================setting shared preference variables, code ends==============
                            self.sharedpreferences.set(UserSingletonModel.sharedInstance.CorpID, forKey: "CorpIDForLogin")
                            self.sharedpreferences.synchronize()
                            self.performSegue(withIdentifier: "home", sender: self)
                            
                        }
                        else if status == "false"{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                        }
                    }
                    print("Company name test->",json["UserLogin"][0]["CompanyName"].string ?? "not available")
                }catch let error
                {
                    print(error)
                    loaderEnd()
                }
              
            }
        }
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
//-------code for UIView shape(rounded corners), starts-------------
extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

//-------code for UIView shape(rounded corners), ends-------------
