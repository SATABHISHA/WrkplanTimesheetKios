//
//  AttendanceRecordViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 01/12/20.
//

import UIKit
import SwiftyJSON
import Alamofire
import Toast

class AttendanceRecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var label_emp_name: UILabel!
    @IBOutlet weak var btn_select_task: DesignableButton!
    @IBOutlet weak var btn_leave_balance: DesignableButton!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_time: UILabel!
    @IBOutlet weak var label_checked_in: UILabel!
    
    var strCheck = ""
    var LeaveBalanceResult = false
    var mutableData = NSMutableData()
    var foundCharacters = ""
    
    var TaskHourSaveResult = false
    
    //---Declaring shared preferences----
    let sharedpreferences=UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label_emp_name.text = RealtimeDetectionViewController.EmployeeName!
        
        self.tableViewLeaveBalance.delegate = self
        self.tableViewLeaveBalance.dataSource = self
        tableViewLeaveBalance.backgroundColor = UIColor.white
        
        if sharedpreferences.object(forKey: "TasklistYN") as! Int == 0 {
            btn_select_task.isHidden = true
        }
        if sharedpreferences.object(forKey: "LeaveBalanceYN") as! Int == 0 {
            btn_leave_balance.isHidden = true
        }
        
        label_date.text = Date.getCurrentDateMonthForAttendanceRecordControllel()
        label_time.text = Date.getCurrentTime()
        label_checked_in.text = RecognitionOptionViewController.checkedInOut
        label_emp_name.text = RealtimeDetectionViewController.EmployeeName!
    }
    

    
    @IBAction func btn_view_select_task(_ sender: Any) {
        self.performSegue(withIdentifier: "task", sender: nil)
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
        loaderStart()
        SaveOnCancel(stringCheck: "SaveOnCancel")
//        self.performSegue(withIdentifier: "homefromattendancerecord", sender: nil)
    }
    @IBAction func btn_leave_balance(_ sender: Any) {
        loaderStart()
        loadDataOfLeaveBalance(stringCheck: "LeaveBalance")
        openLeaveBalancePopup()
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
extension AttendanceRecordViewController: XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
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
    func SaveOnCancel(stringCheck: String){
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><TaskHourSave xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType><ContractId>0</ContractId><TaskId>0</TaskId><LaborCatId>0</LaborCatId><CostTypeId>0</CostTypeId><SuffixCode>%@</SuffixCode></TaskHourSave></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN"), String(describing: ""))
        
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
        if elementName == "TaskHourSaveResult"{ //--for cancel
            self.TaskHourSaveResult = true
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

                        labelLeaveBalanceEmployeeName.text = UserSingletonModel.sharedInstance.EmpName
                        labelLeaveBalanceDate.text = "Up To \(response["LeaveDateUpto"].stringValue)"
                        
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
                                self.performSegue(withIdentifier: "homefromattendancerecord", sender: nil)
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
    }
}
