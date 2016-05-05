//
//  GameViewController.swift
//  Ugly Fish
//
//  Created by Martin  on 2016-05-03.
//  Copyright (c) 2016 Martin . All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
}
