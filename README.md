![](Logo/logo.png)

[![Build Status](https://travis-ci.org/MailOnline/Reactor.svg?branch=master)](https://travis-ci.org/MailOnline/Reactor)
[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

#### Intro

Reactor provides a [Model layer](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core) with minimum configuration. It makes use of the following elements to achieve that:

* [Network](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core/Network)
* [Parser](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core/Parser)
* [Persistence](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core/Persistence)
* [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) as its only dependency.

Reactor's then uses common flows (represented by the `ReactorFlow<T>`), that are typically seen in applications. For example:

 1. Does persisted data exists and it's valid?
  1. **Yes**: Use it ✅
  2. **No**: Fetch data from network
    1. Do we have internet?
      1. **Yes**: make the Request.
        1. Parse the data and persist it (send any error that might happen) ✅
        2. Request failed: send an error ❌
       2. **No**: send an error ❌

This particular flow is provided out of the box by Reactor. In the future we will provide others. 

## Why should you use Reactor? ✅

* You are are starting a new project. 🌳
* You are in the process of defining your model layer. 🛠
* You are creating a prototype or demo and you need something working quickly. 🚀
* You don't feel confortable enough with [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) and need some help with the setup. 🆒
* You already have your Model layer in place, but you think Reactor could formalize your flows. ✨ 

## Why shouldn't you use Reactor? ❌

* You have an unusual flow, that doesn't really fit the `ReactorFlow<T>`. ⛔️
* You already have a Model layer and you feel it wouldn't really benifit you in any way. 😞
* You already got a parser and your own network library (Alamofire for example). 🔥
* After checking the [Advance usage](#advance-usage), Reactor doesn't provide what you need. 😭😭

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

extension Author: Mappable { 

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
}
```
**Note:** The above implementation, is just an example, you are free to use whatever means you prefer.

The first function `mapToModel` is what allows a model object to be created (JSON ➡️ Model). The second function `mapToJSON` is the inverse (Model ➡️ JSON).

The second step would be:

```swift
let baseURL = NSURL(string: "https://myApi.com")!
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

#### Without Persistence
 
If it doesn't make sense to persist data, you pass the `persistencePath` an an empty string (`""`) or:

```swift
let baseURL = NSURL(string: "https://myApi.com")!
let reactor = Reactor<Author>(baseURL:baseURL)
```

In the future will make this explicit via a `ReactorConfiguration`. As for the `mapToJSON` function, you can simply return a:

```swift
func mapToJSON() -> AnyObject {
  return NSNull()
}
```

#### Advance Usage

In order to make most of Reactor, keep the following in mind (these are `ReactorFlow<T>`'s properties):

```swift
var networkFlow: Resource -> SignalProducer<T, Error>
var loadFromPersistenceFlow: Void -> SignalProducer<T, Error>
var saveToPersistenceFlow: T -> SignalProducer<T, Error>
```

All three properties are mutable (`var`) on purpose, so you can extend specific behaviours. For example, you migth be interested in knowing why `loadFromPersistenceFlow` is failing and log it. With the default flow, this is not possible to do, because if `loadFromPersistenceFlow` fails, the network flow will kick in and the error is lost. 

A way to accomplish this, is by creating a default flow and then extending it:

```swift
let baseURL = NSURL(string: "https://myApi.com")!
let reactor = Reactor<Author>(persistencePath: path, baseURL:baseURL)

let extendedPersistence = reactor.loadFromPersistenceFlow().on(failure: { error in print(error) })
reactor.loadFromPersistenceFlow =  { extendedPersistence }
```

You can further decompose the flow, since all the core pieces are exposed in the public api. More concretly:

* [`Network`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Network/Network.swift) and the [`Connection`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Network/Connection.swift) protocol
* [`Parser`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Parser/Parser.swift)
* [`InDiskPersistenceHandler<T>`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Persistence/InDiskPersistence.swift) 

The default flow provided by Reactor ([Intro](https://github.com/MailOnline/Reactor#intro)) is something you are welcome to use, but not tied to. Keep in mind the following when creating your own flows:

The `Reactor<T>`'s `fetch` function axiom:

* the `loadFromPersistenceFlow` will always be called first. If it fails the `fetchFromNetwork` is called.

The `Reactor<T>`'s `fetchFromNetwork` function axiom:

* the `networkFlow` will always be called first, if it successeds it will be followed by `saveToPersistenceFlow`.

## License
Reactor is licensed under the MIT License, Version 2.0. [View the license file](LICENSE)

Copyright (c) 2015 MailOnline

Header image by [Henrique Macedo](https://twitter.com/henrikemacedo). 
