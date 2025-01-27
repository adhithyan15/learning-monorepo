# Lua
Lua is a high level, multi-paradigm language that was designed to be lightweight and embedded into applications. It has a very small memory footprint and plays well with C/C++ easily. It also has a JIT compiler known as LuaJIT and it makes it even faster and efficient. Lua is written in ANSI C. So, it runs in almost all places where you can compile and run C code. 

## Built In Functions
### print
`print` is primarily used for displaying output. It works by calling `toString` of the object being printed and then displaying it to the console or any other output. Here is a simple "Hello World" program in Lua using `print`

```lua
print("Hello World")
```