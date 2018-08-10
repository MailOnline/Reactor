func curry<T, U, V>(_ function: @escaping (T, U) -> V) -> (T) -> (U) -> V {    
    return { t in { u in function(t, u) } }
}
