//
//  RealtimeDetectionViewController.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 01/12/20.
//

import UIKit
import AVFoundation
import Vision
import VideoToolbox
import Alamofire
import SwiftyJSON
import SWXMLHash
import ImageIO

class RealtimeDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var viewCamera: UIView!
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var drawings: [CAShapeLayer] = []
    
    var strCheck = ""
    var mutableData = NSMutableData()
    var RecognizeFaceResult = false
    
   static var EmployeeCode: String!
   static var PersonId: Int!
   static var EmployeeName: String!
   static var Supervisor1: String!
   static var Supervisor2: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addCameraInput()
        self.showCameraFeed()
        self.getCameraFrames()
        self.captureSession.startRunning()
        
        //-----code to show the Avrrunning session in a view, starts
        DispatchQueue.main.async {
            self.previewLayer.frame = self.viewCamera!.bounds
        }
        //-----code to show the Avrrunning session in a view, ends
    }
    

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        self.detectFace(in: frame)
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                mediaType: .video,
                position: .front).devices.first else {
            fatalError("No back camera device found, please make sure to run SimpleLaneDetection in an iOS device and not a simulator")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        /*  self.previewLayer.videoGravity = .resizeAspectFill
         self.view.layer.addSublayer(self.previewLayer)
         self.previewLayer.frame = self.view.frame */
        
        //----code to show realtime session in a view
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.viewCamera.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.viewCamera.frame
        
    }
    
    private func getCameraFrames() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    private func detectFace(in image: CVPixelBuffer) {
        /*   let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
         DispatchQueue.main.async {
         if let results = request.results as? [VNFaceObservation] {
         self.handleFaceDetectionResults(results)
         } else {
         self.clearDrawings()
         }
         }
         })
         let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
         try? imageRequestHandler.perform([faceDetectionRequest])*/
        var detect_count:Int = 0
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.sync {
                parentif: if let results = request.results as? [VNFaceObservation], results.count > 0 {
                    
                    detect_count = detect_count + 1
                    print("detectcount-=>",detect_count)
//                    break parentif
                    self.handleFaceDetectionResults(results)
                    print("did detect \(results.count) face(s)")
                    self.captureSession.stopRunning()
                    self.loaderStart1()
                    nestedif: if(results.count>1){
                        self.loaderEnd()
//                        self.captureSession.stopRunning()
                        DispatchQueue.main.async {
                        self.openDetailsPopup(name: "Multiple faces detected. Please try again.")
                        }
//                        break nestedif
                    }else {
                       // break nestedif
//                        self.loaderEnd() //on 5th jan
                        //----convert cvpixel to base64, code starts
                        let image = UIImage(ciImage: CIImage(cvPixelBuffer: image))
                        let imageData = image.jpegData(compressionQuality: 0.7)
                        let base64String = imageData?.base64EncodedString()
//                                                    print("base64convert-=>",base64String)
                        
                        //----convert cvpixel to base64, code ends
                        
                        //===============upload photo to the server code starts==========
                        
                        
                        //                   let api = "https://wrkplan-test.com/f/*ace-recognition/api/recognize"
                        
                     /*   let api = "https://wrkplan-test.com/face-recognition/api/collection/face/recognize"
//                        let api = "http://14.99.211.60:9012/AttendanceService.asmx/RecognizeFace"
                        let sentData: [String:Any] = [
                            "CollectionId":"arb-usa",
                            "ImageBase64":base64String,
                        ]
                        AF.request(api, method: .post, parameters: sentData, encoding: JSONEncoding.default, headers: nil).responseJSON{
                            response in
                            switch response.result{
                            case .success:
                                self.loaderEnd()
                                
                                let swiftyJsonVar = JSON(response.value ?? "")
                                print("responseData-=>",swiftyJsonVar)
                                nestedif1: if(swiftyJsonVar["FaceMatches"][0]["Face"].exists()){
                                    let name = swiftyJsonVar["FaceMatches"][0]["Face"]["ExternalImageId"].stringValue
                                    print("name-=>",name)
//                                    self.openDetailsPopup(name: "Hello \(name)")
                                    self.performSegue(withIdentifier: "recognitionoption", sender: nil)
//                                    break nestedif1
                                }else {
                                    self.openDetailsPopup(name: "Sorry! Couldn't recognize")
//                                    break nestedif1
                                }
                                break
                                
                            case .failure(let error):
                                self.loaderEnd()
                                print("Error: ", error)
                            }
                        }*/
                        
                        //===============upload photo to the server code ends===========
                        
                        self.loadData(strchk: "Recognize", base64: base64String!)
                    }
                    
                } else {
                    self.clearDrawings()
                    print("did not detect any face")
                }
                
            }
        }
        )
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
        
        
    }
    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        
        self.clearDrawings()
        let facesBoundingBoxes: [CAShapeLayer] = observedFaces.flatMap({ (observedFace: VNFaceObservation) -> [CAShapeLayer] in
            let faceBoundingBoxOnScreen = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observedFace.boundingBox)
            let faceBoundingBoxPath = CGPath(rect: faceBoundingBoxOnScreen, transform: nil)
            let faceBoundingBoxShape = CAShapeLayer()
            faceBoundingBoxShape.path = faceBoundingBoxPath
            faceBoundingBoxShape.fillColor = UIColor.clear.cgColor
            faceBoundingBoxShape.strokeColor = UIColor.white.cgColor
            var newDrawings = [CAShapeLayer]()
            newDrawings.append(faceBoundingBoxShape)
            if let landmarks = observedFace.landmarks {
                newDrawings = newDrawings + self.drawFaceFeatures(landmarks, screenBoundingBox: faceBoundingBoxOnScreen)
            }
            return newDrawings
        })
        facesBoundingBoxes.forEach({ faceBoundingBox in self.view.layer.addSublayer(faceBoundingBox) })
        self.drawings = facesBoundingBoxes
    }
    
    private func clearDrawings() {
        self.drawings.forEach({ drawing in drawing.removeFromSuperlayer() })
    }
    
    private func drawFaceFeatures(_ landmarks: VNFaceLandmarks2D, screenBoundingBox: CGRect) -> [CAShapeLayer] {
        var faceFeaturesDrawings: [CAShapeLayer] = []
        /*if let leftEye = landmarks.leftEye {
            let eyeDrawing = self.drawEye(leftEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }
        if let rightEye = landmarks.rightEye {
            let eyeDrawing = self.drawEye(rightEye, screenBoundingBox: screenBoundingBox)
            faceFeaturesDrawings.append(eyeDrawing)
        }*/
        // draw other face features here
        return faceFeaturesDrawings
    }
    private func drawEye(_ eye: VNFaceLandmarkRegion2D, screenBoundingBox: CGRect) -> CAShapeLayer {
        let eyePath = CGMutablePath()
        let eyePathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * screenBoundingBox.height + screenBoundingBox.origin.x,
                    y: eyePoint.x * screenBoundingBox.width + screenBoundingBox.origin.y)
            })
        eyePath.addLines(between: eyePathPoints)
        eyePath.closeSubpath()
        let eyeDrawing = CAShapeLayer()
        eyeDrawing.path = eyePath
        eyeDrawing.fillColor = UIColor.clear.cgColor
        eyeDrawing.strokeColor = UIColor.green.cgColor
        
        return eyeDrawing
    }
    
    
    //-------to convert uiimage, code starts
    
    
    //===============FormDetails Popup code starts===================
    
    
    @IBOutlet weak var btnPopupOk: UIButton!
    @IBOutlet weak var btnPopupCancel: UIButton!
    @IBAction func btnPopupOk(_ sender: Any) {
        closeDetailsPopup()
//        self.performSegue(withIdentifier: "dashboard", sender: nil)
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
    }
    
    @IBAction func btn_cancel(_ sender: Any) {
        closeDetailsPopup()
        self.performSegue(withIdentifier: "homemain", sender: nil)
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
        btnPopupCancel.addBorder(side: .right, color: UIColor(hexFromString: "7F7F7F"), width: 1)
        
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
    
    func loaderStart1(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        loader = UIVisualEffectView(effect: blurEffect)
        loader.frame = view.bounds
       /* let xPosition = view.frame.origin.x
        let yPosition = view.frame.maxY - view.frame.size.height// Slide Up - 20px
        let width = view.frame.size.width
        let height = view.frame.size.height
        loader.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)*/
        loader.alpha = 1
        view.addSubview(loader)
        var loadingIndicator: UIImageView!
        if UIScreen.main.bounds.size.width < 768 { //IPHONE
            loadingIndicator = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 175/2, y: view.frame.maxY - 150, width: 175, height: 88))
        }else { //Ipad
            print("screensize-=>",UIScreen.main.bounds.width)
            loadingIndicator = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 300/2, y: view.frame.maxY - 200, width: 300, height: 150))
        }
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.transform = transform
//        loadingIndicator.center = self.view.center //--commented on 12th aug
        /*loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.white*/
