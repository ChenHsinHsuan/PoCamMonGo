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

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    
    
    
    var photoImage:UIImage?
    
    var sessionOutput = AVCaptureStillImageOutput()
    var camera = AVCaptureDevicePosition.Back
    
    
    
    func reloadCamera(){
        let captureSession = AVCaptureSession()
        
        var previewLayer = AVCaptureVideoPreviewLayer()
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            if device.position == camera{
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
                            cameraView.layer.addSublayer(previewLayer)
                            
                            previewLayer.position = CGPoint(x: self.cameraView.frame.width/2, y: self.cameraView.frame.height/2)
                            
                            previewLayer.bounds = cameraView.frame
                            
                        }
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
    
    
    @IBAction func revertCamButtonPressed(sender: UIButton) {
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

//                
//                
//                let scale = UIScreen.mainScreen().scale
//                UIGraphicsBeginImageContextWithOptions(self.cameraView.frame.size, false, scale)
//                
//                let screenshot = UIGraphicsGetImageFromCurrentImageContext()
//                UIGraphicsEndImageContext()
//                
                
                
                
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                
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


   
    
}

