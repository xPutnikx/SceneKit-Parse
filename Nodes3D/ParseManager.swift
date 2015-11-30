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
        nodeObject.saveInBackgroundWithBlock { (success, error) -> Void in
            if(error != nil || !success){
                block(newNode: nil, error: error)
                return
            }
            block(newNode: nodeObject, error: nil)
        }
    }
    
    func updateNode(let nodeId : String, let newName : String){
        let query = PFQuery(className: "Node")
        query.getObjectInBackgroundWithId(nodeId) { (object, error) -> Void in
            if error != nil || object == nil{
                return;
            }
            if let obj = object {
                obj["name"] = newName
                obj.saveEventually()
            }
        }
    }
    
    func deleteNode(let nodeId: String){
        let query = PFQuery(className: "Node")
        query.getObjectInBackgroundWithId(nodeId) { (object, error) -> Void in
            if error != nil || object == nil{
                return;
            }
            if let obj = object{
                obj.deleteEventually()
            }
        }
    }
    
    func getRoot(block: ((PFObject?, NSError?) -> Void)?){
        let nodeQuery = PFQuery(className: "Node")
        nodeQuery.getObjectInBackgroundWithId("fZQC45KnMu", block: block)
    }
    
}