//
//  SceneRenderer.swift
//  Nodes3D
//
//  Created by Vladimir Hudnitsky on 11/30/15.
//  Copyright © 2015 Rubyroid Labs. All rights reserved.
//

import Foundation
import SceneKit
import Parse

class SceneRenderer : NSObject{
    let sceneView : SCNView
    let cameraNode: SCNNode
    var root : PFObject?
    var scene : SCNScene
    var objectsScene : SCNScene
    var dataSource: NodeDataSource?
    var maxX : Float = 0
    var maxY : Float = 0
    var allowedColor : UIColor = UIColor(red: 0/255, green: 185/255, blue: 230/255, alpha: 1.0)
    var closingColor : UIColor = UIColor(red: 247/255, green: 82/255, blue: 106/255, alpha: 1.0)
    
    init(scnView : SCNView){
        self.sceneView = scnView
        scene = SCNScene()
        objectsScene = SCNScene()
        cameraNode = SCNNode()
    }
    
    func createScene(){
        self.getRoot { success in
            if success {
                if let rootObj = self.root {
                    self.dataSource = NodeDataSource(root: rootObj)
                    self.renderNodes()
                }
            }
        }

        scene.rootNode.addChildNode(objectsScene.rootNode)
        
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.blackColor()
        sceneView.autoenablesDefaultLighting = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        sceneView.addGestureRecognizer(tapGesture)
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: "longPress:")
        sceneView.addGestureRecognizer(longTapGesture)
    }
    
    func longPress(gestureRecongize: UILongPressGestureRecognizer){
        if gestureRecongize.state == .Ended {
            let p = gestureRecongize.locationInView(sceneView)
            let hitResults = sceneView.hitTest(p, options: nil)
            if hitResults.count > 0 {
                let result = hitResults.first!
                let scnNode = result.node
                self.highlightNode(scnNode, color: UIColor.greenColor())
                if let nodeObj = scnNode.accessibilityElements![0] as? NodeDataSource{
                    self.addNode("name_\(NSDate().timeIntervalSince1970.description)", parent: nodeObj)
                }
            }

        }
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.locationInView(sceneView)
        let hitResults = sceneView.hitTest(p, options: nil)
        if hitResults.count > 0 {
            let result = hitResults.first!
            let scnNode = result.node
            self.highlightNode(scnNode, color: UIColor.redColor())
            
            if let nodeObj = scnNode.accessibilityElements![0] as? NodeDataSource{
                print("tap on node : \(nodeObj.root.objectId)")
                ParseManager().getChildNodes(nodeObj.root) { childrensObj, error in
                    if let childrens = childrensObj{
                        var childrensDS : [NodeDataSource] = []
                        childrensDS = childrens.map{
                            NodeDataSource(root: $0)
                        }
                        self.dataSource?.setChildrensForNode(childrensDS, node: nodeObj)
                        
                        //redraw
                        self.renderNodes()
                    }
                }
            }
        }
    }
    
    private func renderNodes(){
        self.objectsScene.rootNode.childNodes.forEach { (e) -> () in
            e.removeFromParentNode()
        }
        self.maxX = 1
        self.maxY = 1
        let scnNode = self.objectsScene.rootNode
        let ds = self.dataSource!
        renderLayer(scnNode, ds: ds, x: 0, y: 0)
        self.cameraNode.position = SCNVector3(x: self.maxX / 2, y: self.maxY / 2, z: 15 + abs(self.maxY))
    }
    
    private func renderLayer(let rootNode: SCNNode, let ds: NodeDataSource, let x: Int, let y: Int) -> Int{
        let scnNode = addBox(rootNode, ds: ds, position: SCNVector3Make(Float(x), Float(y), 0))
        var tmpX :Int = 0
        var tmpY :Int = 0
        if ds.getNodes().count > 0{
            tmpX++
            maxX++
            scnNode.geometry?.firstMaterial?.diffuse.contents = closingColor
        }else if ds.root["nodes"]?.count > 0{
            scnNode.geometry?.firstMaterial?.diffuse.contents = allowedColor
        }
        var i = 0
        for e in ds.getNodes(){
            i++
            let level = renderLayer(scnNode, ds: e, x: tmpX, y: tmpY)
            if(i != ds.getNodes().count){
                tmpY--
                maxY--
            }
            tmpY += level
        }
        return tmpY
    }
    
    private func highlightNode(node : SCNNode, color: UIColor){
        let material = node.geometry!.firstMaterial!
        
        // highlight it
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(0.5)
        
        // on completion - unhighlight
        SCNTransaction.setCompletionBlock {
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            material.emission.contents = UIColor.blackColor()
            SCNTransaction.commit()
        }
        
        material.emission.contents = color
        SCNTransaction.commit()
    }
    
    //draw node on scene
    private func addBox(let rootNode: SCNNode, let ds: NodeDataSource, let position : SCNVector3) -> SCNNode{
        let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = position
        boxNode.accessibilityElements = [ds]
        boxNode.accessibilityLabel = ds.root.objectId!
        rootNode.addChildNode(boxNode)
        return boxNode
    }
    
    
    //add node to server
    private func addNode(let name : String, let parent: NodeDataSource){
        ParseManager().createNode(name, parent: parent.root) { newNode, error in
            guard let newNode = newNode else { return }
            self.dataSource?.addChildForNode(NodeDataSource(root: newNode), node: parent)
            
            //redraw
            self.renderNodes()
        }
    }
    
    //get root from server for init datasource
    private func getRoot(block: (success: Bool) -> Void){
        ParseManager().getRoot{ object, error in
            if let obj = object {
                self.root = obj
                block(success: true)
            } else {
                block(success: false)
            }
        }
    }

}