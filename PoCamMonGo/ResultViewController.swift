//
//  ResultViewController.swift
//  PoCamMonGo
//
//  Created by ChenHsin-Hsuan on 8/8/16.
//  Copyright © 2016 AirconTW. All rights reserved.
//

import UIKit
import Photos
import GoogleMobileAds
import ImgurAnonymousAPIClient
import Social
import SVProgressHUD
import SystemConfiguration


class ResultViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var cpTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var configButton: UIButton!
    
    var photoImage:UIImage!
    var imgurClient:ImgurAnonymousAPIClient? = nil
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraImageView.image = photoImage
        
        //guesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(ResultViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)

        
        self.appDelegate.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        cpTextField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard(){
        cpTextField.resignFirstResponder()
    }
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func exportButtonPressed(sender: UIButton) {
        appDelegate.myInterstitial?.presentFromRootViewController(self)
    }
    
    
    
    func genImage() -> UIImage {
        cancelButton.hidden = !cancelButton.hidden
        exportButton.hidden = !exportButton.hidden
        configButton.hidden = !configButton.hidden
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let exportImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cancelButton.hidden = !cancelButton.hidden
        exportButton.hidden = !exportButton.hidden
        configButton.hidden = !configButton.hidden
        return exportImage
    }
    
    func showAdmob(){
        appDelegate.myInterstitial!.presentFromRootViewController(self)
    }
    
    
    func showExportOption(){
        

        let exportImage = genImage()
        
        let alertController = UIAlertController(title: "請選擇您想匯出的方式", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        let sponseAction = UIAlertAction(title: "再看一次廣告贊助作者", style: UIAlertActionStyle.Destructive) { _ in
            if (self.appDelegate.myInterstitial!.isReady){
                self.showAdmob()
            }else{
                let okAciton = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.Default, handler: nil)
                let alertView = UIAlertController(title: "APP偵測到你的網路異常", message: "謝謝你這麼有心～等網路正常再幫我點吧～謝謝", preferredStyle: UIAlertControllerStyle.Alert)
                alertView.addAction(okAciton)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            
        }
        
        let shareToLineAction = UIAlertAction(title: "分享到LINE", style: UIAlertActionStyle.Default) { _ in
            var pasteBoard = UIPasteboard(name: "jp.naver.linecamera.pasteboard", create: true)!
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                pasteBoard = UIPasteboard.generalPasteboard()
            }
            
            pasteBoard.setData(UIImageJPEGRepresentation(exportImage, 1.0)!, forPasteboardType: "public.jpeg")
            
            let lineAppURL:NSURL = NSURL(string: "line://msg/image/\(pasteBoard.name)")!
            
            if( UIApplication.sharedApplication().canOpenURL(lineAppURL)){
                UIApplication.sharedApplication().openURL(lineAppURL)
            }
            
        }
        
        
        let shareToFBAction = UIAlertAction(title: "分享到Facebook", style: UIAlertActionStyle.Default) { _ in
            
            let fbSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbSheet.addImage(exportImage)
            self.presentViewController(fbSheet, animated: true, completion: nil)
        }
        
        
        
        let exportPictureAction = UIAlertAction(title: "儲存到相片膠卷", style: UIAlertActionStyle.Default) { _ in
            
            let status = PHPhotoLibrary.authorizationStatus()
            
            let okAciton = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.Default, handler: nil)
            
            if status == PHAuthorizationStatus.Authorized{
                //Save it to the camera roll
                UIImageWriteToSavedPhotosAlbum(exportImage, nil, nil, nil)
                
                let alertView = UIAlertController(title: "匯出成功", message:  "圖已經存至您的相機膠卷中囉!", preferredStyle: UIAlertControllerStyle.Alert)
                alertView.addAction(okAciton)
                self.presentViewController(alertView, animated: true, completion: nil)
            }else{
                let alertView = UIAlertController(title: "匯出失敗", message:  "請至設定>隱私權>照片>將PoCamMonGo的權限打開唷!!", preferredStyle: UIAlertControllerStyle.Alert)
                alertView.addAction(okAciton)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
        
        
        func printTimestamp() -> String {
            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            print(timestamp)
            return timestamp
        }

        
        let imgurAction = UIAlertAction(title: "上傳imgur拿短網址", style: UIAlertActionStyle.Default) { _ in
            
            
            SVProgressHUD.showWithStatus("上傳中,請稍候...")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            
            self.imgurClient = ImgurAnonymousAPIClient(clientID: "c65f9b902df351c")
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0),{
                self.imgurClient?.uploadImage(exportImage, withFilename: "\(printTimestamp()).jpg", completionHandler: { (url, erorr) in
                    
                    if(url == nil){
                        let okAciton = UIAlertAction(title: "我知道了", style: UIAlertActionStyle.Default, handler: nil)
                        let alertView = UIAlertController(title: "APP偵測到你的網路異常，所以沒辦法幫你上傳", message: "請確認連線狀況!", preferredStyle: UIAlertControllerStyle.Alert)
                        alertView.addAction(okAciton)
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }else{
                        let alertView = UIAlertController(title: "上傳完畢，網址如下", message: "\(url)", preferredStyle: UIAlertControllerStyle.ActionSheet)
                        let copyAction = UIAlertAction(title: "幫我複製URL讓我直接可以貼上", style: UIAlertActionStyle.Default, handler: { _ in
                            UIPasteboard.generalPasteboard().string = "\(url)"
                        })
                        alertView.addAction(copyAction)
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        SVProgressHUD.dismiss()
                    })
                })
            })
            
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { _ in
            
        }
        
        alertController.addAction(sponseAction)
        alertController.addAction(shareToLineAction)
        alertController.addAction(shareToFBAction);
        alertController.addAction(imgurAction)
        alertController.addAction(exportPictureAction)
        alertController.addAction(cancelAction)
        
        
        presentViewController(alertController, animated: true, completion:nil)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    @IBAction func configButtonPressed(sender: AnyObject) {
        
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("ConfigPopover") as! ConfigPopoverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 20 , UIScreen.mainScreen().bounds.height - 100)
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        presentViewController(popoverVC, animated: true, completion: nil)
    }
    
    
}
