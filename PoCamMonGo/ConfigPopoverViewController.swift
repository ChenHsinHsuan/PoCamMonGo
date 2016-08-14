//
//  ConfigPopoverViewController.swift
//  PoCamMonGo
//
//  Created by ChenHsin-Hsuan on 8/14/16.
//  Copyright © 2016 AirconTW. All rights reserved.
//

import UIKit

class ConfigPopoverViewController: UIViewController {

    var delegate: ResultViewController?
    
    @IBOutlet weak var cpBackgroundSwitch: UISwitch!
    @IBOutlet weak var pokemonBallSwitch: UISwitch!
    @IBOutlet weak var leaveButtonSwitch: UISwitch!
    @IBOutlet weak var arButtonSwitch: UISwitch!
    
    var cpBackgroundDisplay = true
    var pokemonBallDisplay = true
    var leaveButtonDisplay = true
    var arButtonDisplay = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cpBackgroundSwitch.on = cpBackgroundDisplay
        pokemonBallSwitch.on = pokemonBallDisplay
        leaveButtonSwitch.on = leaveButtonDisplay
        arButtonSwitch.on = arButtonDisplay
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func CPTextFieldSwitched(sender: UISwitch) {
        delegate?.triggerCPTextField(sender.on)
    }
    @IBAction func PokemonBallSwitched(sender: UISwitch) {
        delegate?.triggerPokemonBallButton(sender.on)
    }
    
    @IBAction func leaveButtonSwitched(sender: UISwitch) {
        delegate?.triggerLeaveButton(sender.on)
    }
    
    @IBAction func arSwitchSwitched(sender: AnyObject) {
        delegate?.triggerARButton(sender.on)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
