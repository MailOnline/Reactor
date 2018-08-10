func flip <T,U,V>(_ f: @escaping (T) -> (U) -> V) -> (U) -> (T) -> V {    
    return {t in { u in f(u)(t) } }
}
