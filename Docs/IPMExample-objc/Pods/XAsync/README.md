# XAsync

- [Introduction](#introduction)
- [Install](#install)
- [Swift note](#swift-note)
- [Usage](#usage)
- [License](#license)
- [See also](#see-also)

## Introduction

Working with asyncronous operations might be tedious. In general there are two ways of doing this: using blocks and GCD (NSOperations are here as well) and using delegation. When the code performs a lot of such asynchronous operations it becomes very hard at some point to read this code. Obviously, synchronous code is much more convenient to read and maintain. This is where XAsync comes into play. It allows to call asynchronous opertion and stop further execution of current method until asynchronous operation is done. It is implemented in non-blocking manner, so other events can be (and will be) handled on the caller's thread when asynchronous operation is executing.
    
XAsync functionality inspired by C#'s await code constructions.

## Install

The easiest and recommended way to install XAsync for Objective-C/Swift applcations is to install and maintain it using CocoaPods.
 
- First of all you need to install CocoaPods to your computer. It might be done by executing the following line in terminal:

```
$ sudo gem install cocoapods
``` 
CocoaPods is built with Ruby and it will be installable with the default Ruby available on OS X.

- Open Xcode and create a new project (in the Xcode menu: File->New->Project), or navigate to existing Xcode project using:

```
$ cd <Path to Xcode project folder>
```

- In the Xcode project's folder create a new file, give it a name *Podfile* (with a capital *P* and without any extension). The following example shows how to compose the Podfile for an OSX application. If you are planning to use other platform the process will be quite similar. You only need to change platform to correspondent value. [Here](https://guides.cocoapods.org/syntax/podfile.html#platform) you can find more information about platform values.

```
source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.10'
use_frameworks!

target '<Put your Xcode target name here>' do
	pod 'XAsync'
end
```

- Get back to your terminal window and execute the following line:

```
$ pod install
```
 
- Close Xcode project (if it is still opened). For any further development purposes you should use Xcode *.xcworkspace* file created for you by CocoaPods.

You should be all set.
If you encountered any issues with CocoaPods installations try to find more information at [cocoapods.org](https://guides.cocoapods.org/using/getting-started.html).

## Swift note

Although XAsync is using Objective-C as its primary language it might be quite easily used in a Swift application. After XAsync is installed as described in the [Install](#install) section it is necessary to perform the following:

- Create a new header file in the Swift project.
- Name it something like *BridgingHeader.h*
- Put there the following line:

``` objective-c
@import XAsync;
```

- In the Xcode build settings find the setting called *Objective-C Bridging Header* and set the path to your BridgingHeader.h file. Be aware that this path is relative to your Xcode project's folder.

You can find more information about using Objective-C and Swift in the same project [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).  

## Usage

Below you can find a the examples for using XAsync functionality in a synchronous manner.

###### Objective-C
```objective-c
//...
@import XAsync;
//...
NSLog(@"About to start async task 1.");
[XAsync await:^{
    NSLog(@"Task 1 has been started.");
    for (NSInteger i = 0; i < 1000000000; i++) {
    }
    NSLog(@"Task 1 is about to end.");
}];
NSLog(@"Async task 1 has been done.");
        
NSLog(@"About to start async task 2.");
NSNumber *result = [XAsync awaitResult:^ id _Nullable {
    NSLog(@"Task 2 has been started.");
    NSInteger i = 0;
    for (i = 0; i < 1000000000; i++) {
    }
    NSLog(@"Task 2 is about to end.");
    return [NSNumber numberWithInteger:i];
}];
NSLog(@"Async task 2 has been done with result: %@", [result stringValue]);
//...
```

###### Swift
```swift
//...
print("About to start async task 1.")
XAsync.await{
    print("Task 1 has been started.");
    for _ in 1...1000000000 {
        
    }
    print("Task 1 is about to end.")
    
}
print("Async task 1 has been done.")

print("About to start async task 2.")
if let result = XAsync.awaitResult({ () -> AnyObject? in
    print("Task 2 has been started.")
    var i = 0
    for _ in 1...1000000000 {
        i += 1
    }
    print("Task 2 is about to end.")
    return i
}) {
    print("Async task 2 has been done with result: \(result)")
}
//...
```

## License

Usage is provided under the [MIT License](https://opensource.org/licenses/MIT). See LICENSE for the full details.