//        let jeremyGif = UIImage.gifImageWithName("Processing")
        let imagesArray = [UIImage(named: "Processingimagedata.png")!]
//        let imagesArray = [jeremyGif!]
        loadingIndicator.animationImages = imagesArray
//        loadingIndicator.sizeToFit()
        loadingIndicator.startAnimating();
        loader.contentView.addSubview(loadingIndicator)
        
        // screen roted and size resize automatic
        loader.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth];
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
    
    //-------function to draw rectangle
    private func drawRectangle() {
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 200, y: 0))
            path.addLine(to: CGPoint(x: 200, y: 200))
            path.addLine(to: CGPoint(x: 0, y: 200))
            path.addLine(to: CGPoint(x: 0, y: 0))
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.fillColor = UIColor.orange.cgColor
            shapeLayer.lineWidth = 3
            
        self.previewLayer.addSublayer(shapeLayer)
        }

};
extension RealtimeDetectionViewController: XMLParserDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    func loadData(strchk: String, base64: String) {
        self.strCheck = strchk
        //        KRProgressHUD.show(withMessage: "Loading...")
        let text = String(format: "<?xml version='1.0' encoding='utf-8'?><soap12:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap12='http://www.w3.org/2003/05/soap-envelope'><soap12:Body><RecognizeFace xmlns='%@/KioskService.asmx'><CorpId>%@</CorpId><ImageBase64>%@</ImageBase64></RecognizeFace></soap12:Body></soap12:Envelope>",BASE_URL, String(describing: UserSingletonModel.sharedInstance.CorpID!), String(describing:base64))
        
