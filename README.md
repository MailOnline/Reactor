
Reactor
-----
[![Build Status](https://travis-ci.org/MailOnline/Reactor.svg?branch=master)](https://travis-ci.org/MailOnline/Reactor)
[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

Reactor's goal is to provide, out of the box, a Model layer with its different components talking with each other. With minimum setup, you are able to get the following:

* Network 
* Parsing
* Persistence

Reactor's then defines common flows (represented by the `ReactorFlow<T>`), that are typically used in applications. For example:

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
