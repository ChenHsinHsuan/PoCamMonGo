//
//  ViewController.swift
//  PokemonKacha
//
//  Created by ChenHsin-Hsuan on 8/7/16.
//  Copyright © 2016 AirconTW. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var exportImage:UIImage?
    
    override func viewWillAppear(animated: Bool) {
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            if device.position == AVCaptureDevicePosition.Front{
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
                } catch {
                    print("Error!")
                }
                
                
            }
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhotoButtonPressed(sender: UIButton) {
        
        if let videoConnection = sessionOutput.connectionWithMediaType(AVMediaTypeVideo) {
            
            sessionOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                buffer, error in
                
//                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
//                
//                let image = UIImage(data:imageData)!
                
                UIGraphicsBeginImageContextWithOptions(self.cameraView.frame.size, true, 0.0)
                self.cameraView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                self.exportImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                
                
                UIImageWriteToSavedPhotosAlbum(self.exportImage!, nil, nil, nil)
                
            })
        }
        
        
        
    }

}

