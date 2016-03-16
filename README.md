
Reactor
-----
[![Build Status](https://travis-ci.org/MailOnline/Reactor.svg?branch=master)](https://travis-ci.org/MailOnline/Reactor)
[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

Reactor's goal is to provide, out of the box, a Model layer with its different components connected with each other.

#### Intro

With minimum setup, Reactor provides:

* Network 
* Parsing
* Persistence

Reactor's then uses common flows (represented by the `ReactorFlow<T>`), that are typically seen in applications. For example:

 1. Does persisted data exists and it's valid?
  1. **Yes**: Use it ✅
  2. **No**: Fetch data from network
    1. Do we have internet?
     1. **Yes**: make the Request.
       1. Parse the data and persist it (send any error that might happen) ✅
       2. Request failed: send an error ❌
      2. **No**: send an error ❌

This particular flow is provided by Reactor. In the future we will provide others. 

## Who should use Reactor?

* You are are starting a new project. 🌳
* You are in the process of defining your model layer. 🛠
* You are creating a prototype or demo and you need something working quickly. 🚀
* You don't feel confortable enough with [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) and need some help with the setup. 🆒
* You already have your Model layer in place, but you think Reactor could formalize your flows. ✨ 

## How to use

#### Carthage

```
github "MailOnline/Reactor"
```

#### Basic setup

For Reactor to work, you need to make sure your Model objects comply with the `Mappable` protocol. This protocol allows you to encode and decode an object. This is necessary for parsing the object (coming from the network) and storing it in disk.

Let's use the `Author` struct as an example ([this can be found in the Unit tests](https://github.com/MailOnline/Reactor/blob/master/ReactorTests/Tests/Stubs/Article.swift)). The first step is to make the `Author`
struct compliant with the `Mappable` protocol: 

```swift
struct Author {
    let name: String
}
```

Complying with the `Mappable` protocol is quite straighforward:

```swift
static func mapToModel(object: AnyObject) -> Result<Author, MappedError> {

 guard
  let dictionary = object as? [String: AnyObject],
  let name = dictionary["name"] as? String
  else { return Result(error: MappedError.Custom("Invalid dictionary @ \(Author.self)\n \(object)"))}

  let author = Author(name: name)

  return Result(value: author)
}
 
func mapToJSON() -> AnyObject {
  return ["name": self.name]
}
```

The first function `static func mapToModel` is what allows an object to be created from a `Dictionary`. The second function `mapToJSON` is the reverse process.

The second step would be:

```swift
let baseURL = NSURL(string: "https://myApi.com"!)
let reactor = Reactor<Author>(persistencePath: path, baseURL:baseURL)
```

Now that you have the `reactor` ready, it exposes two functions:

```swift
func fetch(resource: Resource) -> SignalProducer<T, Error>
func fetchFromNetwork(resource: Resource) -> SignalProducer<T, Error>
```

We find that these are the two most common scenarios:

1. When you get inside a new screen, you try to get some data. In this case, Reactor checks first the persistence and if it fails it will fallback to the network.
2. You want new data, so Reactor will try the network.

The final piece is the `Resource`, which is nothing more than struct that encapsulates how the request will be made:

* path
* query
* body
* HTTP headers
* HTTP method

 
