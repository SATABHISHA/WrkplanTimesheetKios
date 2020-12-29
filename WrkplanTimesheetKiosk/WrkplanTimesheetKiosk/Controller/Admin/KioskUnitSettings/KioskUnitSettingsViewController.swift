//
//  KioskUnitSettingsViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 08/12/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast

class KioskUnitSettingsViewController: UIViewController {

    @IBOutlet weak var txt_corp_id: UITextField!
    @IBOutlet weak var txt_kiosk_unit_name: UITextField!
    @IBOutlet weak var txt_device_id: UITextField!
    @IBOutlet weak var btn_faceattendance_yes: KGRadioButton!
    @IBOutlet weak var btn_faceattendance_no: KGRadioButton!
    @IBOutlet weak var btn_view_select_task_yes: KGRadioButton!
    @IBOutlet weak var btn_view_select_task_no: KGRadioButton!
    @IBOutlet weak var btn_view_leave_balance_yes: KGRadioButton!
    @IBOutlet weak var btn_view_leave_balance_no: KGRadioButton!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var stackViewbuttonBorder: UIStackView!
    
    var attendance_yn: Int = 1
    var tasklist_yn: Int = 1
    var leavebalance_yn: Int = 1
    
    //---Declaring shared preferences----
    let sharedpreferences=UserDefaults.standard
    
    var saveResult = false
    var GetKioskInfoResult = false
    var mutableData = NSMutableData()
    var foundCharacters = ""
    var strCheck = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        
        txt_device_id.text = deviceId
        txt_corp_id.text = UserSingletonModel.sharedInstance.CorpID!
        // Do any additional setup after loading the view.
        txt_device_id.isUserInteractionEnabled = false
        txt_device_id.isEnabled = false
        
        txt_corp_id.isEnabled = false
        txt_corp_id.isUserInteractionEnabled = false
        
        //----default making custom radiobutton selected yes
       /* btn_faceattendance_yes.isSelected = true
        btn_view_select_task_yes.isSelected = true
        btn_view_leave_balance_yes.isSelected = true */ //commented on 14th dec
        
        txt_corp_id.setLeftPaddingPoints(5)
        txt_kiosk_unit_name.setLeftPaddingPoints(5)
        txt_device_id.setLeftPaddingPoints(5)
        
        btn_cancel.addBorder(side: .right, color: UIColor(hexFromString: "4f4f4f"), width: 1)
        stackViewbuttonBorder.addBorder(side: .top, color: UIColor(hexFromString: "4f4f4f"), width: 1)
//        btn_cancel.layer.masksToBounds = true
        
        self.loadData(stringCheck: "Info")
    }
    

    @IBAction func btn_onclick(_ sender: KGRadioButton) {
        switch sender {
        case btn_faceattendance_yes:
            btn_faceattendance_yes.isSelected = true
            btn_faceattendance_no.isSelected = false
            
            attendance_yn = 1
            
        case btn_faceattendance_no:
            btn_faceattendance_no.isSelected = true
            btn_faceattendance_yes.isSelected = false
            
            attendance_yn = 0
            
        case btn_view_select_task_yes:
            btn_view_select_task_yes.isSelected = true
            btn_view_select_task_no.isSelected = false
            
            tasklist_yn = 1
            
        case btn_view_select_task_no:
            btn_view_select_task_no.isSelected = true
            btn_view_select_task_yes.isSelected = false
            
            tasklist_yn = 0
            
        case btn_view_leave_balance_yes:
            btn_view_leave_balance_yes.isSelected = true
            btn_view_leave_balance_no.isSelected = false
            
            leavebalance_yn = 1
            
        case btn_view_leave_balance_no:
            btn_view_leave_balance_no.isSelected = true
            btn_view_leave_balance_yes.isSelected = false
            
            leavebalance_yn = 0
            
        default:
            break
        }
    }
    
    
    @IBAction func btn_cancel(_ sender: Any) {
        self.performSegue(withIdentifier: "home", sender: nil)
    }
    
    @IBAction func btn_ok(_ sender: Any) {
        loaderStart()
        self.saveAPICall(stringCheck: "Save")
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
        self.loader.removeFromSuperview()
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

extension KioskUnitSettingsViewController: XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    func saveAPICall(stringCheck:String) {
        self.strCheck = stringCheck
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        print("deviceId-=>",deviceId!)
        
//        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><ValidateTSheetLogin xmlns='%@/'><CorpID>%@</CorpID><UserName>%@</UserName><Password>%@</Password></ValidateTSheetLogin></soap:Body></soap:Envelope>",BASE_URL, String(describing: corpId.text!),  String(describing: userName.text!), String(describing: password.text!))
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><SaveKioskInfo xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><DeviceId>%@</DeviceId><UnitName>%@</UnitName><AttendanceYn>\(self.attendance_yn)</AttendanceYn><TaskListYn>\(self.tasklist_yn)</TaskListYn><LeaveBalanceYn>\(self.leavebalance_yn)</LeaveBalanceYn> </SaveKioskInfo></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: self.txt_corp_id.text!), String(describing: deviceId!), String(describing: self.txt_kiosk_unit_name.text!))
//        <DeviceID>%@</DeviceID> , String(describing: deviceId!)
        let soapMessage = text