        var soapMessage = text
        let url = NSURL(string: "\(BASE_URL)/kioskservice.asmx?op=RecognizeFace")
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
        if elementName == "RecognizeFaceResult" {
            self.RecognizeFaceResult = true
        }
        
    }
    
    // Operations to do for each element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(String(format : "foundCharacters / value %@", string))
        if strCheck == "Recognize"{
            if self.RecognizeFaceResult == true {
                
//                eventData.removeAll()
                //                self.removeAllArrayValue()
                
                //            KRProgressHUD.dismiss()
                if let dataFromString = string.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    do{
                        let response = try JSON(data: dataFromString)
                        //                    print("ResponseData Test->",response)
                        let json = try JSON(data: dataFromString)
                        
                      
                        let swiftyJsonVar = JSON(dataFromString)
                        print("RecognizeFaceResult->",swiftyJsonVar)
                       /* nestedif1: if(swiftyJsonVar["FaceMatches"][0]["Face"].exists()){
                            let name = swiftyJsonVar["FaceMatches"][0]["Face"]["ExternalImageId"].stringValue
                            print("name-=>",name)
                            self.performSegue(withIdentifier: "recognitionoption", sender: nil)
//                                    break nestedif1
                        }else {
                            self.openDetailsPopup(name: "Sorry! Couldn't recognize")
//                                    break nestedif1
                        } */
                        nestedif1: if(swiftyJsonVar["PersonId"].intValue > 0){
                            let name = swiftyJsonVar["EmployeeName"].stringValue
                            print("name-=>",name)
//                                    self.openDetailsPopup(name: "Hello \(name)")
                            RealtimeDetectionViewController.EmployeeName = swiftyJsonVar["EmployeeName"].stringValue
                            RealtimeDetectionViewController.PersonId = swiftyJsonVar["PersonId"].intValue
                            RealtimeDetectionViewController.EmployeeCode = swiftyJsonVar["EmployeeCode"].stringValue
                            RealtimeDetectionViewController.Supervisor1 = swiftyJsonVar["Supervisor1"].stringValue
                            RealtimeDetectionViewController.Supervisor2 = swiftyJsonVar["Supervisor2"].stringValue
                            self.performSegue(withIdentifier: "recognitionoption", sender: nil)
                            print("Employeename test-=>",RealtimeDetectionViewController.EmployeeName)
//                                    break nestedif1
                            loaderEnd()
                        }else {
                            self.openDetailsPopup(name: "Sorry! Couldn't recognize")
//                                    break nestedif1
                            loaderEnd()
                        }
                        
                    }
                    catch let error
                    {
                        print(error)
                        loaderEnd()
                    }
                    
                }
            }
        }
        
    }
}
extension UIImage{
    public class func gifImageWithData(_ data: Data) -> UIImage? {
           guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
               print("image doesn't exist")
               return nil
           }
           
