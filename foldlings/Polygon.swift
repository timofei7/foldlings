//
//  Polygon.swift
//  foldlings
//
//  Created by nook on 6/7/15.
//  Copyright (c) 2015 Marissa Allen, Nook Harquail, Tim Tregubov.  All Rights Reserved.
//

import Foundation

class Polygon:FoldFeature{

    // the (draggable) points that define the polygon
    var points:[CGPoint] = []
    //the path through the points
    var path: UIBezierPath?
    //the intersection points calculated by featureSpansFold & used for occlusion
    var intersectionsWithDrivingFold:[CGPoint] = []
    
    //the path through polygon points
    class func pathThroughPolygonPoints(points:[CGPoint]) -> UIBezierPath? {
        return UIBezierPath()
        var ps = points
    
        //return nil if we can't draw a path
        if(ps.isEmpty){
            return nil
        }
        
        var polyPath = UIBezierPath()
        // move to the first point & pop it off the array
        polyPath.moveToPoint(ps.shift()!)
        // draw lines between the remaining points
        points.map({polyPath.addLineToPoint($0)})
//        polyPath.closePath()
        
        return polyPath
    }
    
    // set intersections here
    override func featureSpansFold(fold: Edge) -> Bool {
        return false
    }
    
    func polyPointAt(point:CGPoint) -> CGPoint?{
        return nil
    }
    
    func addPoint(point:CGPoint){
        points.append(point)
        path = Polygon.pathThroughPolygonPoints(points)
        
        if(points.count>1){
        featureEdges?.append(Edge.straightEdgeBetween(points[points.count - 2], end: points.last!, kind: .Cut, feature: self))
            println(featureEdges)
        }
        else{
            featureEdges = []
        }
 
        endPoint = point
    }
    
    func movePolyPoint(from:CGPoint, to:CGPoint) {
    
    }
    

    override func tapOptions() -> [FeatureOption]?{
        var options:[FeatureOption] = super.tapOptions() ?? []
        
        options.append(.DeleteFeature)
        
        if(self.isLeaf() && horizontalFolds.count >= 3){
            options.append(.MoveFolds);
        }
        
        options.append(.MovePoints)

        return options
        
    }
    
}