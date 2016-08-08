//
//  ResultViewController.swift
//  PoCamMonGo
//
//  Created by ChenHsin-Hsuan on 8/8/16.
//  Copyright © 2016 AirconTW. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var cpTextField: UITextField!
    
    var photoImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraImageView.image = photoImage
        // Do any additional setup after loading the view.
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
    
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func exportButtonPressed(sender: UIButton) {
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
