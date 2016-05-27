![](Logo/logo.png)

[![Build Status](https://travis-ci.org/MailOnline/Reactor.svg?branch=master)](https://travis-ci.org/MailOnline/Reactor)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/MOReactor.svg)](https://cocoapods.org/)
[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

#### Intro

Reactor provides a [Model layer](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core) with minimum configuration. It makes use of the following elements to achieve that:

* [Network](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core/Network)
* [Parser](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core/Parser)
* [Persistence](https://github.com/MailOnline/Reactor/tree/master/Reactor/Core/Persistence)
* [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) as its only dependency.

Reactor then uses flows (represented by the `ReactorFlow<T>`), that are typically seen in applications. For example:

 1. Does persisted data exist and is it valid?
  1. **Yes**: Use it ✅
  2. **No**: Fetch data from the network
    1. Do we have an internet connection?
      1. **Yes**: make the Request.
        1. Parse the data and persist it (send any error that might occur) ✅
        2. Request failed: send an error ❌
       2. **No**: send an error ❌

This particular flow is provided out of the box by Reactor. In the future we will provide others. 

##### What's a flow? 🙄

A flow is nothing more than a stream of events, in our case, that is composed by different pieces ( network, parsing and persistence ). 

## Use Reactor if... ✅

* You are are starting a new project. 🌳
* You are in the process of defining your model layer. 🛠
* You are creating a prototype or demo and you need something working quickly. 🚀
* You don't feel comfortable enough with [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) and need some help with the setup. 🆒
* You already have your Model layer in place, but you think Reactor could formalize your flows. ✨ 

## Not suited if... ❌

* You have an unusual flow, that doesn't really fit the `ReactorFlow<T>`. ⛔️
* You already have a Model layer and you feel it wouldn't really benefit you in any way. 😞
* You already have a parser and your own network library (Alamofire for example). 🔥
* After checking the [Advance usage](#advance-usage), Reactor doesn't provide what you need. 😭😭

## How to use

#### Carthage

```
github "MailOnline/Reactor"
```

#### Cocoapods

```
# Since there is already a podfile named `Reactor`, we are using `MOReactor`.
pod 'MOReactor', '~> 0.9'
```

#### Basic setup

For Reactor to work, you need to make sure your Model objects comply with the `Mappable` protocol. This protocol allows you to encode and decode an object. This is necessary for parsing the object (coming from the network) and storing it on disk.

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
let configuration = FlowConfiguration(usingPersistence: .True("path_to_persistence"))

let flow: ReactorFlow<Author> = createFlow(baseURL, configuration: configuration)
let reactor: Reactor<Author> = Reactor(flow: flow)
```

Now that you have the `reactor` ready, it exposes two functions:

```swift
func fetch(resource: Resource) -> SignalProducer<T, Error>
func fetchFromNetwork(resource: Resource) -> SignalProducer<T, Error>
```

We find that these are the two most common scenarios:

1. When you get to a new screen, you try to get some data. In this case, Reactor checks the persistence first and if it fails it will fallback to the network.
2. You want fresh data, so Reactor will use the network.

The final piece is the `Resource`, which is nothing more than a struct that encapsulates how the request will be made:

* path
* query
* body
* HTTP headers
* HTTP method

#### Configuration

For extra flexibility, you can use the `CoreConfiguration` and `FlowConfiguration` protocols. 

The `CoreConfiguration` protocols defines how the Reactor behaves:

```swift
public protocol CoreConfiguration {
/// If the entire flow should fail, when `saveToPersistenceFlow` fails.
/// `true` by default.
var shouldFailWhenSaveToPersistenceFails: Bool { get }
/// If the `saveToPersistenceFlow`, should be part of the flow.
/// Should be `false` when the flow shouldn't
/// wait for `saveToPersistenceFlow` to finish (for example it takes
/// a long time).
/// Note: if you set it as `false` and it fails, the failure will be
/// lost, because it's not part of the flow, but injected instead .
/// `true` by default.
var shouldWaitForSaveToPersistence: Bool { get }
}
```

The `FlowConfiguration` protocol defines how the Reactor Flow is created:


```swift
public protocol FlowConfiguration {
/// If persistence should be used.
/// `true` by default.
var usingPersistence: Bool { get }
/// If reachability should be used.
/// `true` by default.
var shouldCheckReachability: Bool { get }
/// If the parser should be strick or prune the bad objects.
/// Prunning will simply remove objects are were not parsable, instead
/// of erroring the flow. Strick on the other hand as soon as it finds
/// a bad objects will error the entire flow.
/// Note: if you receive an entire batch of bad objects, it will default to
/// an empty array. Witch leads to not knowing if the server has no results or
/// all objects are badly formed.
/// `true` by default.
var shouldPrune: Bool { get }
}
```

The `FlowConfiguration` protocol is used in the following methods:

```swift
public func createFlow<T where T: Mappable>(baseURL: NSURL, configuration: FlowConfigurable) -> ReactorFlow<T>
public func createFlow<T where T: SequenceType, T.Generator.Element: Mappable>(baseURL: NSURL, configuration: FlowConfigurable) -> ReactorFlow<T>
```

These are convinient methods, that provide a ready to use `ReactorFlow`. **It's important to note**, that if you would like to use a custom persistence (CoreData, Realm, SQLite, etc), you should create a `ReactorFlow` on your own. The reason why, is because the default Persistence class (`InDiskPersistence.swift`) takes a path, where the data will be saved. This might not make sense with other approaches. 
 

#### Without Persistence
 
If it doesn't make sense to persist data, you can:

```swift
let baseURL = NSURL(string: "https://myApi.com")!
let configuration = FlowConfiguration(usingPersistence: .False)
let flow: ReactorFlow<Foo> = createFlow(baseURL, configuration: configuration)
let reactor: Reactor<Foo> = Reactor(flow: flow)
```

As for the `mapToJSON` function, you can simply return an `NSNull`:

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

All three properties are mutable (`var`) on purpose, so you can extend specific behaviours. For example, you might be interested in knowing why `loadFromPersistenceFlow` is failing and log it. With the default flow, this is not possible to do, because if `loadFromPersistenceFlow` fails, the network flow will kick in and the error is lost. 

A way to accomplish this, is by creating a default flow and then extending it:

```swift
let reactorFlow: ReactorFlow<Author> = ...

let extendedPersistence = reactorFlow.loadFromPersistenceFlow().on(failure: { error in print(error) })
reactorFlow.loadFromPersistenceFlow =  { extendedPersistence }
```

You can further decompose the flow, since all the core pieces are exposed in the public API. More specifically:

* [`Network`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Network/Network.swift) and the [`Connection`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Network/Connection.swift) protocol
* [`Parser`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Parser/Parser.swift)
* [`InDiskPersistenceHandler<T>`](https://github.com/MailOnline/Reactor/blob/master/Reactor/Core/Persistence/InDiskPersistence.swift) 

The default flow provided by Reactor ([Intro](https://github.com/MailOnline/Reactor#intro)) is something you are welcome to use, but not tied to. Keep in mind the following when creating your own flows:

The `Reactor<T>`'s `fetch` function invariant:

* the `loadFromPersistenceFlow` will always be called first. If it fails, `fetchFromNetwork` is called.

The `Reactor<T>`'s `fetchFromNetwork` function invariant:

* the `networkFlow` will always be called first, if it succeeds it will be followed by `saveToPersistenceFlow`.

## License
Reactor is licensed under the MIT License, Version 2.0. [View the license file](LICENSE)

Copyright (c) 2015 MailOnline

Header image by [Henrique Macedo](https://twitter.com/henrikemacedo). 
