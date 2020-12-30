//
//  TaskSelectionViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 01/12/20.
//

import UIKit
import SwiftyJSON
import Alamofire
import Toast


struct EmployeeTimeSheetDetails{
    var CostType:String!
    var Task:String!
    var Contract:String!
    var Note:String!
    var ACSuffix:String!
    var LaborCategoryID:Int!
    var DefaultTaskYn:Int!
    var TaskID:Int!
    var LaborCategory:String!
    var Hour:String!
    var AccountCode:String!
    var CostTypeID:Int!
    var ContractID:Int!
    var tempDefault:Int!
}

class TaskSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TaskSelectionTableViewCellDelegate {
    

    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var tablevieTaskSelect: UITableView!
    @IBOutlet weak var label_emp_name: UILabel!
    var strCheck = ""
    var EmployeeTimeSheetDailyTaskListResult = false
    @IBOutlet weak var stackViewButtonBorder: UIStackView!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_done: UIButton!
    
    var mutableData = NSMutableData()
    var foundCharacters = ""
    
    var arrRes = [[String:AnyObject]]()
    var tableChildData = [EmployeeTimeSheetDetails]()
    var collectUpdatedFullData = [Any]()
    var collectUpdatedDetailsData = [Any]()
    
    var TaskHourSaveResult = false
    
    var ContractID: Int!
    var TaskId: Int!
    var LaborCatId: Int!
    var CostTypeId: Int!
    var SuffixCode: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stackViewButtonBorder.addBorder(side: .top, color: UIColor(hexFromString: "4f4f4f"), width: 1.0)
        btn_cancel.addBorder(side: .right, color: UIColor(hexFromString: "4f4f4f"), width: 1.0)
        
        label_emp_name.text = RealtimeDetectionViewController.EmployeeName!
        label_date.text = Date.getCurrentDate()
        // Do any additional setup after loading the view.
        self.tablevieTaskSelect.delegate = self
        self.tablevieTaskSelect.dataSource = self
        tablevieTaskSelect.backgroundColor = UIColor.white
        
        if UIScreen.main.bounds.size.width < 768 { //IPHONE
            tablevieTaskSelect.rowHeight = 100;
            tablevieTaskSelect.rowHeight = UITableView.automaticDimension
            tablevieTaskSelect.estimatedRowHeight = 130
        } else { //IPAD
            tablevieTaskSelect.rowHeight = 127;
            tablevieTaskSelect.rowHeight = UITableView.automaticDimension
            tablevieTaskSelect.estimatedRowHeight = 150
        }
       // tablevieTaskSelect.rowHeight = UITableView.automaticDimension
        //tablevieTaskSelect.estimatedRowHeight = 150
        
