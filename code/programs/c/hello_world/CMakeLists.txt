cmake_minimum_required(VERSION 3.15)
project(MultiCompilerCProject C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Print selected compiler
message(STATUS "Using compiler: ${CMAKE_C_COMPILER_ID} (${CMAKE_C_COMPILER})")

# Optional: print warning on unknown compiler
if (NOT CMAKE_C_COMPILER_ID MATCHES "GNU|Clang|AppleClang|MSVC")
  message(WARNING "Unknown compiler detected: ${CMAKE_C_COMPILER_ID}")
endif()

# Add your executable or library
add_executable(hello_world src/hello_world.c)

# Optionally set warnings and sanitizer flags based on compiler
if (CMAKE_C_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
  target_compile_options(hello_world PRIVATE -Wall -Wextra -fsanitize=address,undefined -g)
  target_link_options(hello_world PRIVATE -fsanitize=address,undefined)
elseif (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  target_compile_options(hello_world PRIVATE /W4 /permissive-)
endif()