//        let url = NSURL(string: "\(BASE_URL)/TimesheetService.asmx?op=ValidateTSheetLogin")
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=SaveKioskInfo")
        print("url-=>", url!)
        print("attendanceyn-=>",attendance_yn)
        
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
    
    func loadData(stringCheck:String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        print("deviceid-=>",deviceId!)
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><GetKioskInfo xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><DeviceId>%@</DeviceId></GetKioskInfo></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: deviceId!))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=GetKioskInfo")
        print("url-=>", url)
        let theRequest = NSMutableURLRequest(url: url! as URL)
        let msgLength = String(soapMessage.count)
        
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(msgLength, forHTTPHeaderField: "Content-Length")
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
        if elementName == "SaveKioskInfoResult" {
            self.saveResult = true
            self.foundCharacters = ""
        }
        if elementName == "GetKioskInfoResult" {
            self.GetKioskInfoResult = true
            self.foundCharacters = ""
            }
    }
    
    // Operations to do for each element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(String(format : "foundCharacters / value %@", string))
        self.foundCharacters += string
        if strCheck == "Save"{
        if self.saveResult == true {
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
                            
                            
                            //====================setting shared preference variables, code starts==============
                            self.sharedpreferences.set(self.txt_kiosk_unit_name.text!, forKey: "UnitName")
                            self.sharedpreferences.set(self.txt_device_id.text!, forKey: "DeviceId")
                            self.sharedpreferences.set(self.attendance_yn, forKey: "AttendanceYN")
                            self.sharedpreferences.set(self.tasklist_yn, forKey: "TasklistYN")
                            self.sharedpreferences.set(self.leavebalance_yn, forKey: "LeaveBalanceYN")
                                
                                
                                self.sharedpreferences.synchronize()
                            
                            //====================setting shared preference variables, code ends==============
                            
                            self.sharedpreferences.synchronize()
                            
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                // your code here For Pushing to Another Screen
                                self.performSegue(withIdentifier: "home", sender: nil)
                            }
                            
                        }
                        else if status == "false"{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                        }
                    }
                }catch let error
                {
                    print(error)
                    loaderEnd()
                }
              
            }
        }
        }
        if strCheck == "Info"{
            if self.GetKioskInfoResult == true{
                if let dataFromString = foundCharacters.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                     let response = try JSON(data: dataFromString)
    //                print("Jsondatatest->",response)
                        let json = try JSON(data: dataFromString)
                        print("Jsondatatest->",json)
                        if json["timesheet_kiosk_id"].intValue > 0{
                            self.txt_kiosk_unit_name.text = json["unit_name"].stringValue
                            self.tasklist_yn = json["task_selection_yn"].intValue
                            self.leavebalance_yn = json["view_leave_balance_yn"].intValue
                            self.attendance_yn = json["face_attendance_yn"].intValue
                            if self.tasklist_yn == 0 {
                                btn_view_select_task_no.isSelected = true
                                btn_view_select_task_yes.isSelected = false
                            }else{
                                btn_view_select_task_no.isSelected = false
                                btn_view_select_task_yes.isSelected = true
                            }
                            
                            if self.leavebalance_yn == 0 {
                                btn_view_leave_balance_no.isSelected = true
                                btn_view_leave_balance_yes.isSelected = false
                            }else{
                                btn_view_leave_balance_no.isSelected = false
                                btn_view_leave_balance_yes.isSelected = true
                            }
                            
                            if self.attendance_yn == 0 {
                                btn_faceattendance_no.isSelected = true
                                btn_faceattendance_yes.isSelected = false
                            }else{
                                btn_faceattendance_no.isSelected = false
                                btn_faceattendance_yes.isSelected = true
                            }
                        }else {
                            self.leavebalance_yn = 1
                            self.attendance_yn = 1
                            self.tasklist_yn = 1
                            
                            btn_faceattendance_yes.isSelected = true
                            btn_view_select_task_yes.isSelected = true
                            btn_view_leave_balance_yes.isSelected = true
                        }
                    }catch let error
                    {
                        print(error)
                        loaderEnd()
                    }
                }
            }
        }
        
    }
};
extension UIView {

    public enum BorderSide {
        case top, bottom, left, right
    }

    public func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
            let border = UIView()
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = color
            self.addSubview(border)

            let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
            let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
            let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
            let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
            let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
            let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)


            switch side {
            case .top:
                NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
            case .right:
                NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
            case .bottom:
                NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
            case .left:
                NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
            }
        }
}
