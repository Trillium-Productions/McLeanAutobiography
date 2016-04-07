//
//  introview.swift
//  autobiography
//
//  Created by William Rosenbloom on 4/2/16.
//  Copyright © 2016 William Rosenbloom. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class IntroViewController: AVPlayerViewController {
    
    override func viewDidLoad() {
        let rec = UITapGestureRecognizer(target: self, action: "onTapReceived")
        rec.numberOfTapsRequired = 1
        rec.numberOfTouchesRequired = 1
        let sub = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 768)))
        view.addSubview(sub)
        let _image = UIImage(named: "touch-to-start")!
        let height: CGFloat = 90
        let width = _image.size.width * height / _image.size.height
        let left = 1024 - 50 - width
        let top = 768 - 20 - height
        let iv = UIImageView(frame: CGRect(x: left, y: top, width: width, height: height))
        iv.image = _image
        sub.addSubview(iv)
        sub.addGestureRecognizer(rec)
        (UIApplication.sharedApplication().delegate as! AppDelegate).navigator = navigationController!
        view.addGestureRecognizer(rec)
        if let url = NSBundle.mainBundle().URLForResource("attractscreen", withExtension: "mp4") {
            player = AVPlayer(URL: url)
        } else {
            fatalError("Failed to load video file \"starter.mp4\"")
        }
        if let _player = player {
            _player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
            _player.muted = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "restartVideo", name: AVPlayerItemDidPlayToEndTimeNotification, object: _player.currentItem)
        } else {
            fatalError("Failed to load AV player")
        }
        super.viewDidLoad()
    }
    
    func restartVideo() {
        let secs: Int64 = 0
        let scale: Int32 = 1
        let time = CMTimeMake(secs, scale)
        if let _player = player {
            _player.seekToTime(time)
            _player.play()
        } else {
            fatalError("Failed to restart video")
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        player?.pause()
        (UIApplication.sharedApplication().delegate as! AppDelegate).startIdleTimer()
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).timer?.invalidate()
        restartVideo()
        super.viewWillAppear(animated)
    }
    
    func onTapReceived() {
        performSegueWithIdentifier("tomain", sender: self)
    }
    
}