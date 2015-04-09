//
//  MasterCard.swift
//  foldlings
//
//  Created by nook on 3/22/15.
//  Copyright (c) 2015 nook. All rights reserved.
//

import Foundation

class MasterCard:FoldFeature{
    
    //         top
    //   S_______________
    //   |              |
    // l0|              |r0
    //   |              |
    //   |_ _ master _ _|
    //   |              |
    // l1|              |r1
    //   |              |
    //   |              |
    //   ---------------E
    //        bottom
    
    override func getEdges()->[Edge]{
        
        if let returnee = cachedEdges {
            return returnee
        }
        
        let top = Edge.straightEdgeBetween(startPoint!, end:CGPointMake(endPoint!.x, startPoint!.y), kind: .Cut)
        let bottom = Edge.straightEdgeBetween(endPoint!, end:CGPointMake(startPoint!.x, endPoint!.y), kind: .Cut)
        let midPointDist = (endPoint!.y - startPoint!.y)/2
        let l0 = Edge.straightEdgeBetween(startPoint!, end: CGPointMake(startPoint!.x, startPoint!.y + midPointDist), kind: .Cut)
        let l1 = Edge.straightEdgeBetween(l0.end, end: CGPointMake(startPoint!.x, endPoint!.y), kind: .Cut)
        let r1 = Edge.straightEdgeBetween(endPoint!, end: CGPointMake(endPoint!.x,endPoint!.y-midPointDist), kind: .Cut)
        let r0 = Edge.straightEdgeBetween(r1.end, end: CGPointMake(endPoint!.x,startPoint!.y), kind: .Cut)
        
        var returnee = [top,bottom,l0,l1,r0,r1]
        // if there are no children, then we just need to draw a single fold
        // maybe we don't want master here after all, but for now the only horizontal folds are the driving edge
        let master = Edge.straightEdgeBetween(l0.end, end:r1.end, kind: .Fold)
        horizontalFolds = [top,bottom]
        
        let fragments = edgeSplitByChildren(master)
    
        for fragment in fragments{
            returnee.append(fragment)
            horizontalFolds.append(fragment)
        }
        
        
        for edge in returnee{
            edge.isMaster = true
        }
        
        cachedEdges = returnee
        claimEdges()
        return returnee
        
    }
    
    /// bounding box is start & end point
    override func boundingBox() -> CGRect? {
        return CGRectMake(startPoint!.x, startPoint!.y, endPoint!.x - startPoint!.x, endPoint!.y - startPoint!.y)
    }
}