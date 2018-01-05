# HoneyBee 
---
## Introduction

HoneyBee is a Swift library to increase the expressiveness of asynchronous and concurrent programming. HoneyBee design follows a few principles:

- __Show Me.__ Concurrent code should _look_ like the structure that it implements (see Examples below)
- __Bring Your Own Code.__ HoneyBee works with your asynchronous and synchronous functions, as they are today, with no modifications. (Usually.)
- __Safe By Default.__ HoneyBee enforces proper error handling techniques - while also reducing programmer burden. 


## Quick Examples

### Example: Show Me.
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

### Example: BYOC (Bring Your Own Code)
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

### Example: Safe By Default


One of the many problems with the "pyramid of doom" is that is both error-prone to get the error handling right.

```swift
func processImageData1(completionBlock: (result: Image?, error: Error?) -> Void) {
    loadWebResource("dataprofile.txt") { dataResource, error in
        loadWebResource("imagedata.dat") { imageResource, error in
            decodeImage(dataResource, imageResource) { imageTmp, error in
                dewarpAndCleanupImage(imageTmp) { imageResult in
                    completionBlock(imageResult, nil)
                }
            }
        }
    }
}
```

The above naive, "happy path" code has no error handling. 
Let's add the most principled form of handling now:

```swift
func processImageData2(completionBlock: (result: Image?, error: Error?) -> Void) {
    loadWebResource("dataprofile.txt") { dataResource, error in
        guard let dataResource = dataResource else {
            completionBlock(nil, error)
            return
        }
        loadWebResource("imagedata.dat") { imageResource, error in
            guard let imageResource = imageResource else {
                completionBlock(nil, error)
                return
            }
            decodeImage(dataResource, imageResource) { imageTmp, error in
                guard let imageTmp = imageTmp else {
                    completionBlock(nil, error)
                    return
                }
                dewarpAndCleanupImage(imageTmp) { imageResult in
                    guard let imageResult = imageResult else {
                        completionBlock(nil, error)
                        return
                    }
                    completionBlock(imageResult, nil)
                }
            }
        }
    }
}
```

Not very pretty, right? And there's still issues here. This form of `processImageData` has made its contract correctness dependent on the contract correctness of _all_ of the invoked asynchronous methods. What happens if one of the methods fails to call its completion? Or calls back more than once? What happens if a method calls the completion, but with two `nil` values? HoneyBee handles each of these issues for you, so that your method's correctness is not dependent on the correctness of any dependency method. 
Let's take a look at the Honeybee form:

```swift
func processImageData3(completionBlock: (result: Image?, error: Error?) -> Void) {
    HoneyBee.start { root in
        root.setErrorHanlder { completionBlock(nil, $0)}
            .branch { stem in
                stem.chain(loadWebResource =<< "dataprofile.txt")
                +
                stem.chain(loadWebResource =<< "imagedata.dat")
            }
            .chain(decodeImage)
            .chain(dewarpAndCleanupImage)
            .chain{ completionBlock($0, nil) }
    }
}
```

So much cleaner right? And _Bonus Points_, the HoneyBee implementation allows us to parallelize the first two async calls to `loadWebResource`, so this form has better performance than the others too. _Groovy._

(If you're wondering about the `=<<` operator it's pronounced `bind`. It performs a partial function application, "binding" the argument to the function. See the API docs for more details.)

### Error Diagnostics


Diagnosing problems in misbehaving concurrent code is really hard right? Not with HoneyBee. Consider the following: 

```swift
func handleError(_ error: Error, context: ErrorContext) {
    print(context)
}
func stringToInt(string: String, callback: (FailableResult<Int>) -> Void) {
    if let int = Int(string) {
        callback(.success(int))
    } else {
        let error = NSError(domain: "couldn't convert string to int", code: -2, userInfo: ["string:": string])
        callback(.failure(error))
    }
}
HoneyBee.start { root in
    root.setErrorHanlder(handleError)
        .insert(7)
        .chain(String.init)              // produces "7"
        .chain(String.append =<< "dog")  // produces "7dog"
        .chain(stringToInt)              // errors
        .chain(successFunc)              // not reached
}
```

prints

```
subject = "7dog"
file = "/Users/alex/HoneyBee/HoneyBeeTests/ErrorHandlingTests.swift"
line = 172
internalPath = 5 values {
  [0] = "start: /Users/alex/HoneyBee/HoneyBeeTests/ErrorHandlingTests.swift:167"
  [1] = "chain: /Users/alex/HoneyBee/HoneyBeeTests/ErrorHandlingTests.swift:169 insert"
  [2] = "chain: /Users/alex/HoneyBee/HoneyBeeTests/ErrorHandlingTests.swift:170 (Int) -> String"
  [3] = "chain: /Users/alex/HoneyBee/HoneyBeeTests/ErrorHandlingTests.swift:171 (String) -> String"
  [4] = "chain: /Users/alex/HoneyBee/HoneyBeeTests/ErrorHandlingTests.swift:172 (String, (FailableResult<Int>) -> ()) -> ()"
}
```

HoneyBee pinpoints the file and line where the recipe errored, along with the path which was taken to arrive at that function, and the inbound "subject" value. In most cases this reduces your diagnostic search process to a single function. 

### Wrap Up


So that's HoneyBee. Expressive, easy, and safe. Concurrency the way it should be.
If you have any questions, [contact me](mailto:alex@iamapps.net).