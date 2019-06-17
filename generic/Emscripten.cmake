#
# Toolchain for cross-compiling to JS using Emscripten
#
# Modify EMSCRIPTEN_PREFIX to your liking; use EMSCRIPTEN environment variable
# to point to it or pass it explicitly via -DEMSCRIPTEN_PREFIX=<path>.
#
#  mkdir build-emscripten && cd build-emscripten
#  cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/Emscripten.cmake
#

set(CMAKE_SYSTEM_NAME Emscripten)
set(CMAKE_SYSTEM_VERSION 1)

# Set a global EMSCRIPTEN variable that can be used in client CMakeLists.txt to detect when building using Emscripten.
# https://github.com/emscripten-core/emscripten/blob/incoming/cmake/Modules/Platform/Emscripten.cmake#L228
set(EMSCRIPTEN 1 CACHE BOOL "If true, we are targeting Emscripten output.")

# Help CMake find the platform file
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../modules ${CMAKE_MODULE_PATH})

if(NOT EMSCRIPTEN_PREFIX)
    if(DEFINED ENV{EMSCRIPTEN})
        file(TO_CMAKE_PATH "$ENV{EMSCRIPTEN}" EMSCRIPTEN_PREFIX)
    else()
        set(EMSCRIPTEN_PREFIX "/usr/lib/emscripten")
    endif()
endif()

set(EMSCRIPTEN_TOOLCHAIN_PATH "${EMSCRIPTEN_PREFIX}/system")

if(CMAKE_HOST_WIN32)
    set(EMCC_SUFFIX ".bat")
else()
    set(EMCC_SUFFIX "")
endif()

set(CMAKE_C_COMPILER "${EMSCRIPTEN_PREFIX}/emcc${EMCC_SUFFIX}")
set(CMAKE_CXX_COMPILER "${EMSCRIPTEN_PREFIX}/em++${EMCC_SUFFIX}")
set(CMAKE_AR "${EMSCRIPTEN_PREFIX}/emar${EMCC_SUFFIX}" CACHE FILEPATH "Emscripten ar")
set(CMAKE_RANLIB "${EMSCRIPTEN_PREFIX}/emranlib${EMCC_SUFFIX}" CACHE FILEPATH "Emscripten ranlib")

set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    "${EMSCRIPTEN_TOOLCHAIN_PATH}"
    "${EMSCRIPTEN_PREFIX}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Otherwise FindCorrade fails to find _CORRADE_MODULE_DIR. Why the heck is this
# not implicit is beyond me.
set(CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_FIND_ROOT_PATH})

# Since some unspecified release, -s WASM=1 is the default, so we need to
# explicitly say -s WASM=0 to use asm.js. The *_INIT variables are available
# since CMake 3.7, so it won't work in earlier versions. Sorry.
cmake_minimum_required(VERSION 3.7)

string(APPEND CMAKE_CXX_FLAGS_INIT " -s WASM=0")
string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " -s WASM=0")
string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " -DNDEBUG -O3")
string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " -O3 --llvm-lto 1")
