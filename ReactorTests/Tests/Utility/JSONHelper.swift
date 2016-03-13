//
//  JSONHelper.swift
//  Reactor
//
//  Created by Rui Peres on 04/07/2015.
//  Copyright © 2015 Mail Online. All rights reserved.
//

import Foundation
import XCTest

func JSONFromFile(file: String) -> AnyObject {
    
    let path = NSBundle(forClass: JSONFileReader.self).pathForResource(file, ofType: "json")
    let data = NSData(contentsOfFile: path!)
    
    return try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
}

func dataFromFile(file: String) -> NSData {
    
    let path = NSBundle(forClass: JSONFileReader.self).pathForResource(file, ofType: "json")
    
    return NSData(contentsOfFile: path!)!
}

func delay(delay:Double, closure: Void -> Void) {
    
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(dispatchTime, dispatch_get_main_queue(), closure)
}

private class JSONFileReader { }