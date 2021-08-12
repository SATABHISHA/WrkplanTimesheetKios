//
//  RecognitionOptionViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 01/12/20.
//

import UIKit
import SwiftyJSON
import Alamofire
import Toast

struct Objects {
    var sectionName : String!
    var sectionObjects : String!
}
class RecognitionOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var StackViewInOutTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var StackViewInOutLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var label_punch_in_break_title: UILabel!
    @IBOutlet weak var label_punch_in_break_caption: UILabel!
    
    @IBOutlet weak var custom_btn_checkin: DesignableButton!
    @IBOutlet weak var custom_btn_check_out: DesignableButton!
    @IBOutlet weak var custom_btn_select_task: DesignableButton!
    @IBOutlet weak var custom_label_select_task: UILabel!
    
    @IBOutlet weak var custom_btn_select_task_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var custom_btn_cancel: DesignableButton!
    @IBOutlet weak var custom_btn_view_select: UILabel!
    @IBOutlet weak var custom_label_leavebalance: UILabel!
    @IBOutlet weak var custom_btn_leavebalance: DesignableButton!
    
    @IBOutlet weak var custom_btn_leavebalance_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var custom_label_cancel: UILabel!
    @IBOutlet weak var label_emp_name: UILabel!
    @IBOutlet weak var label_emp_id: UILabel!
    @IBOutlet weak var label_supervisor1: UILabel!
    @IBOutlet weak var label_supervisor2: UILabel!
    @IBOutlet weak var label_emp_name_title: UILabel!
    @IBOutlet weak var label_supervisor1_title: UILabel!
    @IBOutlet weak var label_supervisor2_title: UILabel!
    
    @IBOutlet weak var stackview_height: NSLayoutConstraint!
    
    @IBOutlet weak var constraint_view_select_top: NSLayoutConstraint!
    
    @IBOutlet weak var constraint_leavebalance_top: NSLayoutConstraint!
    var strCheck = ""
    var LeaveBalanceResult = false
    var SaveAttendanceResult = false
    var GetAttendanceNextActionResult = false
    var TaskHourSaveResult = false
    var TaskHourUpdateResult = false
    var TaskHourSubmitResult = false
    var mutableData = NSMutableData()
    var foundCharacters = ""
    
    static var checkedInOut: String!
    static var punch_out_break: String!
    
    var next_action: String!
    
    //---Declaring shared preferences----
    let sharedpreferences=UserDefaults.standard
    
    static var attendance_id: Int?, EmployeeAssignmentID: Int?, IsInOutButtonHit: Bool! //added on 12-Aug-2021
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //--added on 12-Aug-2021, code starts--
        RecognitionOptionViewController.attendance_id = 0
        RecognitionOptionViewController.EmployeeAssignmentID = 0
        RecognitionOptionViewController.IsInOutButtonHit = false
        //--added on 12-Aug-2021, code ends--
        
        if sharedpreferences.object(forKey: "AttendanceYN") as! Int == 0 {
            stackview_height.constant = 0
            
            custom_btn_checkin.isHidden = true
            custom_btn_check_out.isHidden = true
            
            label_custom_button_punchout.isHidden = true
            label_custom_button_punchout.isHidden = true
            label_custom_btn_break.isHidden = true
            label_punch_in_break_title.isHidden = true
            label_punch_in_break_caption.isHidden = true
        }
        self.tableViewLeaveBalance.delegate = self
        self.tableViewLeaveBalance.dataSource = self
        tableViewLeaveBalance.backgroundColor = UIColor.white
        
        
        label_emp_name.text = "Hello \n \(RealtimeDetectionViewController.EmployeeName!)"
        label_supervisor1.text = "\(RealtimeDetectionViewController.Supervisor1!)"
        label_supervisor2.text = "\(RealtimeDetectionViewController.Supervisor2!)"
        label_emp_id.text = "\(RealtimeDetectionViewController.PersonId!)"
        
       /* label_emp_name_title.setLeftPaddingPoints(10)
        label_supervisor1_title.setLeftPaddingPoints(10)
        label_supervisor2_title.setLeftPaddingPoints(10)*/
        
        CheckButtonInOut(stringCheck: "Check")
        
        /* if sharedpreferences.object(forKey: "TasklistYN") as! Int == 0 {
         custom_btn_select_task.isHidden = true
         custom_label_select_task.isHidden = true
         }
         if sharedpreferences.object(forKey: "LeaveBalanceYN") as! Int == 0 {
         custom_label_leavebalance.isHidden = true
         custom_btn_leavebalance.isHidden = true
         } */
        //Chekin onclick
        let tapGestureRecognizerCheckinView = UITapGestureRecognizer(target: self, action: #selector(ChecknView(tapGestureRecognizer:)))
        custom_btn_checkin.isUserInteractionEnabled = true
        custom_btn_checkin.addGestureRecognizer(tapGestureRecognizerCheckinView)
        
        //Chekin onclick
        let tapGestureRecognizerCheckOutView = UITapGestureRecognizer(target: self, action: #selector(CheckOutView(tapGestureRecognizer:)))
        custom_btn_check_out.isUserInteractionEnabled = true
        custom_btn_check_out.addGestureRecognizer(tapGestureRecognizerCheckOutView)
        
        //Leave Balance onclick
        let tapGestureRecognizerLeaveBalanceView = UITapGestureRecognizer(target: self, action: #selector(LeaveBalanceView(tapGestureRecognizer:)))
        custom_label_leavebalance.isUserInteractionEnabled = true
        custom_label_leavebalance.addGestureRecognizer(tapGestureRecognizerLeaveBalanceView)
        
        //View Select task onclick
        let tapGestureRecognizerTaskSelectView = UITapGestureRecognizer(target: self, action: #selector(TaskSelectView(tapGestureRecognizer:)))
        custom_btn_select_task.isUserInteractionEnabled = true
        custom_btn_select_task.addGestureRecognizer(tapGestureRecognizerTaskSelectView)
        
        //View Cancel onclick
        let tapGestureRecognizerCancelView = UITapGestureRecognizer(target: self, action: #selector(CancelView(tapGestureRecognizer:)))
        custom_btn_cancel.isUserInteractionEnabled = true
        custom_btn_cancel.addGestureRecognizer(tapGestureRecognizerCancelView)
        
        //View Punchout onclick
        let tapGestureRecognizerPunchOutView = UITapGestureRecognizer(target: self, action: #selector(PunchOutViewOnClick(tapGestureRecognizer:)))
        view_custom_btn_punchout.isUserInteractionEnabled = true
        view_custom_btn_punchout.addGestureRecognizer(tapGestureRecognizerPunchOutView)
        
        //View Break onclick
        let tapGestureRecognizerBreakView = UITapGestureRecognizer(target: self, action: #selector(BreakViewOnClick(tapGestureRecognizer:)))
        view_custom_btn_break.isUserInteractionEnabled = true
        view_custom_btn_break.addGestureRecognizer(tapGestureRecognizerBreakView)
    }
    
    //---Checkin onclick
    @objc func ChecknView(tapGestureRecognizer: UITapGestureRecognizer){
        if next_action == "IN"{
            RecognitionOptionViewController.IsInOutButtonHit = true
            loaderStart()
            saveAttendance(stringCheck: "SaveAttendance", saveInOut: "IN", InOutText: "PUNCHED_IN")
            RecognitionOptionViewController.checkedInOut = "You are Punched IN"
        }else if next_action == "OUT"{
            loaderStart()
            saveAttendance(stringCheck: "SaveAttendance", saveInOut: "OUT", InOutText: "BREAK_STARTS")
            print("break tapped", next_action!)
            RecognitionOptionViewController.checkedInOut = "You are on Break!"
            RecognitionOptionViewController.punch_out_break = "break"
            
        }
        //        self.performSegue(withIdentifier: "attendancerecord", sender: nil)
        
    }
    //---CheckOut onclick
    @objc func CheckOutView(tapGestureRecognizer: UITapGestureRecognizer){
        //        loaderStart()
        openPunchOutPopup()
        /*  saveAttendance(stringCheck: "SaveAttendance", saveInOut: "OUT", InOutText: "PUNCHED_OUT")
         RecognitionOptionViewController.checkedInOut = "You are Checked OUT" */
        //        self.performSegue(withIdentifier: "attendancerecord", sender: nil)
    }
    //---LeaveBlance onclick
    @objc func LeaveBalanceView(tapGestureRecognizer: UITapGestureRecognizer){
        loaderStart()
        loadDataOfLeaveBalance(stringCheck: "LeaveBalance")
        openLeaveBalancePopup()
        
    }
    
    //---View Select task onclick
    @objc func TaskSelectView(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "task", sender: nil)
        
    }
    
    //---View Cancel onclick
    @objc func CancelView(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "homefromrecognizeoption", sender: nil)
        if next_action == "IN"{
            self.performSegue(withIdentifier: "homefromrecognizeoption", sender: nil)
            //        saveAttendance(stringCheck: "SaveAttendance", saveInOut: "IN", InOutText: "PUNCHED_IN")
            
        }else if next_action == "OUT"{
            loaderStart()
            SaveOnCancel(stringCheck: "SaveOnCancel")
            
        }
        
    }
    
    
    //-------------table code starts--------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        objectArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecognitionOptionViewLeaveBalanceTableViewCell
        
        cell.labelHolidayName.text = objectArray[indexPath.row].sectionName
        cell.labelHrs.text = objectArray[indexPath.row].sectionObjects
        return cell
    }
    //----------table code ends--------
    //===============FormDialogLeaveBalance Popup code starts===================
    @IBOutlet weak var tableViewLeaveBalance: UITableView!
    var arrRes = [[String:AnyObject]]() // for leave balance
    var dict = [String:Any]() // for leave balance
    var objectArray = [Objects]() // for leave balance
    @IBOutlet var viewLeaveBalancePopup: UIView!
    @IBOutlet weak var labelLeaveBalanceEmployeeName: UILabel!
    @IBOutlet weak var labelLeaveBalanceDate: UILabel!
    
    @IBOutlet weak var btnLeaveBalanceOk: UIButton!
    @IBAction func btnLeaveBalanceOk(_ sender: Any) {
        cancelLeaveBalancePopup()
    }
    
    func openLeaveBalancePopup(){
        blurEffect()
        self.view.addSubview(viewLeaveBalancePopup)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewLeaveBalancePopup.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewLeaveBalancePopup.center = self.view.center
        viewLeaveBalancePopup.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewLeaveBalancePopup.alpha = 0
        viewLeaveBalancePopup.sizeToFit()
        
        labelLeaveBalanceEmployeeName.text = RealtimeDetectionViewController.EmployeeName!
        
        btnLeaveBalanceOk.addBorder(side: .top, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
        UIView.animate(withDuration: 0.3){
            self.viewLeaveBalancePopup.alpha = 1
            self.viewLeaveBalancePopup.transform = CGAffineTransform.identity
        }
        tableViewLeaveBalance.reloadData()
    }
    func cancelLeaveBalancePopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewLeaveBalancePopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewLeaveBalancePopup.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewLeaveBalancePopup.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //===============FormDialogLeaveBalance Popup code ends===================
    
    //===============FormDialogPunchOut Popup code starts===================
    
    @IBOutlet weak var btn_break: UIButton!
    @IBOutlet weak var btn_punchout: UIButton!
    
    @IBOutlet weak var stackViewButtonborder: UIStackView!
    @IBOutlet weak var view_custom_btn_punchout: UIView!
    @IBOutlet weak var label_custom_button_punchout: UILabel!
    @IBOutlet weak var view_custom_btn_break: UIView!
    @IBOutlet weak var label_custom_btn_break: UILabel!
    
    @IBOutlet var viewPunchOutPopup: UIView!
    @IBOutlet weak var viewChildPunchOut: UIView!
    
    //---View Punchout onclick
    @objc func PunchOutViewOnClick(tapGestureRecognizer: UITapGestureRecognizer){
        RecognitionOptionViewController.punch_out_break = "out"
        loaderStart()
        cancelPunchOutPopup()
        saveAttendance(stringCheck: "SaveAttendance", saveInOut: "OUT", InOutText: "PUNCHED_OUT")
        RecognitionOptionViewController.checkedInOut = "Good Bye!"
        
        RecognitionOptionViewController.punch_out_break = "out"
        
    }
    
    //---View Break onclick
    @objc func BreakViewOnClick(tapGestureRecognizer: UITapGestureRecognizer){
        RecognitionOptionViewController.punch_out_break = "break"
        loaderStart()
        cancelPunchOutPopup()
        saveAttendance(stringCheck: "SaveAttendance", saveInOut: "OUT", InOutText: "BREAK_STARTS")
        print("break tapped", next_action!)
        RecognitionOptionViewController.checkedInOut = "You are on Break!"
        
        
    }
    
    func openPunchOutPopup(){
        blurEffect()
        self.view.addSubview(viewPunchOutPopup)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        viewPunchOutPopup.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewPunchOutPopup.center = self.view.center
        viewPunchOutPopup.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewPunchOutPopup.alpha = 0
        viewPunchOutPopup.sizeToFit()
        

        stackViewButtonborder.addBorder(side: .top, color: UIColor(hexFromString: "7F7F7F"), width: 1)
//        view_custom_btn_punchout.addBorder(side: .top, color: UIColor(hexFromString: "4f4f4f"), width: 1)
        view_custom_btn_punchout.addBorder(side: .right, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
        
        
        var attrsPunchOutBreak1 : [NSAttributedString.Key : NSObject]!
        var attrsPunchOutBreak2 : [NSAttributedString.Key : NSObject]!
        
        if UIScreen.main.bounds.size.width < 768 { //IPHONE
            attrsPunchOutBreak1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 23), NSAttributedString.Key.foregroundColor : UIColor.black]
            attrsPunchOutBreak2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor(hexFromString: "5B5B5B")]
            
            
        }else { //Ipad
            attrsPunchOutBreak1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 23), NSAttributedString.Key.foregroundColor : UIColor.black]
            attrsPunchOutBreak2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor(hexFromString: "5B5B5B")]
        }
        let attributedStringPunchOut1 = NSMutableAttributedString(string: "Yes \n", attributes: attrsPunchOutBreak1)
        let attributedStringPunchOut2 = NSMutableAttributedString(string:"I will Punch Out", attributes:attrsPunchOutBreak2)
        
        let attributedStringBreak1 = NSMutableAttributedString(string: "No \n", attributes: attrsPunchOutBreak1)
        let attributedStringBreak2 = NSMutableAttributedString(string:"I want to take a Break", attributes:attrsPunchOutBreak2)
        
        attributedStringPunchOut1.append(attributedStringPunchOut2)
        attributedStringBreak1.append(attributedStringBreak2)
        
        label_custom_button_punchout.numberOfLines = 0
        label_custom_button_punchout.attributedText = attributedStringPunchOut1
        
        label_custom_btn_break.numberOfLines = 0
        label_custom_btn_break.attributedText = attributedStringBreak1
        
        
        
        UIView.animate(withDuration: 0.3){
            self.viewPunchOutPopup.alpha = 1
            self.viewPunchOutPopup.transform = CGAffineTransform.identity
        }
        
    }
    func cancelPunchOutPopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewPunchOutPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewPunchOutPopup.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewPunchOutPopup.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //===============FormDialogPunchOut Popup code ends===================
    
    // ====================== Blur Effect Defiend START ================= \\
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
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
    // ====================== Blur Effect function calling code ends =================
    
};
// MARK: - XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate
//--------to get colorstatus from api, code starts-------
extension RecognitionOptionViewController: XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    func loadDataOfLeaveBalance(stringCheck:String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><LeaveBalance xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><EmployeeId>\(RealtimeDetectionViewController.PersonId!)</EmployeeId><DateToday>%@</DateToday></LeaveBalance></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: Date.getCurrentDate()))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=LeaveBalance")
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
    
    func CheckButtonInOut(stringCheck:String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><GetAttendanceNextAction xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType></GetAttendanceNextAction></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN"))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=GetAttendanceNextAction")
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
    
    func saveAttendance(stringCheck: String, saveInOut: String, InOutText: String ) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><SaveAttendance xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType><InOut>%@</InOut><InOutText>%@</InOutText></SaveAttendance></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN"), String(describing: saveInOut), String(describing: InOutText))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=SaveAttendance")
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
    
    func SaveOnCancel(stringCheck: String){
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
//        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><TaskHourSave xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType><ContractId>0</ContractId><TaskId>0</TaskId><LaborCatId>0</LaborCatId><CostTypeId>0</CostTypeId><SuffixCode>%@</SuffixCode></TaskHourSave></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN"), String(describing: ""))  //--commented on 12-Aug-2021
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><TaskHourSave xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType><EmployeeAssignmentId>\(RecognitionOptionViewController.EmployeeAssignmentID!)</EmployeeAssignmentId><KioskAttendanceId>\(RecognitionOptionViewController.attendance_id!)</KioskAttendanceId></TaskHourSave></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN")) //--added on 12-Aug-2021
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=TaskHourSave")
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
    
    func SaveonBreak(stringCheck: String){
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><TaskHourUpdate xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType></TaskHourUpdate></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN"), String(describing: ""))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=TaskHourUpdate")
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
    
    func SaveonPunchOut(stringCheck: String){
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><TaskHourSubmit xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType></TaskHourSubmit></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN"), String(describing: ""))
        
        var soapMessage = text
//        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=TaskHourUpdate") //--commented on 25th feb
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=TaskHourSubmit") //--added on 25th feb
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
    // Operation to do when a new element is parsed
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print(String(format : "didStartElement / elementName %@", elementName))
        /* if elementName == "SubordinateListTimeSheetStatusResult"{
         self.SubordinateListTimeSheetStatusResult = true
         }*/ //----will not work for get method
        if elementName == "LeaveBalanceResult"{
            self.LeaveBalanceResult = true
        }
        if elementName == "SaveAttendanceResult" {
            self.SaveAttendanceResult = true
            //            self.foundCharacters = ""
        }
        if elementName == "GetAttendanceNextActionResult" {
            self.GetAttendanceNextActionResult = true
            //            self.foundCharacters = ""
        }
        if elementName == "TaskHourSaveResult"{ //--for cancel
            self.TaskHourSaveResult = true
        }
        if elementName == "TaskHourUpdateResult"{ // -- for break
            self.TaskHourUpdateResult = true
        }
        if elementName == "TaskHourSubmitResult"{ //---for punch out
            self.TaskHourSubmitResult = true
        }
        
    }
    
    // Operations to do for each element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(String(format : "foundCharacters / value %@", string))
        
        if strCheck == "LeaveBalance"{
            if LeaveBalanceResult == true{
                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        
                        
                        guard let json = try? JSONSerialization.jsonObject(with: dataFromString, options: []) else{return}
                        //                        print("getJsonDataforLeaveBalance=-=->",json)
                        if(!objectArray.isEmpty){
                            objectArray.removeAll()
                        }
                        
//                        labelLeaveBalanceEmployeeName.text = UserSingletonModel.sharedInstance.EmpName
//                        labelLeaveBalanceDate.text = "Up To \(response["LeaveDateUpto"].stringValue)"
                        
                        //-------date formatter code starts------
                        let dateFormatterGet = DateFormatter()
                //        dateFormatterGet.dateFormat = "MM/dd/yyyy hh:mm:ss a"
//                        dateFormatterGet.dateFormat = "dd/MM/yyyy" //--for test version //commented on 19th April
                        dateFormatterGet.dateFormat = "MM/dd/yyyy" //--changed on 19th April 21
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "dd-MMM-yyyy"
                        
                        
                        let date = dateFormatterGet.date(from: (response["LeaveDateUpto"].stringValue))
                        print("DateTest-=>",response["LeaveDateUpto"].stringValue)
                        //-------date formatter code ends------
                        labelLeaveBalanceDate.text = "Up To \(dateFormatterPrint.string(from: date!))"
                        
                        if let dictionary = json as? [String: Any] {
                            dict = (dictionary["LeaveBalanceItems"] as? [String:Any])!
                        }
                        for (key,value) in dict{
                            //                            print("\(key) -> \(value)")
                            objectArray.append(Objects(sectionName: key, sectionObjects: value as? String))
                        }
                        if dict.count>0 {
                            tableViewLeaveBalance.reloadData()
                        }else{
                            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableViewLeaveBalance.bounds.size.width, height: self.tableViewLeaveBalance.bounds.size.height))
                            noDataLabel.text          = "No Data to show"
                            noDataLabel.textColor     = UIColor.black
                            noDataLabel.textAlignment = .center
                            self.tableViewLeaveBalance.backgroundView  = noDataLabel
                            self.tableViewLeaveBalance.separatorStyle  = .none
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        print(error)
                    }
                    
                }
            }
        }
        if strCheck == "SaveAttendance"{
            if self.SaveAttendanceResult == true{
                //                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("DataSave->",json)
                        RecognitionOptionViewController.attendance_id = json["attendance_id"].intValue //--added on 12-Aug-2021
                        if json["response"]["status"].stringValue == "true"{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["response"]["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            if self.next_action == "IN"{
                                self.performSegue(withIdentifier: "attendancerecord", sender: nil)
                            }else{
                                self.performSegue(withIdentifier: "punch", sender: nil)
                            }
                            
                            //--added on 23rd dec
                            if RecognitionOptionViewController.punch_out_break == "break"{
                                SaveonBreak(stringCheck: "SaveOnBreak")
                            }else if RecognitionOptionViewController.punch_out_break == "out"{
                                SaveonPunchOut(stringCheck: "SaveOnPunchOut")
                            }
                            
                            loaderEnd()
                        }else{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            loaderEnd()
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        loaderEnd()
                        print(error)
                    }
                    
                }
            }
        }
        if strCheck == "Check"{
            loaderStart()
            if self.GetAttendanceNextActionResult == true{
                //                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("Check->",json)
                        if json["next_action"].stringValue == "IN"{
                            custom_btn_checkin.isHidden = false
                            custom_btn_check_out.isHidden = true
                            var style = ToastStyle()
                            
                            self.next_action = "IN"
                            
                            custom_btn_select_task.isHidden = true
                            custom_label_select_task.isHidden = true
                            
                            custom_btn_select_task_constraint_height.constant = 0
                            
                            //---tasklist,viewleavebalance visibility on/off
                            if sharedpreferences.object(forKey: "LeaveBalanceYN") as! Int == 0 {
                                custom_label_leavebalance.isHidden = true
                                custom_btn_leavebalance.isHidden = true
                                
                                custom_btn_leavebalance_constraint_height.constant = 0
                            }
                            
                            loaderEnd()
                        }else if json["next_action"].stringValue == "OUT"{
                            self.next_action = "OUT"
                            
                            custom_btn_checkin.isHidden = false
                            custom_btn_check_out.isHidden = false
                            
                            if UIScreen.main.bounds.size.width < 768 { //IPHONE
//                                StackViewInOutTrailingConstraint.constant = 25 Commented as per discussion
//                                StackViewInOutLeadingConstraint.constant = 25
                                
                                label_punch_in_break_title.text = "Take a"
                                label_punch_in_break_caption.text = "BREAK"
                            } else { //IPAD
//                                StackViewInOutTrailingConstraint.constant = 100
//                                StackViewInOutLeadingConstraint.constant = 100
                                
                                label_punch_in_break_title.text = "Take a"
                                label_punch_in_break_caption.text = "BREAK"
                            }
                            
                            //---tasklist,viewleavebalance visibility on/off
                            if sharedpreferences.object(forKey: "TasklistYN") as! Int == 0 {
                                custom_btn_select_task.isHidden = true
                                custom_label_select_task.isHidden = true
                                
//                                custom_btn_select_task_constraint_height.constant = 0
                            }else if sharedpreferences.object(forKey: "TasklistYN") as! Int == 1{
                                custom_btn_select_task.isHidden = false
                                custom_label_select_task.isHidden = false
                            }
                            if sharedpreferences.object(forKey: "LeaveBalanceYN") as! Int == 0 {
                                custom_label_leavebalance.isHidden = true
                                custom_btn_leavebalance.isHidden = true
                                
//                                custom_btn_leavebalance_constraint_height.constant = 0
                            } else if sharedpreferences.object(forKey: "LeaveBalanceYN") as! Int == 1 {
                                custom_label_leavebalance.isHidden = false
                                custom_btn_leavebalance.isHidden = false
                            }
                            
                            loaderEnd()
                        }else if json["next_action"].stringValue == "NA"{
                            custom_btn_checkin.isHidden = true
                            custom_btn_check_out.isHidden = true
                            custom_btn_select_task.isHidden = true
                            
                            let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
                            label.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: view.bounds.height / 2)
                            if UIScreen.main.bounds.size.width < 768 {
                                label.font = UIFont.systemFont(ofSize: 22)
                            }else{
                                label.font = UIFont.systemFont(ofSize: 36)
                            }
                            label.numberOfLines = 0
                            label.textAlignment = .center
                            label.text = "You are too early for the next working day!"
                            self.view.addSubview(label)
                            
                            loaderEnd()
                        }else{
                            custom_btn_checkin.isHidden = false
                            custom_btn_check_out.isHidden = false
                            
                            loaderEnd()
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        loaderEnd()
                        print(error)
                    }
                    
                }
            }
        }
        if strCheck == "SaveOnCancel"{
            if self.TaskHourSaveResult == true{
                //                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("DataSave->",json)
                        if json["status"].stringValue == "true"{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            
                            loaderEnd()
                            self.performSegue(withIdentifier: "homefromrecognizeoption", sender: nil)
                        }else{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            loaderEnd()
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        loaderEnd()
                        print(error)
                    }
                    
                }
            }
        }
        if strCheck == "SaveOnBreak"{
            if self.TaskHourUpdateResult == true{
                //                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("DataSave->",json)
                        if json["status"].stringValue == "true"{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            
                            //                                loaderEnd()
                            //                                self.performSegue(withIdentifier: "homefromrecognizeoption", sender: nil)
                        }else{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            //                                loaderEnd()
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        //                            loaderEnd()
                        print(error)
                    }
                    
                }
            }
        }
        if strCheck == "SaveOnPunchOut"{
            if self.TaskHourSubmitResult == true{
                //                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("DataSave->",json)
                        if json["status"].stringValue == "true"{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            
                            //                                loaderEnd()
                            //                                self.performSegue(withIdentifier: "homefromrecognizeoption", sender: nil)
                        }else{
                            var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            //                                loaderEnd()
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        //                            loaderEnd()
                        print(error)
                    }
                    
                }
            }
        }
    }
}

extension Date {
    
    static func getCurrentDate() -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        return dateFormatter.string(from: Date())
        
    }
    static func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: Date())
    }
    static func getCurrentDateMonthForAttendanceRecordControllel() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MMM-yyy"
        
        return dateFormatter.string(from: Date())
    }
}
extension UIView {

    enum ViewSide {
        case Left, Right, Top, Bottom
    }

    func addViewBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {

        let border = CALayer()
        border.backgroundColor = color

        switch side {
        case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
        }

        layer.addSublayer(border)
    }
}

