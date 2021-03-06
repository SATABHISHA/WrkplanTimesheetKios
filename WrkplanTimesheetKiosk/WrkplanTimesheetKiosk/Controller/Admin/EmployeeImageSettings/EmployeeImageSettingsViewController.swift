//
//  EmployeeImageSettingsViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 08/12/20.
//

import UIKit
import SwiftyJSON
import Alamofire
import Toast

class EmployeeImageSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EmployeeImageSettingsTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var custom_btn_back: UILabel!
    @IBOutlet weak var tableviewEmployeeImageSettings: UITableView!
    
    var strCheck = ""
    var ListFacesResult = false
    var IndexFacesResult = false
    var DeleteFacesResult = false
    var CreateGalleryResult = false //--added on 21st may
    var mutableData = NSMutableData()
    var foundCharacters = ""
    
    var arrRes = [[String:AnyObject]]()
    var enroll_names: String!
    var id_person: Int!
    var aws_face_id: String!
    //-----camera variables
    let imagePicker = UIImagePickerController()
    var base64String:String!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredTableData = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //---tableiew
        self.tableviewEmployeeImageSettings.delegate = self
        self.tableviewEmployeeImageSettings.dataSource = self
        self.searchBar.delegate = self
        
        tableviewEmployeeImageSettings.backgroundColor = UIColor.white
        searchBar.searchTextField.backgroundColor = UIColor.white
        searchBar.backgroundColor = UIColor.white
        searchBar.searchTextField.textColor = UIColor.black
        if UIScreen.main.bounds.size.width < 768 { //IPHONE
            searchBar.searchTextField.font = .systemFont(ofSize: 17.0)
        }else { //Ipad
            searchBar.searchTextField.font = .systemFont(ofSize: 31.0)
        }
        
//        searchBar.searchTextField.borderColor = UIColor.lightGray
//        searchBar.searchTextField.borderWidth = 1
//        searchBar.searchTextField.cornerRadius = 10
        searchBar.layer.borderWidth = 10
        searchBar.layer.borderColor = UIColor.white.cgColor
        //---camera
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
        imagePicker.allowsEditing = false
        
        loaderStart()
        loadData(stringCheck: "ListFace")
        
        //---Dashboard OnClick
        let tapGestureRecognizerKioskDashboard = UITapGestureRecognizer(target: self, action: #selector(DesignablebtnKioskDashboard(tapGestureRecognizer:)))
        custom_btn_back.isUserInteractionEnabled = true
        custom_btn_back.addGestureRecognizer(tapGestureRecognizerKioskDashboard)
    }
    
    //---Dashboard OnClick
    @objc func DesignablebtnKioskDashboard(tapGestureRecognizer: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "home", sender: nil)
       
    }
    
    //------camera code, starts------
    public static var image_to_base64:String?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePicker.dismiss(animated: true, completion: nil)
            //                   loaderStart()
            
            //            var imageData = UIImagePNGRepresentation(pickedImage)
            var imageData = pickedImage.jpegData(compressionQuality: 0.2)
            base64String = imageData?.base64EncodedString()
            print("base64-=>",self.enroll_names!)
            
