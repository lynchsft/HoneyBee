# HoneyBee 
---
## Introduction

HoneyBee is a Swift library to increase the expressiveness of asynchronous and concurrent programming. HoneyBee design follows a few principles:

- __Show Me.__ Concurrent code should _look_ like the structure that it implements (see Examples below)
- __Bring Your Own Code.__ HoneyBee works with your asynchronous and synchronous functions, as they are today, with no modifications. (Usually. See Advanced Examples)
- __Safe By Design.__ HoneyBee enforces proper error handling techniques - while also reducing programmer burden. 


## Quick Examples

#### Example: Show Me.
```swift
HoneyBee.start { root in
    root.setErrorHandler(errorHandlingFunc)
        .chain(func1)
        .branch { stem in
            stem.chain(func3)
                .chain(func4)
            +
            stem.chain(func5)
                .chain(func6)
        }
        .chain(func7)
}
```

In the above example, `func1` will be called first. Then the result of `func1` will be passed to `func3` _and_ `func5` in parallel. `func4` will be called after `func3` has finished and will be passed the result of `func3`. Likewise, `func6` will be called after `func5` has finished and will be passed the result of `func5`. When _both_ `func4` and `func6` have finished, their results will be combined into a tuple and passed to `func7`. If _any_ of the functions `throws` or asynchronously responds with an `Error`, then `errorHandlingFunc` will be invoked with the error as an argument.

#### Example: BYOC (Bring Your Own Code)
```swift
func func1(completion: ([String]?, Error?) -> Void) {...}
func func2(string: String) throws -> Int {...}
func func3(int: Int, completion: (Error?) -> Void) {...}
func func4(int: Int, completion: (FailableResult<String>) -> Void) {...}
func func5(strings: [String], completion: () -> Void) {...}
func successFunc(strings: [String]) {...}
HoneyBee.start { root in
    root.setErrorHandler(errorHandler)
        .chain(func1)
        .map { elem in
            elem.chain(func2)
                .chain(func3)
                .chain(func4)
        }
        .chain(func5)
        .chain(successFunc)
}
```

In the above example we see six of HoneyBee's supported function signatures. `func1` is an Objective-C style errorring async callback. `func2` is a synchronous Swift throwing function. `func3` completes with an optional error but does not generate a new value. HoneyBee forwards the inbound value automatically. `func4` is a Swift style, generic enum-based result which may contain a value or may contain an error. `func5` is asynchronous but cannot error (UI animations fit this category). And `successFunc` is a simply, synchronous non-errorring function. 

HoneyBee supports **34** distinct function signatures.

## Other Features

- __Fault Detecting.__ HoneyBee recognizes when an async function _over-calls or under-calls_ its callback and responds appropriately. 