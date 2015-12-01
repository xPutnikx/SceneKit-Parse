//
//  GameViewController.swift
//  Nodes3D
//
//  Created by Vladimir Hudnitsky on 11/30/15.
//  Copyright (c) 2015 Rubyroid Labs. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Parse

class GameViewController: UIViewController {
    var renderer : SceneRenderer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scn = self.view as? SCNView{
            renderer = SceneRenderer(scnView: scn)
            renderer?.createScene()
        }
    }
        
    override func shouldAutorotate() -> Bool {
        return true
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
