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
    var root : PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getRoot()
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

    func addNode(let name : String){
        if let rootObj = self.root{
            ParseManager().createNode(name, parent: rootObj) { (newNode, error) -> Void in
                if error != nil || newNode == nil{
                    print(error)
                    return
                }
                self.root!.addObject(newNode!, forKey: "nodes")
                self.root!.saveEventually()
            }
        }
    }
    
    func getRoot(){
        ParseManager().getRoot{ (object : PFObject?, error :NSError?) -> Void in
            if let obj = object{
                do{
                    try obj.fetchIfNeeded()
                }catch {}
                self.root = obj
                let nodes = obj["nodes"]
                print("nodes  \(nodes.count)")
            }
        }
    }
}