        loadData(stringCheck: "Task")
    }
    
    @IBAction func btn_done(_ sender: Any) {
      /*  print("ContractId-=>", self.ContractID!)
        print("TaskId-=>", self.TaskId!)
        print("LaborCatId-=>", self.LaborCatId!)
        print("CostTypeId-=>", self.CostTypeId!)
        print("SuffixCode-=>", self.SuffixCode!) */
        
//        self.performSegue(withIdentifier: "homemain", sender: nil)
        Save(stringCheck: "Save", ContractID: self.ContractID!, TaskId: self.TaskId!, LaborCatId: self.LaborCatId!, CostTypeId: self.CostTypeId!, SuffixCode: self.SuffixCode!)
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
//        self.performSegue(withIdentifier: "homemain", sender: nil)
        Save(stringCheck: "Save", ContractID: self.ContractID!, TaskId: self.TaskId!, LaborCatId: self.LaborCatId!, CostTypeId: self.CostTypeId!, SuffixCode: self.SuffixCode!)
    }
    
    
    //-----tableview code starts
    
    func TaskSelectionTableViewCellDidTapAddOrView(_ sender: TaskSelectionTableViewCell) {
        guard let tappedIndexPath = tablevieTaskSelect.indexPath(for: sender) else {return}
        var dict = tableChildData[tappedIndexPath.row]
        for i in 0..<tableChildData.count{
            if i == tappedIndexPath.row{
                tableChildData[i].DefaultTaskYn = 1
            }else{
                tableChildData[i].DefaultTaskYn = 0
            }
        }
        self.ContractID = dict.ContractID!
        self.TaskId = dict.TaskID!
        self.LaborCatId = dict.LaborCategoryID!
        self.CostTypeId = dict.CostTypeID!
        self.SuffixCode = dict.ACSuffix!
        print("ContractId-=>", self.ContractID!)
        print("TaskId-=>", self.TaskId!)
        tablevieTaskSelect.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TaskSelectionTableViewCell
        cell.delegate = self
        
        var dict = tableChildData[indexPath.row]
        
        /*cell.label_contract.text = dict["Contract"] as? String
        cell.label_labour_category.text = dict["LaborCategory"] as? String
        cell.label_hour.text = dict["Hour"] as? String
        
        if dict["DefaultTaskYn"] as? Int == 1{
            cell.label_account_code.text = "\(String(describing: dict["AccountCode"] as? String)) (Default)"
            cell.btn_radio.isSelected = true
        }else if dict["DefaultTaskYn"] as? Int == 0{
            cell.label_account_code.text = dict["AccountCode"] as? String
            cell.btn_radio.isSelected = false
        }*/
        cell.label_contract.text = dict.Contract
        cell.label_labour_category.text = dict.LaborCategory
        cell.label_hour.text = dict.Hour
        
       
        if dict.DefaultTaskYn == 1{
            if dict.tempDefault == 1{
                var attrs2: [NSAttributedString.Key : NSObject]!
                if UIScreen.main.bounds.size.width < 768 { //IPHONE
                 attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.red]
                }else { //Ipad
                    attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.red]
                }
                let attributedString1 = NSMutableAttributedString(string: dict.AccountCode)
                let attributedString2 = NSMutableAttributedString(string:" (Default)", attributes:attrs2)
                attributedString1.append(attributedString2)
                
//            cell.label_account_code.text = "\(String(describing: dict.AccountCode!)) (Default)"
                
                cell.label_account_code.attributedText = attributedString1
            }else{
                cell.label_account_code.text = dict.AccountCode
            }
            cell.btn_radio.isSelected = true
            
            self.ContractID = dict.ContractID!
            self.TaskId = dict.TaskID!
            self.LaborCatId = dict.LaborCategoryID!
            self.CostTypeId = dict.CostTypeID!
            self.SuffixCode = dict.ACSuffix!
            
        }else if dict.DefaultTaskYn == 0{
            if dict.tempDefault == 1{
                var attrs2: [NSAttributedString.Key : NSObject]!
                if UIScreen.main.bounds.size.width < 768 { //IPHONE
                 attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.red]
                }else { //Ipad
                    attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.red]
                }
                let attributedString1 = NSMutableAttributedString(string: dict.AccountCode)
                let attributedString2 = NSMutableAttributedString(string:" (Default)", attributes:attrs2)
                attributedString1.append(attributedString2)
                
//                cell.label_account_code.text = "\(String(describing: dict.AccountCode!)) (Default)"
                cell.label_account_code.attributedText = attributedString1
                cell.btn_radio.isSelected = false
            }else{
            cell.label_account_code.text = dict.AccountCode
            cell.btn_radio.isSelected = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let indexPath = tableView.indexPathForSelectedRow
        var dict = tableChildData[indexPath.row]
        for i in 0..<tableChildData.count{
            if i == indexPath.row{
                tableChildData[i].DefaultTaskYn = 1
            }else{
                tableChildData[i].DefaultTaskYn = 0
            }
        }
        self.ContractID = dict.ContractID!
        self.TaskId = dict.TaskID!
        self.LaborCatId = dict.LaborCategoryID!
        self.CostTypeId = dict.CostTypeID!
        self.SuffixCode = dict.ACSuffix!
        print("ContractId-=>", self.ContractID!)
        print("TaskId-=>", self.TaskId!)
        tableView.reloadData()
        
    }
    
    //-----tableview code ends

    
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

