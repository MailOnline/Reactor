//
//  ThreadUtility.swift
//  Reactor
//
//  Created by Rui Peres on 20/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import Foundation

func isMainThread() -> Bool {
    return NSThread.isMainThread()
}