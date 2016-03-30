//
//  flip.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

func flip <T,U,V>(f: T -> U -> V) -> U -> T -> V {
    
    return {t in { u in f(u)(t) } }
}