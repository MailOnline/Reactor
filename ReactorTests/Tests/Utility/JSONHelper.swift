//
//  JSONHelper.swift
//  Reactor
//
//  Created by Rui Peres on 04/07/2015.
//  Copyright © 2015 Mail Online. All rights reserved.
//

import Foundation
import XCTest

func JSONFromFile(_ file: String) -> AnyObject {
    
    let path = Bundle(for: JSONFileReader.self).path(forResource: file, ofType: "json")
    let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
    
    return try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
}

func dataFromFile(_ file: String) -> Data {
    
    let path = Bundle(for: JSONFileReader.self).path(forResource: file, ofType: "json")
    
    return (try! Data(contentsOf: URL(fileURLWithPath: path!)))
}

func delay(_ delay:Double, closure: @escaping (Void) -> Void) {
    
    let dispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: closure)
}

private class JSONFileReader { }
