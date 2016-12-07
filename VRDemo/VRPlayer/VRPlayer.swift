//
//  VRPlayer.swift
//  VRDemo
//
//  Created by huhuan on 2016/11/25.
//  Copyright © 2016年 Huanhoo. All rights reserved.
//

import UIKit
import AVFoundation

class VRPlayer: UIView, VRGLKViewDelegate {
    
    var avPlayer     : AVPlayer?
    var avPlayerItem : AVPlayerItem?
    var avAsset      : AVAsset?
    var output       : AVPlayerItemVideoOutput?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.avAsset = AVAsset.init(url:NSURL.fileURL(withPath: Bundle.main.path(forResource: "demo", ofType: "m4v")!))
        self.avPlayerItem = AVPlayerItem.init(asset : self.avAsset!)
        self.avPlayer = AVPlayer.init(playerItem: self.avPlayerItem!)
        
        let glkView : VRGLKView = VRGLKView.init(frame: CGRect.zero)
        glkView.translatesAutoresizingMaskIntoConstraints = false
        glkView.glkDelegate = self
        self.addSubview(glkView)
        
        let leftConstraint = NSLayoutConstraint(item:glkView,
                                                attribute:.left,
                                                relatedBy:.equal,
                                                toItem:self,
                                                attribute:.left,
                                                multiplier:1.0,
                                                constant:0);
        let rightConstraint = NSLayoutConstraint(item:glkView,
                                                 attribute:.right,
                                                 relatedBy:.equal,
                                                 toItem:self,
                                                 attribute:.right,
                                                 multiplier:1.0,
                                                 constant:0);
        let topConstraint = NSLayoutConstraint(item:glkView,
                                               attribute:.top,
                                               relatedBy:.equal,
                                               toItem:self,
                                               attribute:.top,
                                               multiplier:1.0,
                                               constant:0);
        let bottomConstraint = NSLayoutConstraint(item:glkView,
                                                  attribute:.bottom,
                                                  relatedBy:.equal,
                                                  toItem:self,
                                                  attribute:.bottom,
                                                  multiplier:1.0,
                                                  constant:0);
        
        self.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        
        self.avPlayer?.play()
        configureOutput()
        
        NotificationCenter.default.addObserver(self, selector:#selector(playEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureOutput() {
        
        if self.avPlayerItem != nil && output != nil {
           self.avPlayerItem?.remove(output!)
        }
        output = nil;
        
        let pixelBuffer: Dictionary = [kCVPixelBufferPixelFormatTypeKey as String :  NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)];
        output = AVPlayerItemVideoOutput.init(pixelBufferAttributes: pixelBuffer)
        output!.requestNotificationOfMediaDataChange(withAdvanceInterval: 0.03)
        avPlayerItem?.add(output!)
        
        
    }
    
    internal func dataSource() -> CVPixelBuffer? {
    
        let pixelBuffer: CVPixelBuffer? = output?.copyPixelBuffer(forItemTime: (avPlayerItem?.currentTime())!, itemTimeForDisplay: nil)
        //if pixelBuffer == nil {
        //    configureOutput()
        //}
        return pixelBuffer;
        
    }
    
    func playEnd() {
    
        self.avPlayer?.seek(to: kCMTimeZero)
        self.avPlayer?.play()
    
    }

}
