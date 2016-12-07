//
//  ViewController.swift
//  VRDemo
//
//  Created by huhuan on 2016/12/6.
//  Copyright © 2016年 Huanhoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vrPlayer : VRPlayer! = VRPlayer.init()
        self.view.addSubview(vrPlayer)
        vrPlayer.translatesAutoresizingMaskIntoConstraints = false
        
        let size: CGSize = self.view.bounds.size
        
        let leftConstraint = NSLayoutConstraint(item:vrPlayer,
                                                attribute:.left,
                                                relatedBy:.equal,
                                                toItem:self.view,
                                                attribute:.left,
                                                multiplier:1.0,
                                                constant:0);
        let rightConstraint = NSLayoutConstraint(item:vrPlayer,
                                                 attribute:.right,
                                                 relatedBy:.equal,
                                                 toItem:self.view,
                                                 attribute:.right,
                                                 multiplier:1.0,
                                                 constant:0);
        let centerYConstraint = NSLayoutConstraint(item:vrPlayer,
                                                   attribute:.centerY,
                                                   relatedBy:.equal,
                                                   toItem:self.view,
                                                   attribute:.centerY,
                                                   multiplier:1.0,
                                                   constant:0);
        let heightConstraint = NSLayoutConstraint(item:vrPlayer,
                                                  attribute:.height,
                                                  relatedBy:.equal,
                                                  toItem:nil,
                                                  attribute:.notAnAttribute,
                                                  multiplier:1.0,
                                                  constant:size.width/16*9);
        
        self.view.addConstraints([leftConstraint, rightConstraint, centerYConstraint])
        vrPlayer.addConstraint(heightConstraint)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

