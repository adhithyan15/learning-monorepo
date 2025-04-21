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

# Add aggressive warning flags per compiler
if (CMAKE_C_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
    target_compile_options(${EXE_NAME} PRIVATE
        -Wall
        -Wextra
        -pedantic
        -Wconversion
        -Wsign-conversion
        -Wshadow
        -Wstrict-prototypes
        -Wmissing-prototypes
        -Wdouble-promotion
        -Wformat=2
    )
    # Optional: Treat all warnings as errors
    # target_compile_options(${EXE_NAME} PRIVATE -Werror)

elseif (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(${EXE_NAME} PRIVATE
        /W4
        /permissive-
        /w14242  # conversion: possible loss of data
        /w14263  # does not override any base
        /w14265  # virtual funcs but no virtual dtor
        /w14287  # unsigned/negative mismatch
        /we4289  # loop var used outside scope
        /w14296  # expression always false
        /w14311  # pointer truncation
        # /WX    # Uncomment to treat warnings as errors
    )
endif()
