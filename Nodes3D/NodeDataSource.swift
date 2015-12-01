//
//  NodeDataSource.swift
//  Nodes3D
//
//  Created by Vladimir Hudnitsky on 12/1/15.
//  Copyright © 2015 Rubyroid Labs. All rights reserved.
//

import Foundation
import Parse
class NodeDataSource {
    
    let root: PFObject
    var childrens: [NodeDataSource]
    
    init(root: PFObject){
        self.root = root
        self.childrens = []
    }
    
    func getNodes() -> [NodeDataSource]{
        return childrens
    }
    
    func getRoot() -> PFObject{
        return root
    }
    
    func setChildrens(childrens: [NodeDataSource]){
        self.childrens = childrens
    }
    
    func setChildrensForNode(childrens: [NodeDataSource], node: NodeDataSource){
        if(root.objectId == node.root.objectId){
            if(self.childrens.count > 0){
                self.childrens = []
            }else{
                self.setChildrens(childrens)
            }
        }else{
            checkInDeep(self.childrens, childrens: childrens, node: node)
        }
    }
    
    func addChildForNode(child: NodeDataSource, node: NodeDataSource){
        if(root.objectId == node.root.objectId){
            self.childrens.append(child)
        }else{
            checkInDeep(self.childrens, child: child, node: node)
        }
    }
    
    private func checkInDeep(rootNodes: [NodeDataSource], childrens:[NodeDataSource], node: NodeDataSource){
        rootNodes.forEach{ (e) -> () in
            if(e.root.objectId == node.root.objectId){
                if(e.childrens.count > 0){
                    e.setChildrens([])
                }else{
                    e.setChildrens(childrens)
                }
            }else{
                checkInDeep(e.getNodes(), childrens: childrens, node: node)
            }
        }
    }
    
    private func checkInDeep(rootNodes: [NodeDataSource], child: NodeDataSource, node: NodeDataSource){
        rootNodes.forEach{ (e) -> () in
            if(e.root.objectId == node.root.objectId){
                e.childrens.append(child)
            }else{
                checkInDeep(e.getNodes(), child: child, node: node)
            }
        }
    }
}