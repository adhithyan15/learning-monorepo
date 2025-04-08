# Operation

`Operation` is an abstraction that wraps a piece of code. The abstraction allows for the following functionality

* Name the piece of code - e.g serialize, getData, etc.
* Allows for the success and failure of the piece of code to be declared
* Measure the runtime of the piece of code
* Trap errors/exceptions and prevent them from crashing the program
* Allows for the authors of the code to add properties or "metadata" to the operation
* Allows for the collection of logs in the context of the operation
* Allows for the tracking of parent hierarchy of operations
* Should support both synchronous and asynchronous operations

The `Operation` abstraction will become a core abstraction that will be used repeatedly in this code base and will be implemented in all the languages that the repo supports. 