           return UIImage.animatedImageWithSource(source)
       }
       
       public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
           guard let bundleURL:URL? = URL(string: gifUrl)
               else {
                   print("image named \"\(gifUrl)\" doesn't exist")
                   return nil
           }
           guard let imageData = try? Data(contentsOf: bundleURL!) else {
               print("image named \"\(gifUrl)\" into NSData")
               return nil
           }
           
           return gifImageWithData(imageData)
       }
       
       public class func gifImageWithName(_ name: String) -> UIImage? {
           guard let bundleURL = Bundle.main
               .url(forResource: name, withExtension: "gif") else {
                   print("SwiftGif: This image named \"\(name)\" does not exist")
                   return nil
           }
           guard let imageData = try? Data(contentsOf: bundleURL) else {
               print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
               return nil
           }
           
           return gifImageWithData(imageData)
       }
       
       class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
           var delay = 0.1
           
           let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
           let gifProperties: CFDictionary = unsafeBitCast(
               CFDictionaryGetValue(cfProperties,
                   Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
               to: CFDictionary.self)
           
           var delayObject: AnyObject = unsafeBitCast(
               CFDictionaryGetValue(gifProperties,
                   Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
               to: AnyObject.self)
           if delayObject.doubleValue == 0 {
               delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                   Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
           }
           
           delay = delayObject as! Double
           
           if delay < 0.1 {
               delay = 0.1
           }
           
           return delay
       }
       
       class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
           var a = a
           var b = b
           if b == nil || a == nil {
               if b != nil {
                   return b!
               } else if a != nil {
                   return a!
               } else {
                   return 0
               }
           }
           
        if a! < b! {
               let c = a
               a = b
               b = c
           }
           
           var rest: Int
           while true {
               rest = a! % b!
               
               if rest == 0 {
                   return b!
               } else {
                   a = b
                   b = rest
               }
           }
       }
       
       class func gcdForArray(_ array: Array<Int>) -> Int {
           if array.isEmpty {
               return 1
           }
           
           var gcd = array[0]
           
           for val in array {
               gcd = UIImage.gcdForPair(val, gcd)
           }
           
           return gcd
       }
       
       class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
           let count = CGImageSourceGetCount(source)
           var images = [CGImage]()
           var delays = [Int]()
           
           for i in 0..<count {
               if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                   images.append(image)
               }
               
               let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                   source: source)
               delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
           }
           
           let duration: Int = {
               var sum = 0
               
               for val: Int in delays {
                   sum += val
               }
               
               return sum
           }()
           
           let gcd = gcdForArray(delays)
           var frames = [UIImage]()
           
           var frame: UIImage
           var frameCount: Int
           for i in 0..<count {
               frame = UIImage(cgImage: images[Int(i)])
               frameCount = Int(delays[Int(i)] / gcd)
               
               for _ in 0..<frameCount {
                   frames.append(frame)
               }
           }
           
           let animation = UIImage.animatedImage(with: frames,
               duration: Double(duration) / 1000.0)
           
           return animation
       }
}

