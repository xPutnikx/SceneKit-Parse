//
//  ParseManager.swift
//  Nodes3D
//
//  Created by Vladimir Hudnitsky on 11/30/15.
//  Copyright © 2015 Rubyroid Labs. All rights reserved.
//

import Foundation
import Parse
class ParseManager{
    
    func createNode(let name : String, let parent : PFObject, block: (newNode : PFObject?, error : NSError?) -> Void){
        let nodeObject = PFObject(className: "Node")
        nodeObject["name"] = name
        nodeObject["nodes"] = []
        nodeObject.saveInBackgroundWithBlock { success, error in
            guard success else {
                print(error)
                block(newNode: nil, error: error)
                return
            }
            parent.addObject(nodeObject, forKey: "nodes")
            parent.saveEventually()
            block(newNode: nodeObject, error: nil)
        }
    }
    
    func updateNode(let nodeId : String, let newName : String){
        let query = PFQuery(className: "Node")
        query.getObjectInBackgroundWithId(nodeId) { object, error in
            guard let obj = object else { return }
            obj["name"] = newName
            obj.saveEventually()
        }
    }
    
    func deleteNode(let nodeId: String){
        let query = PFQuery(className: "Node")
        query.getObjectInBackgroundWithId(nodeId) { object, error in
            guard let obj = object else { return }
            obj.deleteEventually()
        }
    }
    
    func getRoot(block: ((PFObject?, NSError?) -> Void)?){
        let nodeQuery = PFQuery(className: "Node")
        nodeQuery.includeKey("nodes")
        nodeQuery.getObjectInBackgroundWithId("fZQC45KnMu", block: block)
    }
    
    func getChildNodes(node: PFObject, block: (([PFObject]?, NSError?) -> Void)?){
        let nodeQuery = PFQuery(className: "Node")
        nodeQuery.includeKey("nodes")
        nodeQuery.getObjectInBackgroundWithId(node.objectId!) { nodeObj, error in
            guard let nodes = nodeObj?["nodes"] as? [PFObject] else {
                block!(nil, error)
                return
            }
            block!(nodes, nil)
        }
    }

}