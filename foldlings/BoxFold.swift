
import Foundation

class BoxFold:FoldFeature{
    
    override func getEdges() -> [Edge] {
        
        if let returnee = cachedEdges {
//            println("BOX: cache hit")
            return returnee
        }
        
//        println("  BOX: cache MISS")
        
        // make h0, h1, and h2 first.  Then s0, s1, s2, e0, e1, e2....
        //
        //                  h0
        //            S- - - - -
        //         s0 |         | e0
        //            |     h1  |
        //            - - - - - -
        //         s1 |         | e1
        //     _ _ _ _|         |_ _ _ _ _ driving
        //            |         |
        //         s2 |     h2  | e2
        //            - - - - - E
        //
        var returnee:[Edge] = []
        let h0 = Edge.straightEdgeBetween(startPoint!, end:CGPointMake(endPoint!.x, startPoint!.y), kind: .Fold)
        let h2 = Edge.straightEdgeBetween(CGPointMake(startPoint!.x, endPoint!.y), end:endPoint!, kind: .Fold)
        horizontalFolds = [h0,h2]
        
        returnee.append(h0)
        returnee.append(h2)
        
        //if there's a driving fold
        if let master = drivingFold{
            
            let masterDist = endPoint!.y - master.start.y
            let h1 = Edge.straightEdgeBetween(CGPointMake(startPoint!.x, startPoint!.y + masterDist), end:CGPointMake(endPoint!.x, startPoint!.y + masterDist), kind: .Fold)
            returnee.append(h1)
            horizontalFolds.append(h1)
            
            // this is fine because the box is a rectangle; in the future we'll have to get intersections
            // getting intersections on every drag might be too expensive...
            let tempMasterStart = CGPointMake(startPoint!.x, master.start.y)
            let tempMasterEnd = CGPointMake(endPoint!.x, master.start.y)
            let tempMaster = Edge.straightEdgeBetween(tempMasterStart, end: tempMasterEnd, kind: .Fold)
            horizontalFolds.append(tempMaster)
            
            //sort horizontal folds by y height
            horizontalFolds.sort({ (a:Edge, b:Edge) -> Bool in
                return a.start.y < b.start.y
            })
            //all hfolds are "drawn" left to right
            //this makes the vertical cuts
            // #TODO: in the future, we'll have to skip some of these, which will be replaced with user-defined cuts
            var foldsToAppend = [Edge]()
            for (var i = 0; i < (horizontalFolds.count - 1); i++){
                
                let leftPoint = horizontalFolds[i].start
                let nextLeftPoint = horizontalFolds[i + 1].start
                
                let rightPoint =  horizontalFolds[i].end
                let nextRightPoint = horizontalFolds[i + 1].end
                
                let leftEdge = Edge.straightEdgeBetween(leftPoint,end:nextLeftPoint,kind: .Cut)
                let rightEdge = Edge.straightEdgeBetween(rightPoint,end:nextRightPoint,kind: .Cut)
                
                returnee.append(leftEdge)
                returnee.append(rightEdge)
                
            }
            horizontalFolds.remove(tempMaster)
        }
            // otherwise, we only have 4 edges
            //
            //               h0
            //            S------
            //            |      |
            //         s0 |      | e0
            //            |      |
            //            -------E
            //               h2
        else{
            
            let s0 = Edge.straightEdgeBetween(endPoint!, end:CGPointMake(endPoint!.x, startPoint!.y), kind: .Cut)
            let e0 = Edge.straightEdgeBetween(startPoint!, end:CGPointMake(startPoint!.x, endPoint!.y), kind: .Cut)
            
            returnee.append(s0)
            returnee.append(e0)
            
        }
        
        
        cachedEdges = returnee
        claimEdges()
        return returnee
        
    }
    
    // for box folds, this always creates two folds
    override func splitFoldByOcclusion(edge: Edge) -> [Edge] {
        
        let start = edge.start
        let end = edge.end
        var returnee = [Edge]()
        
        
        //make two pieces between the end points of the split fold and the place the intersect with box fold
        let piece = Edge.straightEdgeBetween(start, end: CGPointMake(self.startPoint!.x, start.y), kind: .Fold)
        let piece2 = Edge.straightEdgeBetween(CGPointMake(self.endPoint!.x, start.y), end: end, kind: .Fold)
        
        returnee = [piece,piece2]
        
    return returnee
    
    
}

// bounding box is between start & end point corners
override func boundingBox() -> CGRect? {
    if (startPoint == nil || endPoint == nil){
        return nil;
    }
    return CGRectMake(startPoint!.x, startPoint!.y, endPoint!.x - startPoint!.x, endPoint!.y - startPoint!.y)
}


/// boxFolds can be deleted
/// folds can be added only to leaves
override func tapOptions() -> [FeatureOption]?{
    var options:[FeatureOption] = []
    options.append(.DeleteFeature)
    if(self.isLeaf()){
        options.append(.AddFolds)
    }
    
    return options
    

}}