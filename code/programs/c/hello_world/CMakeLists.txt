cmake_minimum_required(VERSION 3.15)
project(hello_cmake C)

# Require C99 standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Export compile_commands.json for tooling (e.g., clangd, VSCode)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Detect and normalize the compiler name
string(TOLOWER "${CMAKE_C_COMPILER_ID}" COMPILER_NAME)

# Log compiler info
message(STATUS "Using compiler: ${CMAKE_C_COMPILER_ID} (${CMAKE_C_COMPILER})")
message(STATUS "Compiler name (normalized): ${COMPILER_NAME}")

# Output directory (per compiler)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin-${COMPILER_NAME}")

# Optionally: name the executable uniquely
set(EXE_NAME "hello-world-${COMPILER_NAME}")

# Define the executable
add_executable(${EXE_NAME} hello_world.c)

# Add compiler-specific warning flags
if (CMAKE_C_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
    target_compile_options(${EXE_NAME} PRIVATE -Wall -Wextra -pedantic)
elseif (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(${EXE_NAME} PRIVATE /W4 /permissive-)
endif()
