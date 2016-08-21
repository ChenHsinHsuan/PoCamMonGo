//
//  ViewController.swift
//  PokemonKacha
//
//  Created by ChenHsin-Hsuan on 8/7/16.
//  Copyright © 2016 AirconTW. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices



class ViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var liveCamView: UIView!
    
    var photoImage:UIImage?
    var imagePicker:UIImagePickerController?;
    
    var camera = AVCaptureDevicePosition.Back
    var previewLayer = AVCaptureVideoPreviewLayer()
    var sessionOutput = AVCaptureStillImageOutput()
    var captureSession =  AVCaptureSession()
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    func reloadCamera(){
        if captureSession.running {
            previewLayer.removeFromSuperlayer()
            captureSession.stopRunning()
            captureSession =  AVCaptureSession()
            previewLayer = AVCaptureVideoPreviewLayer()
        }
        
        for device in AVCaptureDevice.devices() {
            if device.position == camera{
                captureDevice = device as? AVCaptureDevice
                do {
                    let input = try AVCaptureDeviceInput(device: device as! AVCaptureDevice)
                
                    if captureSession.canAddInput(input) {
                        
                        
                        captureSession.addInput(input)
                        sessionOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]

                        
                        if captureSession.canAddOutput(sessionOutput) {
                            captureSession.addOutput(sessionOutput)
                            captureSession.startRunning() 
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                            liveCamView.layer.addSublayer(previewLayer)
                            
                            previewLayer.position = CGPoint(x: liveCamView.frame.width/2, y: self.liveCamView.frame.height/2)
                            
                            previewLayer.bounds = liveCamView.frame
                        }
                    }else{
                        print("captureSession can't add input... ")
                    }
                } catch let error as NSError{
                    print("Error: \(error), \(error.userInfo)")
                }
                
            }
        }
    }

    
    
    override func viewWillAppear(animated: Bool) {
        reloadCamera()
    }
    
    
    @IBAction func CamFilpButtonPressed(sender: UIButton) {
        if camera == AVCaptureDevicePosition.Back {
            camera = AVCaptureDevicePosition.Front
        }else{
            camera = AVCaptureDevicePosition.Back
        }
        reloadCamera()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ask photo permission
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
        })
        
        // ask camera permission
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
        })
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhotoButtonPressed(sender: UIButton) {
        
        if let videoConnection = sessionOutput.connectionWithMediaType(AVMediaTypeVideo) {
            
            sessionOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                buffer, error in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                self.photoImage = UIImage(data:imageData)!
                
                self.performSegueWithIdentifier("ResultSegue", sender: self)
                
            })
        }
      
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ResultSegue" {
            let destVC = segue.destinationViewController as! ResultViewController
            destVC.photoImage = self.photoImage
        }
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Get Touch Point
        let Point = touches.first!.locationInView(liveCamView)
        
        
        //Assign Auto Focus and Auto Exposour
        if let device = captureDevice {
            do {
                try! device.lockForConfiguration()
                if device.focusPointOfInterestSupported{
                    //Add Focus on Point
                    device.focusPointOfInterest = Point
                    device.focusMode = AVCaptureFocusMode.AutoFocus
                }
                
                if device.exposurePointOfInterestSupported{
                    //Add Exposure on Point
                    device.exposurePointOfInterest = Point
                    device.exposureMode = AVCaptureExposureMode.AutoExpose
                }
                device.unlockForConfiguration()
                
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Get Touch Point
        let Point = touches.first!.locationInView(liveCamView)
        //Assign Auto Focus and Auto Exposour
        if let device = captureDevice {
            do {
                try! device.lockForConfiguration()
                if device.focusPointOfInterestSupported{
                    //Add Focus on Point
                    device.focusPointOfInterest = Point
                    device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                }
                
                if device.exposurePointOfInterestSupported{
                    //Add Exposure on Point
                    device.exposurePointOfInterest = Point
                    device.exposureMode = AVCaptureExposureMode.AutoExpose
                }
                device.unlockForConfiguration()
            }
        }

    }
    
    
    @IBAction func photoLibraryButtonPressed(sender: AnyObject) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            self.imagePicker = UIImagePickerController()
            self.imagePicker!.delegate = self
            self.imagePicker!.mediaTypes = [kUTTypeImage as String]
            self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.imagePicker!.allowsEditing = true
            
            self.presentViewController(self.imagePicker!, animated: true, completion:nil)
        }

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismissViewControllerAnimated(true, completion:{
            self.photoImage = image
            self.performSegueWithIdentifier("ResultSegue", sender: self)
        })
        
        
    }

    
}

