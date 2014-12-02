//
//  Constants.swift
//  foldlings
//
//

import Foundation
import UIKit



let kLineWidth:CGFloat = 2.0
let kHitTestRadius = CGFloat(10.0)
let kMinLineLength = kHitTestRadius * 2.0



func getRandomColor(alpha:CGFloat) -> UIColor{
    var randomRed:CGFloat = CGFloat(drand48())
    var randomGreen:CGFloat = CGFloat(drand48())
    var randomBlue:CGFloat = CGFloat(drand48())
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
}


func getSmartRandomColor(alpha:CGFloat, horizontal: Bool) -> UIColor{
    var randomRed:CGFloat = CGFloat(drand48())
    var randomGreen:CGFloat = CGFloat(drand48())
    var randomBlue:CGFloat = CGFloat(drand48())
    return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
}

