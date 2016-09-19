//
//  curry.swift
//  Reactor
//
//  Created by Rui Peres on 14/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

func curry<T, U, V>(_ function: @escaping (T, U) -> V) -> (T) -> (U) -> V {
    
    return { t in { u in function(t, u) } }
}
