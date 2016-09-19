//
//  PersistenceHelper.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

func removeTestFile(_ path: String) {
    let fileManager = FileManager()
    
    if (fileManager.fileExists(atPath: path)) {
        try! fileManager.removeItem(atPath: path)
    }
}

func fileExists(_ path: String) -> Bool {
    let fileManager = FileManager()
    
    return fileManager.fileExists(atPath: path)
}
