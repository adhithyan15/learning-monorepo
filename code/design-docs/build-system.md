# Build System
I want to learn the ins and outs of build systems. So, I am planning to build a build system from scratch. 

## What is a build system?
At a very low level, a build system takes in one or more source files and produces one or more artifacts. But modern day build systems do so much more than that. They help you manage the complexity of external libraries and provide additional features like incremental builds where only the parts of the code that have changed are rebuilt. 

## Aren't there existing build systems?
Yes. There are plenty of existing build systems. Some of them I am familiar with are

* Make - A legendary build system. Originally designed to support building C/C++. But can build any language.
* CMake - It is technically a meta build system. It generates build files for other build systems. It is very commonly used for C/C++ projects. 
* Ninja - Ninja is also a meta build system. It generates build files for other build systems. It is used to build complex projects like Google Chrome, Node.js, etc.
* Blaze (and its open source port Bazel) - A build system built by Google and it is designed with monorepos in mind - https://bazel.build
* Buck - A build system built by Meta - https://buck2.build
* Meson - A cross platform build system that supports multiple different programming languages - https://mesonbuild.com
* Pants - A cross platform build system that supports multiple different programming languages as well - https://www.pantsbuild.org/

Some programming languages have their own build systems. Here are a few examples

* Rust - Cargo
* Java - Maven, Gradle
* JavaScript - Webpack, Parcel, Yarn
* Go - Go build
* Python - pybuilder, setuptools

## What's the proposed design?

### V1 Design
We will start with a very simple script that will act as our build system. Source code is usually stored in a number of directories. We will introduce two special files that will act as a guide to the script. 

* BUILD file - This file will contain the command line instructions that are needed to build some source code. Here is a quick example of a BUILD file.

```
ruby hello_world.rb
```

* DIRS file - This file will tell the build script whether to go inside one of the sub directories to look for a BUILD or DIRS file

```
hello_world
fibonacci
```

The build script will look for these two files and at the end of the day will simply run the command line instructions. 

### V2 Update
Every operating system has quirks. So, we need to add support for operating system specific build steps. To achieve this, I am introducing the
concept of operating system specific `BUILD` files. Three files will be detected by the build script

* BUILD_mac - Mac OS specific build instructions
* BUILD_linux - Linux OS specific build instructions
* BUILD_windows - Windows OS specific build instructions

If an operating system other than the one specified is found, the build file is simply skipped. 