//--------to get colorstatus from api, code starts-------
extension TaskSelectionViewController: XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    func loadData(stringCheck:String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><EmployeeTimeSheetDailyTaskList xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserID>\(RealtimeDetectionViewController.PersonId!)</UserID><deviceType>1</deviceType><EmpType>MAIN</EmpType></EmployeeTimeSheetDailyTaskList></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=EmployeeTimeSheetDailyTaskList")
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
    func Save(stringCheck: String, ContractID: Int, TaskId: Int, LaborCatId: Int, CostTypeId: Int, SuffixCode: String){
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><TaskHourSave xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><UserId>\(RealtimeDetectionViewController.PersonId!)</UserId><UserType>%@</UserType><ContractId>\(ContractID)</ContractId><TaskId>\(TaskId)</TaskId><LaborCatId>\(LaborCatId)</LaborCatId><CostTypeId>\(CostTypeId)</CostTypeId><SuffixCode>%@</SuffixCode></TaskHourSave></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing: "MAIN"), String(describing: SuffixCode))
        
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
//        print(String(format : "didStartElement / elementName %@", elementName))
        /* if elementName == "SubordinateListTimeSheetStatusResult"{
         self.SubordinateListTimeSheetStatusResult = true
         }*/ //----will not work for get method
        if elementName == "EmployeeTimeSheetDailyTaskListResult"{
            self.EmployeeTimeSheetDailyTaskListResult = true
            self.foundCharacters = ""
        }
        if elementName == "TaskHourSaveResult"{ //--for save
            self.TaskHourSaveResult = true
        }
        
    }

    // Operations to do for each element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        print(String(format : "foundCharacters / value %@", string))
        loaderStart()
        self.foundCharacters += string
        if strCheck == "Task"{
            if EmployeeTimeSheetDailyTaskListResult == true{
                loaderEnd()
                if let dataFromString = foundCharacters.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("EmployeeTimeSheetDetails->",json)
                        
                        if let resData = json["EmployeeTimeSheetDetails"].arrayObject{
                            self.arrRes = resData as! [[String:AnyObject]]
                        }
                        
                        //------newly adding----
                        for (key,value) in json["EmployeeTimeSheetDetails"]{
                            var data = EmployeeTimeSheetDetails()
                            data.CostType = value["CostType"].stringValue
                            data.Task = value["Task"].stringValue
                            data.Contract = value["Contract"].stringValue
                            data.Note = value["Note"].stringValue
                            data.ACSuffix = value["ACSuffix"].stringValue
                            data.LaborCategoryID = value["LaborCategoryID"].intValue
                            data.DefaultTaskYn = value["DefaultTaskYn"].intValue
                            data.TaskID = value["TaskID"].intValue
                            data.LaborCategory = value["LaborCategory"].stringValue
                            data.Hour = value["Hour"].stringValue
                            data.AccountCode = value["AccountCode"].stringValue
                            data.CostTypeID = value["CostTypeID"].intValue
                            data.ContractID = value["ContractID"].intValue
                            if value["DefaultTaskYn"].intValue == 1{
                                data.tempDefault = 1
                            }else{
                                data.tempDefault = 0
                            }
                            tableChildData.append(data)
                        }
                        //------newly adding ends-----
                        
                        if arrRes.count>0 {
                            tablevieTaskSelect.reloadData()
                        }else{
                            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.tablevieTaskSelect.bounds.size.width, height: self.tablevieTaskSelect.bounds.size.height))
                            noDataLabel.text          = "No Data to show"
                            noDataLabel.textColor     = UIColor.black
                            noDataLabel.textAlignment = .center
                            self.tablevieTaskSelect.backgroundView  = noDataLabel
                            self.tablevieTaskSelect.separatorStyle  = .none
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        print(error)
                    }
                    
                }
            }
        }
        if strCheck == "Save"{
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
                                
                                self.performSegue(withIdentifier: "homemain", sender: nil)
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
};
extension NSMutableAttributedString {

    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)

        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)

        // Swift 4.1 and below
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }

}