//            loaderStart() //--commented on 4t jan 21
            EnrollImage(stringCheck: "IndexFacesResult", base64ImageString: base64String!)
        }
        
    }
    //------camera code, ends------
    
    
    //--------tableview code starts-------
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredTableData = searchText.isEmpty ? arrRes : arrRes.filter({(object) -> Bool in
            let employeename = "\(object["name_first"] as! String) \(object["name_last"] as! String)"
//            guard let employee_name = employeename else {return false}
            
            return employeename.lowercased().contains(searchText.lowercased())
        })

        self.tableviewEmployeeImageSettings.reloadData()
    }

    func EmployeeImageSettingsTableViewCellAddOrRemoveDidTapAddOrView(_ sender: EmployeeImageSettingsTableViewCell) {
        guard let tappedIndexPath = tableviewEmployeeImageSettings.indexPath(for: sender) else {return}
        let rowData = filteredTableData[tappedIndexPath.row]
        self.enroll_names = "\(rowData["name_first"] as! String)-\(rowData["name_last"] as! String)"
        self.id_person = rowData["id_person"] as? Int
        print("Selected-=>",id_person!)
        print("Selected")
        if rowData["aws_action"] as! String == "enroll"{
            self.aws_face_id = rowData["aws_face_id"] as? String
            let label1 = "Do you want to Enroll face image for \(rowData["name_first"] as! String) \(rowData["name_last"] as! String)?"
            let label2 = "Tips for better Recognition result:\n1) Individual's face must be seen clearly and focused\n2) Individual's face must be at center of the camera's frame\n3) Avoid dark background"
            openEnrollPopup(label1: label1, label2: label2)
//            present(imagePicker, animated: true, completion: nil)
        }else if rowData["aws_action"] as! String == "delete"{
            self.aws_face_id = rowData["aws_face_id"] as? String
            print("delete")
            // Create Alert
         /*   var dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete?", preferredStyle: .alert)

            // Create OK button with action handler
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.DeleteImage(stringCheck: "DeleteFacesResult")
            })

            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
//                print("Cancel button tapped")
            }

            //Add OK and Cancel button to an Alert object
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)

            // Present alert message to user
            self.present(dialogMessage, animated: true, completion: nil)*/ //commented as per req on 4th jan 21
            openDetailsPopup(name: "Are you sure you want to delete?")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! EmployeeImageSettingsTableViewCell
        cell.delegate = self
        if indexPath.row == 0{
            if UIScreen.main.bounds.size.width < 768 { //IPHONE
                cell.ViewTopConstraint.constant = 1
            }else { //Ipad
                cell.ViewTopConstraint.constant = 10
            }
            
        }else{
            cell.ViewTopConstraint.constant = 1
        }
        
        let dict = filteredTableData[indexPath.row]
        cell.label_name.text = "\(dict["name_first"] as! String) \(dict["name_last"] as! String)"
        cell.label_custom_btn.layer.masksToBounds = true
        if dict["aws_action"] as? String == "enroll"{
            cell.label_enroll_status.text = "No \n Image"
            cell.label_enroll_status.textColor = UIColor(hexFromString: "9A9A9A")
            
//            cell.view_custom_btn.borderWidth = 1
            cell.view_custom_btn.cornerRadius = 5
//            cell.view_custom_btn.borderColor = UIColor(hexFromString: "626262")
            cell.label_custom_btn.text = "Enroll \n Image"
//            cell.label_custom_btn.textColor = UIColor(hexFromString: "4f4f4f") //--commented on 18th may
//            cell.label_custom_btn.borderWidth = 1
            cell.label_custom_btn.layer.cornerRadius = 5
            cell.label_custom_btn.textColor = UIColor(hexFromString: "494949") //added on 18th may
            cell.label_custom_btn.backgroundColor = UIColor(hexFromString: "D6D6D6")//added on 18th may
            
        }else if dict["aws_action"] as? String == "delete"{
            cell.label_enroll_status.text = "Image \n Enrolled"
            cell.label_enroll_status.textColor = UIColor(hexFromString: "095CB0")
            
//            cell.view_custom_btn.borderWidth = 1
            cell.view_custom_btn.cornerRadius = 5
//            cell.view_custom_btn.borderColor = UIColor(hexFromString: "626262")
            cell.label_custom_btn.text = "Remove \n Image"
//            cell.label_custom_btn.textColor = UIColor(hexFromString: "8E0A02")
//            cell.label_custom_btn.borderWidth = 1
            cell.label_custom_btn.layer.cornerRadius = 5
            cell.label_custom_btn.textColor = UIColor(hexFromString: "FFFFFF") //added on 18th may
            cell.label_custom_btn.backgroundColor = UIColor(hexFromString: "FC362C")//added on 18th may
            
        }else{
            cell.label_enroll_status.text = "Image \n Enrolled"
            cell.label_enroll_status.textColor = UIColor(hexFromString: "095CB0")
            
//            cell.view_custom_btn.borderWidth = 1
            cell.view_custom_btn.cornerRadius = 5
//            cell.view_custom_btn.borderColor = UIColor(hexFromString: "626262")
            cell.label_custom_btn.text = "Remove \n Image"
//            cell.label_custom_btn.textColor = UIColor(hexFromString: "8E0A02")
//            cell.label_custom_btn.borderWidth = 1
            cell.label_custom_btn.layer.cornerRadius = 5
            cell.label_custom_btn.textColor = UIColor(hexFromString: "FFFFFF") //added on 18th may
            cell.label_custom_btn.backgroundColor = UIColor(hexFromString: "FC362C")//added on 18th may
            
        }
        return cell
    }
    //--------tableview code ends-------
    
    //==============Create Gallery popup code starts(added on 21st MAy)================
    
    @IBAction func btn_gallerycreate_popup_ok(_ sender: Any) {
        closeGalleryPopup()
        createGallery(stringCheck: "CreateGalleryResult")
    }
    @IBOutlet weak var stackViewGalleryPopup: UIStackView!
    @IBOutlet var viewGalleryPopup: UIView!
    func createGalleryPopup(){
        blurEffect()
        self.view.addSubview(viewGalleryPopup)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewGalleryPopup.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewGalleryPopup.center = self.view.center
        viewGalleryPopup.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewGalleryPopup.alpha = 0
        viewGalleryPopup.sizeToFit()
        
        stackViewGalleryPopup.addBorder(side: .top, color: UIColor(hexFromString: "7F7F7F"), width: 1)
//        view_custom_btn_punchout.addBorder(side: .top, color: UIColor(hexFromString: "4f4f4f"), width: 1)
//        btnPopupOk.addBorder(side: .right, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
        UIView.animate(withDuration: 0.3){
            self.viewGalleryPopup.alpha = 1
            self.viewGalleryPopup.transform = CGAffineTransform.identity
        }
        
      
    }
    func closeGalleryPopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewGalleryPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewGalleryPopup.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewGalleryPopup.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    
    //==============Create Gallery popup code ends(added on 21st MAy)================
    
    
    //===============FormDetails Popup code starts(added on 4th jan)===================
    
    
    @IBOutlet weak var btnPopupOk: UIButton!
    @IBOutlet weak var btnPopupCancel: UIButton!
    @IBAction func btnPopupOk(_ sender: Any) {
        closeDetailsPopup()
//        self.performSegue(withIdentifier: "dashboard", sender: nil)
        self.DeleteImage(stringCheck: "DeleteFacesResult")
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
        closeDetailsPopup()
    }
    
    @IBOutlet weak var stackViewPupupButton: UIStackView!
    @IBOutlet var viewDetails: UIView!
    @IBOutlet weak var name: UILabel!
    func openDetailsPopup(name:String?){
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
        btnPopupOk.addBorder(side: .right, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
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
    
    //===============Enroll Image Popup code starts===================
    @IBOutlet weak var btnPopupYes: UIButton!
    @IBOutlet weak var btnPopupNo: UIButton!
    @IBAction func btnPopupYes(_ sender: Any) {
        closeEnrollPopup()
//        self.performSegue(withIdentifier: "dashboard", sender: nil)
//        self.DeleteImage(stringCheck: "DeleteFacesResult")
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnPopupNo(_ sender: Any) {
        closeEnrollPopup()
    }
    
    @IBOutlet weak var stackViewEnrollPopupButton: UIStackView!
    @IBOutlet var viewEnroll: UIView!
    @IBOutlet weak var enroll_label1: UILabel!
    @IBOutlet weak var enroll_label2: UILabel!
    func openEnrollPopup(label1: String?, label2: String?){
        blurEffect()
        self.view.addSubview(viewEnroll)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewEnroll.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewEnroll.center = self.view.center
        viewEnroll.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewEnroll.alpha = 0
        viewEnroll.sizeToFit()
        
        stackViewEnrollPopupButton.addBorder(side: .top, color: UIColor(hexFromString: "7F7F7F"), width: 1)
//        view_custom_btn_punchout.addBorder(side: .top, color: UIColor(hexFromString: "4f4f4f"), width: 1)
        btnPopupYes.addBorder(side: .right, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
        UIView.animate(withDuration: 0.3){
            self.viewEnroll.alpha = 1
            self.viewEnroll.transform = CGAffineTransform.identity
        }
        
        self.enroll_label1.text = label1!
        self.enroll_label2.text = label2!
        //        self.confidencelabel.text = confidence!
        
        
    }
    func closeEnrollPopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewEnroll.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewEnroll.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewEnroll.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //===============Enroll Image Popup code ends===================
    
    //===============Enroll Image Submission Popup code starts===================
    @IBOutlet weak var btnPopupStatusYes: UIButton!
    
    @IBAction func btnPopupStatusYes(_ sender: Any) {
        closeEnrollStatusPopup()
        loadData(stringCheck: "ListFace")
    }
    
    @IBOutlet weak var stackViewEnrollStatusPopupButton: UIStackView!
    @IBOutlet var viewEnrollStatus: UIView!
    @IBOutlet weak var enroll_label_status: UILabel!
    var isOpen: Bool!
    func openEnrollStatusPopup(label1: String?){
        if(isOpen == true){
            self.canelBlurEffect()
        }
        blurEffect()
        self.view.addSubview(viewEnrollStatus)
        isOpen = true
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height
        viewEnrollStatus.transform = CGAffineTransform.init(scaleX: 1.3,y :1.3)
        viewEnrollStatus.center = self.view.center
        viewEnrollStatus.layer.cornerRadius = 10.0
        //        addGoalChildFormView.layer.cornerRadius = 10.0
        viewEnrollStatus.alpha = 0
        viewEnrollStatus.sizeToFit()
        
        stackViewEnrollStatusPopupButton.addBorder(side: .top, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
        UIView.animate(withDuration: 0.3){
            self.viewEnrollStatus.alpha = 1
            self.viewEnrollStatus.transform = CGAffineTransform.identity
        }
        
        self.enroll_label_status.text = label1!
        //        self.confidencelabel.text = confidence!
        
        
    }
    func closeEnrollStatusPopup(){
        UIView.animate(withDuration: 0.3, animations: {
            self.viewEnrollStatus.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.viewEnrollStatus.alpha = 0
            self.blurEffectView.alpha = 0.3
        }) { (success) in
            self.viewEnrollStatus.removeFromSuperview();
            self.canelBlurEffect()
        }
    }
    //===============Enroll Image Submission Popup code ends===================
    
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
// MARK: - XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate
//--------to get colorstatus from api, code starts-------
extension EmployeeImageSettingsViewController: XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    func loadData(stringCheck:String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><ListFaces xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId></ListFaces></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!)) //---temporary commented on 21st may
        
//        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><ListFaces xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId></ListFaces></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: 22)) //--for testing
        
        print("corpid-=>",UserSingletonModel.sharedInstance.CorpID!)
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=ListFaces")
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
    
    func createGallery(stringCheck:String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><CreateGallery xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId></CreateGallery></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!)) //---temporary commented on 21st may
        
//        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><CreateGallery xmlns='%@/KioskService.asmx'><CorpId>23</CorpId></CreateGallery></soap12:Body></soap12:Envelope>",BASE_URL) //--for testing
        
        print("corpid-=>",UserSingletonModel.sharedInstance.CorpID!)
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=CreateGallery")
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
    
    func EnrollImage(stringCheck: String, base64ImageString: String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
//        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><IndexFaces xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><EmployeeId>\(id_person!)</EmployeeId><ExternalImageId>%@</ExternalImageId><ImageBase64>%@</ImageBase64></IndexFaces></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!),String(describing: self.enroll_names!),String(describing: base64ImageString))
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><IndexFaces xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><EmployeeId>\(id_person!)</EmployeeId><ImageBase64>%@</ImageBase64></IndexFaces></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!),String(describing: base64ImageString))  //--haved deleted external image id on 22nd jan as per security reasons
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=IndexFaces")
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
    
    func DeleteImage(stringCheck: String) {
        self.strCheck = stringCheck
        //        self.activityIndicator.startAnimating()
        
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><DeleteFaces xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><EmployeeId>\(id_person!)</EmployeeId><FaceId>\(aws_face_id!)</FaceId></DeleteFaces></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=DeleteFaces")
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
        if elementName == "ListFacesResult"{
            self.ListFacesResult = true
        }
        if elementName == "IndexFacesResult"{
            self.IndexFacesResult = true
        }
        if elementName == "DeleteFacesResult"{
            self.DeleteFacesResult = true
        }
        if elementName == "CreateGalleryResult"{
            self.CreateGalleryResult = true
        }
    }
    
    // Operations to do for each element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(String(format : "foundCharacters / value %@", string))
//        loaderStart()
        if strCheck == "ListFace"{
            if ListFacesResult == true{
                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("Listdatatest->",json)
                        print("Status->",json["status"].stringValue)
                        if json["response"]["status"].stringValue == "true"{
                        if let resData = json["employees"].arrayObject{
                            self.arrRes = resData as! [[String:AnyObject]]
                            self.filteredTableData = resData as! [[String:AnyObject]]
                        }
                        if arrRes.count>0 {
                            tableviewEmployeeImageSettings.reloadData()
                        }else{
                            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableviewEmployeeImageSettings.bounds.size.width, height: self.tableviewEmployeeImageSettings.bounds.size.height))
                            noDataLabel.text          = "No Data to show"
                            noDataLabel.textColor     = UIColor.black
                            noDataLabel.textAlignment = .center
                            self.tableviewEmployeeImageSettings.backgroundView  = noDataLabel
                            self.tableviewEmployeeImageSettings.separatorStyle  = .none
                        }
                        }else{
                            
                            //commented on 21st may to open gallery popup
                           /* var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["response"]["message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            
                            // Create Alert
                                       var dialogMessage = UIAlertController(title: "Error!", message: json["response"]["message"].stringValue, preferredStyle: .alert)

                            // Create Cancel button with action handlder
                            let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) -> Void in
                //                print("Cancel button tapped")
                            }

                                       //Add OK and Cancel button to an Alert object
                                       dialogMessage.addAction(cancel)

                                       // Present alert message to user
                                       self.present(dialogMessage, animated: true, completion: nil) */
                            createGalleryPopup()
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        print(error)
                    }
                    
                }
            }
        }
        
        if strCheck == "CreateGalleryResult"{
            if CreateGalleryResult == true{
                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("Gallerydatatest->",json)
                        print("Status->",json["Status"].stringValue)
                        if json["Status"].stringValue == "true"{
                            // Create Alert
                                       var dialogMessage = UIAlertController(title: "", message: "Employee Image Gallery created successfully", preferredStyle: .alert)

                            // Create Cancel button with action handlder
                            let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) -> Void in
                                self.loadData(stringCheck: "ListFace")
                //                print("Cancel button tapped")
                            }

                                       //Add OK and Cancel button to an Alert object
                                       dialogMessage.addAction(cancel)

                                       // Present alert message to user
                                       self.present(dialogMessage, animated: true, completion: nil)
                        
                        }else{
                            // Create Alert
                                       var dialogMessage = UIAlertController(title: "", message: "Sorry! Error creating Employee Image Gallery. Please contact admin.", preferredStyle: .alert)

                            // Create Cancel button with action handlder
                            let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) -> Void in
                //                print("Cancel button tapped")
                            }

                                       //Add OK and Cancel button to an Alert object
                                       dialogMessage.addAction(cancel)

                                       // Present alert message to user
                                       self.present(dialogMessage, animated: true, completion: nil)
                           
                           
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
                        print(error)
                    }
                }
            }
        }
    
        
        
        if strCheck == "IndexFacesResult"{
            if IndexFacesResult == true{
                //                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("EnrollData->",json)
                        if json["Status"].stringValue == "true"{
                            print("No Internet is available")
                            /*var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom, style: style)*/
                            openEnrollStatusPopup(label1: json["Message"].stringValue)
                            
//                            loadData(stringCheck: "ListFace") //--commented on 4t jan and also commented toast
                            
//                            loaderEnd()//commented on 4th jan
                            
                        }else{
                           /* var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom, style: style)*/
                            
                            openEnrollStatusPopup(label1: json["Message"].stringValue)
                            
//                            loadData(stringCheck: "ListFace") //--commented on 4t jan and also commented toast
                            
//                            loaderEnd()//commented on 4th jan
                        }
                        //                        print("getJsonDataforLeaveBalanceArray=-=->",objectArray)
                    } catch let error
                    {
//                        loaderEnd()
                        print(error)
                    }
                    
                }
            }
        }
        if strCheck == "DeleteFacesResult"{
            if DeleteFacesResult == true{
                //                loaderEnd()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        let json = try JSON(data: dataFromString)
                        print("EnrollData->",json)
                        if json["Status"].stringValue == "true"{
                           /* var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            loadData(stringCheck: "ListFace") */ // --commented on 4th jan 21
                            
                            openEnrollStatusPopup(label1: json["Message"].stringValue)
                            
                            loaderEnd()
                        }else{
                          /*  var style = ToastStyle()
                            
                            // this is just one of many style options
                            style.messageColor = .white
                            
                            // present the toast with the new style
                            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom, style: style)
                            
                            loadData(stringCheck: "ListFace") */ // --commented on 4th jan 21
                            
                            openEnrollStatusPopup(label1: json["Message"].stringValue)
                            
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
//-----------hexacode color conversion, code starts---------
extension UIColor {
    convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
//-----------hexacode color conversion, code ends---------
