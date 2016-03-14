//
//  PersistenceHelper.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

func removeTestFile(path: String) {
    let fileManager = NSFileManager()
    
    if (fileManager.fileExistsAtPath(path)) {
        try! fileManager.removeItemAtPath(path)
    }
}

func fileExists(path: String) -> Bool {
    let fileManager = NSFileManager()
    
    return fileManager.fileExistsAtPath(path)
}
