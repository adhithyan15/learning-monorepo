# Objective-C Summary

## Overview

Objective-C is a general-purpose, object-oriented programming language that adds Smalltalk-style messaging to the C programming language. It was the primary language used for macOS and iOS development before the introduction of Swift. It remains relevant for maintaining legacy systems and understanding existing Apple frameworks.

## Core Concepts

1.  **Superset of C:** Any valid C code is also valid Objective-C code. This allows mixing C and Objective-C seamlessly.
2.  **Object-Oriented:**
    * **Classes:** Blueprints for objects. Defined using `@interface` (declaration) and `@implementation` (definition).
    * **Objects:** Instances of classes, created using `[[ClassName alloc] init]` or convenience constructors.
    * **Inheritance:** Classes can inherit properties and methods from a single parent class (single inheritance). Most classes inherit from `NSObject`.
    * **Encapsulation:** Bundling data (instance variables) and methods operating on that data within objects.
    * **Polymorphism:** Objects of different classes can respond to the same message, often achieved through inheritance or protocols.
3.  **Messaging:**
    * Instead of calling methods directly like in C++ or Java, Objective-C sends *messages* to objects.
    * Syntax: `[receiver message]` or `[receiver messageWithArgument:arg1]`
    * Messages to `nil` (the null object pointer) are valid and simply do nothing (return 0, `nil`, or a zeroed struct depending on the return type). This simplifies code by avoiding many null checks.
4.  **Dynamic Runtime:**
    * **Dynamic Typing:** The `id` type represents a pointer to any type of object. The specific class of an object pointed to by `id` isn't determined until runtime.
    * **Dynamic Binding:** The exact method implementation to execute in response to a message is determined at runtime (late binding). This allows for flexibility like method swizzling.
    * **Introspection:** Objects can be queried about their properties and capabilities at runtime (e.g., `isKindOfClass:`, `respondsToSelector:`).

## Memory Management

* **Manual Reference Counting (MRC):** (Largely historical) Developers manually managed object lifetimes using `retain`, `release`, and `autorelease`. Complex and prone to leaks or crashes.
* **Automatic Reference Counting (ARC):** Introduced in 2011. The compiler automatically inserts the necessary `retain`/`release` calls at compile time based on object ownership rules. This is the standard for modern Objective-C development and significantly simplifies memory management. Requires understanding strong vs. weak references (`strong`, `weak`, `unsafe_unretained`).

## Key Syntax Elements

* `#import`: Preferred over `#include` for Objective-C headers; prevents multiple inclusions automatically.
* `@interface ClassName : SuperclassName` ... `@end`: Declares a class's public interface (properties, methods).
* `@implementation ClassName` ... `@end`: Defines the implementation of the methods declared in the interface.
* `@property`: Declares accessor methods (getter/setter) for instance variables. Attributes like `(nonatomic, strong)`, `(atomic, copy)`, `(weak)` control behavior and memory management.
* `@synthesize`: (Less common now) Explicitly tells the compiler to generate accessor methods for a `@property`. Modern Objective-C auto-synthesizes properties by default.
* `self`: A keyword referring to the current object instance within an instance method.
* `super`: A keyword used to call a method implementation in the superclass.
* `id`: A generic pointer type for any Objective-C object.
* `nil`: The null pointer value for Objective-C objects (equivalent to `(id)0`).
* `Nil`: The null pointer value for Objective-C classes (equivalent to `(Class)0`).
* `YES` / `NO`: Boolean values (typed as `BOOL`).
* `@selector(methodName:)`: A compiler directive to get a method selector (type `SEL`), used for dynamic invocation.
* `NSString`, `NSArray`, `NSDictionary`: Core immutable collection classes (Foundation framework). Mutable versions exist (`NSMutableString`, etc.).
* `NSNumber`: Wrapper class for primitive C numeric types.
* `@"`...`"`: Literal syntax for `NSString` objects (e.g., `@"Hello, World!"`).
* `@[]`: Literal syntax for `NSArray`.
* `@{}`: Literal syntax for `NSDictionary`.
* `@()`: Literal syntax for `NSNumber` (e.g., `@(123)`, `@(YES)`, `@(3.14)`).

## Important Features

* **Protocols (`@protocol`):** Similar to interfaces in Java or protocols in Swift. Define a list of methods that a class can promise to implement (adopt). Enables polymorphism without inheritance.
* **Categories:** Allow adding methods to existing classes (even classes you don't have the source code for) without subclassing. Useful for organizing code or extending framework classes.
* **Blocks:** Closure-like constructs that encapsulate a segment of code and can capture variables from their surrounding scope. Widely used for callbacks and asynchronous operations.

## Frameworks

* **Foundation:** Provides fundamental non-GUI classes: data storage (`NSArray`, `NSDictionary`), strings (`NSString`), object management, utilities (`NSDate`, `NSURL`). Essential for almost all Objective-C development.
* **AppKit:** Framework for developing macOS graphical user interfaces.
* **UIKit:** Framework for developing iOS, tvOS, and watchOS graphical user interfaces.

## Relationship with Swift

Swift is Apple's modern programming language, designed for safety, speed, and expressiveness. Swift and Objective-C are interoperable within the same project, allowing gradual migration or use of established Objective-C frameworks in Swift applications. For new Apple platform development, Swift is generally preferred, but Objective-C knowledge remains valuable for existing codebases and deeper framework understanding.

## Summary Points

* Object-oriented superset of C.
* Uses message passing `[receiver message]`.
* Dynamic runtime enables flexibility.
* Primarily uses ARC for memory management.
* Key features: Protocols, Categories, Blocks.
* Foundation framework is essential.
* Interoperable with Swift, but largely succeeded by it for new Apple development.