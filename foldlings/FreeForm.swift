//
//  FreeForm.swift
//  foldlings
//
//  Created by nook on 3/24/15.
//  Copyright (c) 2015 nook. All rights reserved.
//

import Foundation

class FreeForm:FoldFeature{
    
    var path: UIBezierPath?
    var interpolationPoints:[AnyObject] = []
    var lastUpdated:NSDate = NSDate(timeIntervalSinceNow: 0)
    var cachedPath:UIBezierPath? = UIBezierPath()
    var closed = false
    //the intrsection points calculated by featureSpansFold & used for occlusion
    var intersectionsWithDrivingFold:[CGPoint] = []
    
    override init(start: CGPoint) {
        super.init(start: start)
        interpolationPoints.append(NSValue(CGPoint: start))
    }
    
    override func getEdges() -> [Edge] {
        
        //if there are cached edges, return them
        if let cache = cachedEdges {
            println("freeform cache HIT!!")
            return cache
        }
        
        if let p = path{
            
            let edge = Edge(start: p.firstPoint(), end: p.lastPoint(), path: p, kind: .Cut, isMaster: false)
            
            return [edge]
        }
        else{
            return [Edge.straightEdgeBetween(startPoint!, end: CGPointZero, kind: .Cut)]
        }
    }
    
    
    /// splits a path at each of the points, which are already known to be on it
    class func pathSplitByPoints(path:UIBezierPath,breakers:[CGPoint]) ->[UIBezierPath]{
        
        
        var breaks = breakers
        let elements = path.getPathElements()
        let points = getSubdivisions(elements)
        var pointBins: [[CGPoint]] = [[]]
        
        // find the nearest point
        // this is necessary because the subdivisions are not guaranteed equal all the time
        // but will usually be pretty exact
        var minDist = CGFloat(1)
        
        for (i, point) in enumerate(points)
        {
            
            pointBins[pointBins.count-1].append(point)

            for (var i = 0; i<breaks.count; i++){
                if(ccpDistance(point,breaks[i]) < minDist){
                    pointBins.append([point])
                    breaks.remove(breaks[i])
                }
            }
        }

        
        var paths:[UIBezierPath] = []
        for bin in pointBins{
            paths.append(pathFromPoints(bin))
        }
        
        println(paths.count)
        return paths
        
    }
    
    /// this function should be called exactly once, when the feature is created at the end of a pan gesture
    func freeFormEdgesSplitByIntersections() ->[Edge]{
        
        // if there are no interercepts to split on, return the path whole
        if intersectionsWithDrivingFold.count == 0{
            return [Edge(start: path!.firstPoint(), end: path!.lastPoint(), path: path!, kind: .Cut, isMaster: false)]
        }
        else{
            
//            var cgpoints:[CGPoint] = []
//            for cgpoint in interpolationPoints{
//                cgpoints.append((cgpoint as! NSValue).CGPointValue())
//            }
            
            let paths = FreeForm.pathSplitByPoints(path!,breakers: intersectionsWithDrivingFold)
            
            var edges:[Edge] = []
            
            for p in paths{
                edges.append(Edge(start: p.firstPoint(), end: p.lastPoint(), path: p, kind: .Cut, isMaster: false))
            }
            
            return edges
        }
    }
    
    
    
    //the bezier path through a set of points
    func pathThroughTouchPoints() -> UIBezierPath{
        
        //if the points are far enough apart, make a new path
        //(Float(ccpDistance((interpolationPoints.last! as! NSValue).CGPointValue(), endPoint!)) > 2
        if (cachedPath == nil || (Float(ccpDistance((interpolationPoints.last! as! NSValue).CGPointValue(), endPoint!)) > 5)){
            lastUpdated = NSDate(timeIntervalSinceNow: 0)
            
            interpolationPoints.append(NSValue(CGPoint: endPoint!))
            
            //set the curve to be closed when we are close to the endpoint
            var closed = false
            if interpolationPoints.count > 7
                &&
                ccpDistance((interpolationPoints.first! as! NSValue).CGPointValue(), endPoint!) < kMinLineLength*2{
                    closed = true
            }
            
            //if ther are enough points, draw a full curve
            if(interpolationPoints.count > 3){
                let path = UIBezierPath()
                
                //the line between the first two points, which is not part of the catmull-rom curve
                if(!closed){
                    path.moveToPoint(interpolationPoints[0].CGPointValue())
                    path.addLineToPoint(interpolationPoints[1].CGPointValue())
                }
                
                path.appendPath(UIBezierPath.interpolateCGPointsWithCatmullRom(interpolationPoints, closed: closed,alpha: 1.0))
                
                //                path.appendPath(UIBezierPath.interpolateCGPointsWithHermite(interpolationPoints, closed: closed))
                
                //the line to the currrent touch point from the end
                if(!closed){
                    path.addLineToPoint(endPoint!)
                }
                cachedPath = path
                return path
                
            }
            else{
                //for low numbers of points, return a straight line
                let path = UIBezierPath()
                path.moveToPoint(startPoint!)
                path.addLineToPoint(endPoint!)
                cachedPath = path
                return path
            }
            
        }
        return cachedPath!
    }
    
    override func featureSpansFold(fold: Edge) -> Bool {
        
        //first, test if y value is within cgrect ys
        
        
        let lineRect = CGRectMake(fold.start.x,fold.start.y,fold.end.x - fold.start.x,1)
        
        
        //if the line does not intersect the bezier's bounding box, the fold can't span it
        if(!CGRectIntersectsRect(self.boundingBox()!,lineRect)){
            return false
        }
        else{
            
            if let intersects = PathIntersections.intersectionsBetweenCGPaths(fold.path.CGPath,p2: self.path!.CGPath){
                
                intersectionsWithDrivingFold = intersects
                return true
                
            }
            return false
        }
        
    }
    
    override func boundingBox() -> CGRect? {
        return path?.boundsForPath()
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
        
    }
    
    override func splitFoldByOcclusion(edge: Edge) -> [Edge] {
        
        
        let start = edge.start
        let end = edge.end
        var returnee = [Edge]()
        
        
        if intersectionsWithDrivingFold.count == 0{
            
            return [edge]
        }
        
        
        
        let firstPiece = Edge.straightEdgeBetween(start, end: intersectionsWithDrivingFold.first!, kind: .Fold)
        returnee.append(firstPiece)
        
        var brushTip = intersectionsWithDrivingFold[0]
        
        //skip every other point
        for (var i = 1; i < intersectionsWithDrivingFold.count-1; i+=2){
            
            brushTip = intersectionsWithDrivingFold[i]
            let brushTipTranslated = CGPointMake(intersectionsWithDrivingFold[i+1].x,brushTip.y)
            let piece = Edge.straightEdgeBetween(brushTip, end: brushTipTranslated, kind: .Fold)
            returnee.append(piece)
        }
        
        let finalPiece = Edge.straightEdgeBetween(intersectionsWithDrivingFold.last!, end: end, kind: .Fold)
        returnee.append(finalPiece)
        return returnee
    }
    
}